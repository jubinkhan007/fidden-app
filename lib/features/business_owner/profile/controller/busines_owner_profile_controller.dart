import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';
import 'package:fidden/features/business_owner/profile/screens/stripe_webview_screen.dart';
import 'package:fidden/features/business_owner/profile/services/shop_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fidden/core/services/Auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/business_profile_model.dart';

class BusinessOwnerProfileController extends GetxController {
  final RxSet<String> openDays = <String>{}.obs;
  var startDay = ''.obs;
  var endDay = ''.obs;
  var startTime = ''.obs;
  var endTime = ''.obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;

  var lat = "".obs;
  var long = "".obs;

  var profileImage = Rxn<File>();
  var imagePath = ''.obs;
  var documents = <File>[].obs;

  Future<void> pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        documents.addAll(
          result.paths.where((path) => path != null).map((path) => File(path!)),
        );
        documents.refresh();
      }
    } catch (e) {
      AppSnackBar.showError("Error picking files: $e");
    }
  }

  // Method to pick profile image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      imagePath.value = pickedFile.path;
      // updateProfilePhoto();
    }
  }

  void initializeSchedule({
    required String startDayVal,
    required String endDayVal,
    required String startTimeVal,
    required String endTimeVal,
  }) {
    startDay.value = startDayVal;
    endDay.value = endDayVal;
    startTime.value = startTimeVal;
    endTime.value = endTimeVal;
  }

  void pickDay({required bool isStart}) async {
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    String? selectedDay = await showDialog<String>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Day'),
        content: SizedBox(
          height: 300,
          width: 200,
          child: ListView(
            children: days.map((day) {
              return ListTile(
                title: Text(day),
                onTap: () => Navigator.pop(context, day),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedDay != null) {
      if (isStart) {
        startDay.value = selectedDay;
      } else {
        endDay.value = selectedDay;
      }
    }
  }

  void pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final DateTime fullDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // Custom formatting: 10:00 a.m. / 10:00 p.m.
      final formatted = DateFormat('hh:mm a')
          .format(fullDateTime)
          .toLowerCase()
          .replaceAll('am', 'a.m.')
          .replaceAll('pm', 'p.m.');

      if (isStart) {
        startTime.value = formatted; // e.g., "10:00 a.m."
      } else {
        endTime.value = formatted; // e.g., "10:00 p.m."
      }
    }
  }

  final isCheckingStripeStatus = false.obs;
  final Rxn<StripeVerifyResponse> stripeStatus = Rxn<StripeVerifyResponse>();
  bool _awaitingOnboarding = false;

  @override
  void onInit() {
    super.onInit();
    _init(); // keep onInit lean

    // If tokens refresh after we mounted, refetch profile quietly
    ever(AuthService.tokenRefreshCount, (_) async {
      await fetchProfileDetails(silentAuthErrors: true);
      await checkStripeStatusIfPossible();
    });

    WidgetsBinding.instance.addObserver(
      _LifecycleObserver(onResumed: () async {
        if (_awaitingOnboarding) {
          _awaitingOnboarding = false;
          await checkStripeStatusIfPossible();
        }
      }),
    );
  }

  Future<void> _init() async {
    await AuthService.waitForToken();                 // ← wait for token
    await fetchProfileDetails(silentAuthErrors: true);
    final fromApi = profileDetails.value.data?.openDays;
    if (fromApi != null && fromApi.isNotEmpty) openDays.addAll(fromApi);
    startTime.value = profileDetails.value.data?.startTime ?? startTime.value;
    endTime.value   = profileDetails.value.data?.endTime   ?? endTime.value;
    await checkStripeStatusIfPossible();
  }

  Future<void> checkStripeStatusIfPossible() async {
    final shopId = profileDetails.value.data?.id?.toString();
    if (shopId == null || shopId.isEmpty) return;

    isCheckingStripeStatus.value = true;
    try {
      final res = await ShopApi().verifyStripeOnboarding(
        shopId: int.parse(shopId),
        token: AuthService.accessToken ?? '',
      );
      stripeStatus.value = res;
    } catch (e) {
      // Optionally surface a toast/snackbar
      // AppSnackBar.showError('Stripe verify failed');
    } finally {
      isCheckingStripeStatus.value = false;
    }
  }

  Future<void> startStripeOnboarding(int shopId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final link = await ShopApi().getStripeOnboardingLink(
        shopId: shopId,
        token: AuthService.accessToken ?? '',
      );
      Get.back(); // close loader

      final completed = await Get.to<bool>(
        () => StripeWebViewScreen(onboardingUrl: link.url),
      );

      // ✅ Always re-verify when you come back
      await Future.delayed(
        const Duration(milliseconds: 200),
      ); // give Stripe a beat
      await checkStripeStatusIfPossible();

      if (completed == true) {
        AppSnackBar.showSuccess('Stripe onboarding complete.');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.showError(
        'Could not start Stripe onboarding. Please try again.',
      );
    }
  }

  var profileDetails = GetBusinesModel(data: null).obs;

  Future<void> fetchProfileDetails({bool silentAuthErrors = false}) async {
    isLoading.value = true;
    try {
      await AuthService.waitForToken();               // safety if called elsewhere

      final response = await NetworkCaller().getRequest(
        AppUrls.getMBusinessProfile,
        token: AuthService.accessToken,
        treat404AsEmpty: true,
        emptyPayload: const {"data": null},           // normalize shape
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        profileDetails.value = GetBusinesModel.fromJson(response.responseData);
        return;
      }

      // Normalize expected startup/auth cases without toasting
      final sc = response.statusCode ?? 0;
      final err = (response.errorMessage ?? '').toLowerCase();   // ← safe

      // “no shop yet” or unauthorized on boot: keep quiet
      if (sc == 401 || sc == 403 || err.contains('shop')) {
        profileDetails.value = GetBusinesModel(data: null);
        return;
      }

      // Unexpected failure: only toast if not in silent mode
      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError(response.errorMessage ?? 'Failed to fetch profile.');
      }
    } catch (e) {
      // Don’t scare the user on bootstrap—log & set safe state
      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError('An error occurred while fetching profile details.');
      }
      if (kDebugMode) log('Fetch profile details error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> createBusinessProfile({
    required String businessName,
    required String businessAddress,
    required String aboutUs,
    required String capacity,
  }) async {
    isLoading.value = true;
    clearErrors();
    try {
      final uiStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
      final uiClose = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';
      const allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final closed = allDays.where((d) => !openDays.contains(d)).toList();

      final response = await ShopApi().createShopWithImage(
        name: businessName,
        address: businessAddress,
        aboutUs: aboutUs,
        capacity: int.tryParse(capacity) ?? 0,
        startAtUi: uiStart,
        closeAtUi: uiClose,
        closeDays: closed.map((e) => e.toLowerCase()).toList(),
        latitude: lat.value.isEmpty ? null : lat.value,
        longitude: long.value.isEmpty ? null : long.value,
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        documents: documents,
        token: AuthService.accessToken ?? '',
      );

      if (response.isSuccess) {
        profileDetails.value = GetBusinesModel.fromJson(response.responseData);
        AppSnackBar.showSuccess("Business Profile created successfully!");
        final svc = Get.isRegistered<BusinessOwnerController>() ? Get.find<BusinessOwnerController>() : null;
        await svc?.refreshGuardsAndServices();
        Get.offNamed('/all-services');
      } else {
        log('Create profile failed: ${response.statusCode}, error: ${response.errorMessage}');
        AppSnackBar.showError(response.errorMessage.isNotEmpty ? response.errorMessage : 'Create failed.');
      }
    } catch (e) {
      log('Create profile error: $e');
      AppSnackBar.showError('Failed to create business profile.');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _sendPutRequestWithHeadersAndImagesOnly1(
    String url,
    Map<String, dynamic> body,
    String? imagePath,
    String? token,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');

      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({'Authorization': token});

      request.fields['bodyData'] = jsonEncode(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        log('Attaching image: $imagePath');
        request.files.add(
          await http.MultipartFile.fromPath('businessProfileImage', imagePath),
        );
      }

      log('Request Headers: ${request.headers}');
      log('Request Fields: ${request.fields}');

      var response = await request.send();
      debugPrint("----------------------------------------------------------");

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile created successfully!");
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError(errorResponse);
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError(
        "Failed to create business profile. Please try again.",
      );
    }
  }

  String _toApiTime(String ui) {
    final m = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    ).firstMatch(ui);
    if (m == null) return ui; // fallback
    int h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00';
  }

  String? _buildLocation(String latStr, String longStr) {
    final lat = double.tryParse(latStr);
    final lon = double.tryParse(longStr);
    if (lat == null || lon == null) return null; // don’t send invalid
    return '$lat,$lon'; // <-- no space
  }

  Future<void> updateBusinessProfile({
    required businessName,
    required businessAddress,
    required String aboutUs,
    required String id,
    required String capacity,
    List<String>? openDays, // UI passes these; we only send close_days
    List<String>? closeDays, // if null, we derive
    String? startAt, // "09:00 AM"
    String? closeAt, // "06:00 PM"
  }) async {
    try {
      isLoading.value = true;

      // Times with fallback to observables / model
      final uiStart = (startAt?.isNotEmpty ?? false)
          ? startAt!
          : (startTime.value.isNotEmpty
                ? startTime.value
                : (profileDetails.value.data?.startTime ?? '09:00 AM'));

      final uiClose = (closeAt?.isNotEmpty ?? false)
          ? closeAt!
          : (endTime.value.isNotEmpty
                ? endTime.value
                : (profileDetails.value.data?.endTime ?? '06:00 PM'));

      // Closed days (if UI didn’t pass, derive from controller.openDays)
      const allDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final open = (openDays != null && openDays.isNotEmpty)
          ? openDays
          : this.openDays.toList();
      final closed = (closeDays != null && closeDays.isNotEmpty)
          ? closeDays
          : allDays.where((d) => !open.contains(d)).toList();

      final resp = await ShopApi().updateShopWithImage(
        id: id,
        name: businessName,
        address: businessAddress,
        aboutUs: aboutUs,
        capacity: int.tryParse(capacity) ?? 0,
        startAtUi: uiStart,
        closeAtUi: uiClose,
        closeDays: closed.map((e) => e.toLowerCase()).toList(),
        latitude: lat.value.isEmpty ? null : lat.value,
        longitude: long.value.isEmpty ? null : long.value,
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        documents: documents,
        token: AuthService.accessToken ?? '',
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
        await fetchProfileDetails();
        // ✅ forward navigation – replace current screen in the stack
        Get.offNamed('/all-services'); // or Get.off(() => AllServiceScreen());
        return;
      } else {
        AppSnackBar.showError('Update failed');
      }
    } catch (e) {
      log('Update error: $e');
      AppSnackBar.showError('Failed to update business profile.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendPutRequestWithHeadersAndImagesOnly(
    String url,
    Map<String, dynamic> body,
    String? imagePath,
    String? token,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');

      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));

      request.headers.addAll({'Authorization': token});

      request.fields['bodyData'] = jsonEncode(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        log('Attaching image: $imagePath');
        request.files.add(
          await http.MultipartFile.fromPath('businessProfileImage', imagePath),
        );
      }

      log('Request Headers: ${request.headers}');
      log('Request Fields: ${request.fields}');

      var response = await request.send();
      debugPrint("----------------------------------------------------------");

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError(errorResponse);
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError(
        "Failed to update business profile. Please try again.",
      );
    }
  }

  // lib/features/business_owner/profile/controller/busines_owner_profile_controller.dart

