// lib/features/business_owner/profile/controller/busines_owner_profile_controller.dart
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

import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../data/business_profile_model.dart';

class BusinessOwnerProfileController extends GetxController {
  // ---- UI state ----
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

  // Cancellation policy fields (strings bound to inputs)
  final freeCancellationHours = ''.obs;     // e.g. "24"
  final cancellationFeePercentage = ''.obs; // e.g. "50"
  final noRefundHours = ''.obs;             // e.g. "4"

  // Deposit UI state
  final isDepositRequired = false.obs;
  final depositAmount = ''.obs;

  // ---- Subscription context ----
  final sub = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  bool get _isFoundation => sub.isFoundation;
  bool get _isMomentum   => sub.isMomentum;
  bool get _isIcon       => sub.isIcon;

  // What each tier can edit
  bool get canEditDeposit => _isMomentum || _isIcon;
  bool get canEditPolicy  => _isIcon;

  // For upgrade messages
  // void _toastUpgradeForPolicy() =>
  //     AppSnackBar.showSuccess('Upgrade to Icon to edit cancellation policy.');
  // void _toastUpgradeForDeposit() =>
  //     AppSnackBar.showSuccess('Upgrade your plan to edit deposit settings.');

  // Stripe verify
  final isCheckingStripeStatus = false.obs;
  final Rxn<StripeVerifyResponse> stripeStatus = Rxn<StripeVerifyResponse>();
  bool _awaitingOnboarding = false;

  // Loaded profile (handles both wrapped and raw shapes)
  var profileDetails = GetBusinesModel(data: null).obs;

  // ---------------- Lifecycle ----------------
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
    await AuthService.waitForToken();
    await fetchProfileDetails(silentAuthErrors: true);

    // Seed UI from API
    final data = profileDetails.value.data;
    final fromApiOpenDays = data?.openDays;
    if (fromApiOpenDays != null && fromApiOpenDays.isNotEmpty) {
      openDays
        ..clear()
        ..addAll(fromApiOpenDays);
    }

    startTime.value = data?.startTime ?? startTime.value;
    endTime.value   = data?.endTime   ?? endTime.value;

    // Cancellation policy (defaults when missing)
    freeCancellationHours.value     = (data?.freeCancellationHours ?? 24).toString();
    cancellationFeePercentage.value = (data?.cancellationFeePercentage ?? 0).toString();
    noRefundHours.value             = (data?.noRefundHours ?? 0).toString();

    // Deposit (best-effort – BusinessProfileModel has depositAmount)
    depositAmount.value      = (data?.depositAmount ?? '0.00');
    isDepositRequired.value  =  data?.isDepositRequired ?? false;

