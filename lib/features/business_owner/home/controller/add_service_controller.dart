import 'dart:convert';
import 'dart:developer';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/home/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../model/get_single_service_model.dart';
import 'business_owner_controller.dart';

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
    final Map<String, String> requestBody = {
      "title": titleTEController.text,
      "price": priceTEController.text,
      "discount_price": discountPriceTEController.text,
      "description": descriptionTEController.text,
      "category": selectedCategoryId.value.toString(),
      "duration": durationTEController.text,
      "capacity": capacityTEController.text,
    };

    try {
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

      if (response.statusCode == 201) {
        AppSnackBar.showSuccess('Service Created successfully!');
        final businessController = Get.find<BusinessOwnerController>();
        await businessController.fetchAllMyService();
        Get.back();
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError('Failed to create service. Please try again.');
    }
  }

  Future<void> updateService({required String id}) async {
    inProgress.value = true;
    final Map<String, String> requestBody = {
      "title": titleTEController.text,
      "price": priceTEController.text,
      "discount_price": discountPriceTEController.text,
      "description": descriptionTEController.text,
      "category": singleServiceDetails.value.category?.toString() ?? '1',
      "duration": durationTEController.text,
      "capacity": capacityTEController.text,
    };

    try {
      await _sendPutRequestWithHeadersAndImagesOnly(
        AppUrls.updateService(id),
        selectedImagePath.value,
        AuthService.accessToken,
        requestBody,
      );
    } catch (e) {
      log('Error updating service: $e');
      AppSnackBar.showError('Failed to update service. Please try again.');
    } finally {
      inProgress.value = false;
    }
  }

  Future<void> toggleServiceStatus(String id) async {
    inProgress.value = true;
    final currentStatus = singleServiceDetails.value.isActive ?? false;
    final Map<String, String> requestBody = {
      "title": singleServiceDetails.value.title ?? '',
      "price": singleServiceDetails.value.price ?? '',
      "discount_price": singleServiceDetails.value.discountPrice ?? '',
      "description": singleServiceDetails.value.description ?? '',
      "category": singleServiceDetails.value.category?.toString() ?? '1',
      "duration": singleServiceDetails.value.duration?.toString() ?? '',
      "capacity": singleServiceDetails.value.capacity?.toString() ?? '',
      "is_active": (!currentStatus).toString(),
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
        AuthService.accessToken,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Service deleted successfully!');
        final businessController = Get.find<BusinessOwnerController>();
        await businessController.fetchAllMyService();
        Get.back(); // Pop the dialog
        Get.back(); // Pop the EditServiceScreen
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      inProgress.value = false;
    }
  }
}