// lib/features/business_owner/profile/controller/busines_owner_profile_controller.dart

Future<bool> deleteBusinessProfile(String shopId) async {
  isDeleting.value = true;
  try {
    final response = await NetworkCaller().deleteRequest(
      AppUrls.deleteShop(shopId),
      token: AuthService.accessToken,
    );

    // close only the confirmation dialog if it’s open
    if (Get.isDialogOpen ?? false) Get.back();

    if (!response.isSuccess) {
      AppSnackBar.showError(response.errorMessage ?? 'Failed to delete profile.');
      return false;
    }

    AppSnackBar.showSuccess("Business Profile deleted successfully!");

    // reset local state
    profileDetails.value = GetBusinesModel(data: null);
    openDays.clear();
    startTime.value = '';
    endTime.value = '';

    // refresh anything else that depends on shop
    if (Get.isRegistered<BusinessOwnerController>()) {
      await Get.find<BusinessOwnerController>().refreshGuardsAndServices();
    }

    // don’t navigate here; just report success
    return true;
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    AppSnackBar.showError('An error occurred while deleting the profile.');
    return false;
  } finally {
    isDeleting.value = false;
  }
}

  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  void clearErrors() => fieldErrors.clear();
  void setFieldError(String field, String message) {
    fieldErrors[field] = message;
    fieldErrors.refresh();
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  final Future<void> Function() onResumed;
  _LifecycleObserver({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