    await checkStripeStatusIfPossible();
  }

  // ---------------- Stripe onboarding helpers ----------------
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
    } catch (_) {
      // keep quiet
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

      // Always re-verify when you come back
      await Future.delayed(const Duration(milliseconds: 200));
      await checkStripeStatusIfPossible();

      if (completed == true) {
        AppSnackBar.showSuccess('Stripe onboarding complete.');
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.showError('Could not start Stripe onboarding. Please try again.');
    }
  }

  // ---------------- Pickers ----------------
  Future<void> pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        documents.addAll(
          result.paths.where((p) => p != null).map((p) => File(p!)),
        );
        documents.refresh();
      }
    } catch (e) {
      AppSnackBar.showError("Error picking files: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
      imagePath.value = picked.path;
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
    const days = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday',
    ];
    String? selectedDay = await showDialog<String>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Day'),
        content: SizedBox(
          height: 300,
          width: 200,
          child: ListView(
            children: days
                .map((day) => ListTile(
              title: Text(day),
              onTap: () => Navigator.pop(context, day),
            ))
                .toList(),
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
      final full = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      final formatted = DateFormat('hh:mm a')
          .format(full)
          .toLowerCase()
          .replaceAll('am', 'a.m.')
          .replaceAll('pm', 'p.m.');

      if (isStart) {
        startTime.value = formatted;
      } else {
        endTime.value = formatted;
      }
    }
  }

  // ---------------- Networking: read ----------------
  Future<void> fetchProfileDetails({bool silentAuthErrors = false}) async {
    isLoading.value = true;
    try {
      await AuthService.waitForToken();

      final response = await NetworkCaller().getRequest(
        AppUrls.getMBusinessProfile,
        token: AuthService.accessToken,
        treat404AsEmpty: true,
        emptyPayload: const {"data": null},
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        profileDetails.value = GetBusinesModel.fromJson(response.responseData);
        return;
      }

      final sc = response.statusCode ?? 0;
      final err = (response.errorMessage ?? '').toLowerCase();

      if (sc == 401 || sc == 403 || err.contains('shop')) {
        profileDetails.value = GetBusinesModel(data: null);
        return;
      }

      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError(response.errorMessage ?? 'Failed to fetch profile.');
      }
    } catch (e) {
      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError('An error occurred while fetching profile details.');
      }
      if (kDebugMode) log('Fetch profile details error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Validation helpers ----------------
  int? _intOrNull(String s) => int.tryParse(s.trim());

  bool _validPolicy(int freeH, int feePct, int noRefundH) {
    if (freeH < 0 || noRefundH < 0) return false;
    if (feePct < 0 || feePct > 100) return false;
    if (noRefundH >= freeH) return false; // no-refund must be inside free window
    return true;
  }

  // ---------------- Networking: create ----------------
  Future<void> createBusinessProfile({
    required String businessName,
    required String businessAddress,
    required String aboutUs,
    required String capacity,
  }) async {
    isLoading.value = true;
    clearErrors();

    // Gather desired inputs from UI
    final freeH = _intOrNull(freeCancellationHours.value) ?? 24;
    final feePct = _intOrNull(cancellationFeePercentage.value) ?? 0;
    final noRefH = _intOrNull(noRefundHours.value) ?? 0;

    // Enforce tier restrictions BEFORE validating/sending
    final willSendPolicy = canEditPolicy; // Foundation/Momentum can't modify policy
    if (!willSendPolicy) {
      // Show info once so user knows why their changes won't apply
      //_toastUpgradeForPolicy();
    }

    // Validate only if we’re actually going to send policy
    if (willSendPolicy && !_validPolicy(freeH, feePct, noRefH)) {
      AppSnackBar.showError(
        'Invalid cancellation policy. '
            'Make sure 0 ≤ fee ≤ 100 and No-refund hours < Free-cancel hours.',
      );
      isLoading.value = false;
      return;
    }

    try {
      final uiStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
      final uiClose = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

      const allDays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      final closed = allDays.where((d) => !openDays.contains(d)).toList();

      // Build request
      final resp = await ShopApi().createShopWithImage(
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
        // ⬇️ Only include policy fields when user is allowed to edit them
        freeCancellationHours: willSendPolicy ? freeH : null,
        cancellationFeePercentage: willSendPolicy ? feePct : null,
        noRefundHours: willSendPolicy ? noRefH : null,
        token: AuthService.accessToken ?? '',
        // ⬇️ IF ShopApi supports deposit, include it only when allowed:
        // isDepositRequired: canEditDeposit ? isDepositRequired.value : null,
        // depositAmount:     canEditDeposit ? depositAmount.value : null,
      );

      if (resp.isSuccess) {
        profileDetails.value = GetBusinesModel.fromJson(resp.responseData);
        AppSnackBar.showSuccess("Business Profile created successfully!");
        final svc = Get.isRegistered<BusinessOwnerController>()
            ? Get.find<BusinessOwnerController>()
            : null;
        await svc?.refreshGuardsAndServices();
        Get.offNamed('/all-services');
      } else {
        log('Create profile failed: ${resp.statusCode}, error: ${resp.errorMessage}');
        AppSnackBar.showError(
          resp.errorMessage.isNotEmpty ? resp.errorMessage : 'Create failed.',
        );
      }
    } catch (e) {
      log('Create profile error: $e');
      AppSnackBar.showError('Failed to create business profile.');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Networking: update ----------------
  Future<void> updateBusinessProfile({
    required businessName,
    required businessAddress,
    required String aboutUs,
    required String id,
    required String capacity,
    List<String>? openDays,
    List<String>? closeDays,
    String? startAt,
    String? closeAt,
  }) async {
    try {
      isLoading.value = true;

      // --- derive UI times (must be AM/PM) ---
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

      String _normalizeAmPm(String s) =>
          s.replaceAll('.', '').toUpperCase().replaceAll('AM', 'AM').replaceAll('PM', 'PM');
      final normStart = _normalizeAmPm(uiStart);
      final normClose = _normalizeAmPm(uiClose);

      // --- days ---
      const allDays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      final open = (openDays != null && openDays.isNotEmpty) ? openDays : this.openDays.toList();
      final closed = (closeDays != null && closeDays.isNotEmpty)
          ? closeDays
          : allDays.where((d) => !open.contains(d)).toList();

      // --- policy ---
      final freeH = int.tryParse(freeCancellationHours.value.trim()) ?? 24;
      final feePct = int.tryParse(cancellationFeePercentage.value.trim()) ?? 0;
      final noRefH = int.tryParse(noRefundHours.value.trim()) ?? 0;

      final sendPolicy = canEditPolicy;
      if (sendPolicy) {
        if (!_validPolicy(freeH, feePct, noRefH)) {
          AppSnackBar.showError(
            'Invalid cancellation policy. Make sure 0 ≤ fee ≤ 100 and No-refund hours < Free-cancel hours.',
          );
          return;
        }
      }

      // --- NEW: deposit guard + normalize ---
      String? depositToSend;
      //bool? requireDepositToSend;
      if (canEditDeposit) {
        final raw = depositAmount.value.trim(); // kept in controller from the field
        final parsed = double.tryParse(raw) ?? 0.0;
        // if the switch is ON, enforce minimum 1.00
        if (parsed < 1.0) {
          AppSnackBar.showError('Minimum deposit is 1.00');
          return;
        }
        // Always send 2-decimal string to API (even when 0 or switch is off)
        depositToSend = parsed.toStringAsFixed(2);
        //requireDepositToSend = true;
      }
      // If cannot edit deposit on current plan, do not send those fields (server keeps existing)

      final resp = await ShopApi().updateShopWithImage(
        id: id,
        name: businessName,
        address: businessAddress,
        aboutUs: aboutUs,
        capacity: int.tryParse(capacity) ?? 0,
        startAtUi: normStart,
        closeAtUi: normClose,
        closeDays: closed.map((e) => e.toLowerCase()).toList(),
        latitude: lat.value.isEmpty ? null : lat.value,
        longitude: long.value.isEmpty ? null : long.value,
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        documents: documents,
        token: AuthService.accessToken ?? '',

        // ✅ send policy only if allowed
        freeCancellationHours: sendPolicy ? freeH : null,
        cancellationFeePercentage: sendPolicy ? feePct : null,
        noRefundHours: sendPolicy ? noRefH : null,

        // ✅ NEW: send deposit only if allowed
        //isDepositRequired: canEditDeposit ? requireDepositToSend : null,
        depositAmount:     canEditDeposit ? depositToSend       : null,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
        await fetchProfileDetails();
        Get.offNamed('/all-services');
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

  // ---------------- Raw multipart PUT helper (unchanged) ----------------
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

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError(errorResponse);
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError("Failed to update business profile. Please try again.");
    }
  }

  // ---------------- Delete ----------------
  Future<bool> deleteBusinessProfile(String shopId) async {
    isDeleting.value = true;
    try {
      final response = await NetworkCaller().deleteRequest(
        AppUrls.deleteShop(shopId),
        token: AuthService.accessToken,
      );

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

      if (Get.isRegistered<BusinessOwnerController>()) {
        await Get.find<BusinessOwnerController>().refreshGuardsAndServices();
      }
      return true;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.showError('An error occurred while deleting the profile.');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // ---------------- Misc helpers ----------------
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  void clearErrors() => fieldErrors.clear();
  void setFieldError(String field, String message) {
    fieldErrors[field] = message;
    fieldErrors.refresh();
  }

  String _toApiTime(String ui) {
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$', caseSensitive: false).firstMatch(ui);
    if (m == null) return ui;
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
    if (lat == null || lon == null) return null;
    return '$lat,$lon';
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
