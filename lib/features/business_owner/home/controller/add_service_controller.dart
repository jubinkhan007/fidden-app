// lib/features/business_owner/home/controller/add_service_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/home/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../model/get_single_service_model.dart';
import 'business_owner_controller.dart';
import 'owner_service_slot_controller.dart';
import 'package:path/path.dart' as p;

class AddServiceController extends GetxController {
  TextEditingController titleTEController = TextEditingController();
  TextEditingController priceTEController = TextEditingController();
  TextEditingController discountPriceTEController = TextEditingController();
  TextEditingController descriptionTEController = TextEditingController();
  TextEditingController durationTEController = TextEditingController();
  TextEditingController capacityTEController = TextEditingController();
  var selectedImagePath = ''.obs;
  var categories = <CategoryModel>[].obs;
  var selectedCategoryId = Rxn<int>();

  var inProgress = false.obs;

  var singleServiceDetails = GetSingleServiceModel().obs;
  final RxBool requiresAge18Plus = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getCategories,
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        if (response.responseData is List) {
          categories.value = List<CategoryModel>.from(
            response.responseData.map((x) => CategoryModel.fromJson(x)),
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching categories: $e');
    }
  }

  Future<void> fetchService(String id) async {
    inProgress.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getSingleService(id),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          singleServiceDetails.value = GetSingleServiceModel.fromJson(
            response.responseData,
          );
          selectedCategoryId.value = singleServiceDetails.value.category;
          // NEW: seed the toggle from the loaded model
          requiresAge18Plus.value = singleServiceDetails.value.requiresAge18Plus;
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      inProgress.value = false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImagePath.value = pickedFile.path;
    } else {
      AppSnackBar.showError('No image selected');
    }
  }

  Future<void> createService() async {
    inProgress.value = true;
    try {
      // defensive guard
      final priceVal    = double.tryParse(priceTEController.text.trim()) ?? 0;
      final durationVal = int.tryParse(durationTEController.text.trim()) ?? 0;
      final capacityVal = int.tryParse(capacityTEController.text.trim()) ?? 0;

      if (priceVal <= 0 || durationVal <= 0 || capacityVal <= 0) {
        AppSnackBar.showError('Price, duration and capacity must all be greater than 0.');
        inProgress.value = false;
        return;
      }

      final price = priceTEController.text;
      final discountPriceText = discountPriceTEController.text;

      final effectiveDiscountPrice =
      (discountPriceText.isEmpty || double.tryParse(discountPriceText) == 0)
          ? price
          : discountPriceText;

      final Map<String, String> requestBody = {
        "title": titleTEController.text,
        "price": price,
        "discount_price": effectiveDiscountPrice,
        "description": descriptionTEController.text,
        "category": selectedCategoryId.value.toString(),
        "duration": durationTEController.text,
        "capacity": capacityTEController.text,
        "is_active": "true",
        // NEW: send the toggle
        "requires_age_18_plus": requiresAge18Plus.value.toString(), // "true"/"false"
      };

      await _sendPostRequestWithHeadersAndImagesOnly(
        AppUrls.createService,
        selectedImagePath.value,
        AuthService.accessToken,
        requestBody,
      );
    } catch (e) {
      log('Error creating service: $e');
      AppSnackBar.showError('Failed to create service. Please try again.');
    } finally {
      inProgress.value = false;
    }
  }

  Future<void> _sendPostRequestWithHeadersAndImagesOnly(
    String url,
    String? imagePath,
    String? token,
    Map<String, String> body,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields.addAll(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        log('Attaching image: $imagePath');
        request.files.add(
          await http.MultipartFile.fromPath('service_img', imagePath),
        );
      }

      log('Request Headers: ${request.headers}');
      log('Request Fields: ${request.fields}');

      var response = await request.send();
      debugPrint(
        "--------------------------------------------------------------",
      );
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final businessController = Get.find<BusinessOwnerController>();
        await businessController.fetchAllMyService();
        Get.back();
        // Show snackbar after navigation to avoid disposed snackbar error
        Future.delayed(const Duration(milliseconds: 100), () {
          AppSnackBar.showSuccess('Service Created successfully!');
        });
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError('Failed to create service: $errorResponse');
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError('Failed to create service. Please try again.');
    }
  }

  Future<void> updateService({required String id}) async {
    inProgress.value = true;
    try {
      final s = singleServiceDetails.value;

      final int? categoryId = selectedCategoryId.value ?? s.category;
      if (categoryId == null) {
        AppSnackBar.showError('Please select a category.');
        inProgress.value = false;
        return;
      }

      final Map<String, dynamic> body = {
        'title'      : titleTEController.text.trim(),
        'price'      : priceTEController.text.trim(),
        'description': descriptionTEController.text.trim(),
        'duration'   : int.tryParse(durationTEController.text.trim()) ?? s.duration ?? 0,
        'capacity'   : int.tryParse(capacityTEController.text.trim()) ?? s.capacity ?? 1,
        'category'   : categoryId,
        'requires_age_18_plus': requiresAge18Plus.value,
      };

      final dp = discountPriceTEController.text.trim();
      if (dp.isNotEmpty) body['discount_price'] = dp;

      // include disabled times chosen in the Manage Slots card (JSON is fine)
      final tag = s.id != null ? 'svc_${s.id}' : null;
      if (tag != null && Get.isRegistered<OwnerServiceSlotsController>(tag: tag)) {
        final slotsCtrl = Get.find<OwnerServiceSlotsController>(tag: tag);
        body['disabled_start_times'] = slotsCtrl.disabledStartTimesForSave;
      }

      // 1) Update all metadata via JSON (no multipart here)
      final resp = await NetworkCaller().putRequest(
        AppUrls.updateService(id),
        token: AuthService.accessToken,
        body: body,
      );
      if (!resp.isSuccess) {
        AppSnackBar.showError(resp.errorMessage ?? 'Update failed');
        return;
      }

      // 2) If user picked a new image, PATCH image ONLY (no list fields)
      final hasNewImage = selectedImagePath.value.isNotEmpty;
      if (hasNewImage) {
        await _sendPatchMultipartWithImage(
          url: AppUrls.updateService(id),
          token: AuthService.accessToken ?? '',
          fields: const {}, // ← IMPORTANT: send no fields, only the file
          imagePath: selectedImagePath.value,
        );
        AppSnackBar.showSuccess('Service updated (image uploaded)');
      } else {
        AppSnackBar.showSuccess('Service updated');
      }

      // reset unsaved state if present
      if (tag != null && Get.isRegistered<OwnerServiceSlotsController>(tag: tag)) {
        Get.find<OwnerServiceSlotsController>(tag: tag).markSaved();
      }

      await fetchService(id);
    } catch (e) {
      AppSnackBar.showError('Failed to update service. $e');
    } finally {
      inProgress.value = false;
    }
  }


  Future<void> _sendPatchMultipartWithImage({
    required String url,
    required String token,
    required Map<String, dynamic> fields, // send {} for image-only
    required String imagePath,
  }) async {
    final req = http.MultipartRequest('PATCH', Uri.parse(url));
    req.headers['Authorization'] = 'Bearer $token';

    // Add only non-problematic fields (you’ll pass {} here)
    fields.forEach((k, v) {
      if (v == null) return;
      if (v is bool || v is num || v is String) {
        final s = v.toString();
        if (s.isNotEmpty) req.fields[k] = s;
      } else {
        // avoid sending lists/maps here; they break with multipart
        // If you ever need them, JSON-encode only when non-empty.
        req.fields[k] = jsonEncode(v);
      }
    });

    // Attach image (with proper filename + content type)
    final mime = lookupMimeType(imagePath) ?? 'image/jpeg';
    final type = mime.split('/');
    req.files.add(
      await http.MultipartFile.fromPath(
        'service_img',
        imagePath,
        filename: p.basename(imagePath),
        contentType: MediaType(type[0], type[1]),
      ),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Multipart PATCH failed (${res.statusCode}): $body');
    }
  }




  Future<void> toggleServiceStatus(String id) async {
    inProgress.value = true;
    final currentStatus = singleServiceDetails.value.isActive ?? true;
    final Map<String, String> requestBody = {
      "title": singleServiceDetails.value.title ?? '',
      "price": singleServiceDetails.value.price ?? '',
      "discount_price": singleServiceDetails.value.discountPrice ?? '',
      "description": singleServiceDetails.value.description ?? '',
      "category": singleServiceDetails.value.category?.toString() ?? '1',
      "duration": singleServiceDetails.value.duration?.toString() ?? '',
      "capacity": singleServiceDetails.value.capacity?.toString() ?? '',
      "is_active": (!currentStatus).toString(),
      "requires_age_18_plus":
      (singleServiceDetails.value.requiresAge18Plus).toString(),
    };

    try {
      await _sendPutRequestWithHeadersAndImagesOnly(
        AppUrls.updateService(id),
        null, // No image change for status toggle
        AuthService.accessToken,
        requestBody,
      );
    } catch (e) {
      log('Error updating service status: $e');
      AppSnackBar.showError(
        'Failed to update service status. Please try again.',
      );
    } finally {
      inProgress.value = false;
    }
  }

  Future<void> _sendPutRequestWithHeadersAndImagesOnly(
    String url,
    String? imagePath,
    String? token,
    Map<String, String> body,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');
      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields.addAll(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        log('Attaching image: $imagePath');
        request.files.add(
          await http.MultipartFile.fromPath('service_img', imagePath),
        );
      }

      log('Request Headers: ${request.headers}');
      log('Request Fields: ${request.fields}');

      var response = await request.send();
      debugPrint(
        "--------------------------------------------------------------",
      );
      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        AppSnackBar.showSuccess('Service updated successfully!');
        final businessController = Get.find<BusinessOwnerController>();
        await businessController.fetchAllMyService();
        await fetchService(singleServiceDetails.value.id.toString());
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError('Failed to update service. Please try again.');
    }
  }

  Future<void> deleteService(String id) async {
    inProgress.value = true;
    try {
      final response = await NetworkCaller().deleteRequest(
        AppUrls.deleteService(id),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        final businessController = Get.find<BusinessOwnerController>();
        await businessController.fetchAllMyService();
        // Close dialog and screen FIRST to avoid disposed snackbar error
        if (Get.isDialogOpen ?? false) {
          Get.back(); // Pop the dialog
        }
        Get.back(); // Pop the EditServiceScreen
        // Show snackbar AFTER navigation completes
        Future.delayed(const Duration(milliseconds: 100), () {
          AppSnackBar.showSuccess('Service deleted successfully!');
        });
      } else {
        AppSnackBar.showError(response.errorMessage ?? 'Failed to delete service');
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      inProgress.value = false;
    }
  }
}
