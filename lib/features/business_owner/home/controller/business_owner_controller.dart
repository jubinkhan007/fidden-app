import 'dart:convert';
import 'package:fidden/features/business_owner/home/model/business_owner_booking_model.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../profile/controller/busines_owner_profile_controller.dart';

class BusinessOwnerController extends GetxController {
  final pageController = PageController();
  var isLoading = false.obs;
  var allServiceList = <GetMyServiceModel>[].obs;
  final RxList<GetMyServiceModel> discountedServices =
      <GetMyServiceModel>[].obs;
  var allBusinessOwnerBookingOne = BusinessOwnerBookingModel().obs;
  final shopMissing = false.obs;
  final shopMissingMessage = ''.obs;

  final isShopVerified = false.obs;
  final verificationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Chain the calls to ensure correct order
    _initProfileAndGuards().then((_) {
      fetchAllMyService();
      fetchBusinessOwnerBooking();
    });
  }

  Future<void> refreshGuardsAndServices() async {
    await _initProfileAndGuards();
    await fetchAllMyService();
  }

  Future<void> _initProfileAndGuards() async {
    try {
      final profileController = Get.find<BusinessOwnerProfileController>();
      await profileController.fetchProfileDetails();

      final data = profileController.profileDetails.value.data;

      if (data == null) {
        // no shop
        shopMissing.value = true;
        shopMissingMessage.value =
            'You must create a shop before adding services.';
        isShopVerified.value = false;
        verificationMessage.value = '';
        return;
      }

      // ✅ Profile exists → clear the “missing” flag
      shopMissing.value = false;
      shopMissingMessage.value = '';

      // If backend hasn’t set the flag yet, you can decide how strict to be:
      // strict:
      // final verified = (data.isVarified == true);
      // permissive (treat null as verified so owners can add services):
      final verified = (data.isVarified != false);

      isShopVerified.value = verified;
      verificationMessage.value = verified
          ? ''
          : 'Your shop is pending verification. Please complete verification to add services.';
    } catch (e) {
      debugPrint("Error initializing guards: $e");
      // Be conservative, but don’t hard-lock the user forever
      shopMissing.value = false; // don’t claim “no profile” on transient error
      shopMissingMessage.value = '';
      isShopVerified.value = true; // or false, depending on your policy
      verificationMessage.value = '';
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchBusinessOwnerBooking() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.ownerBooking,
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        allBusinessOwnerBookingOne.value = BusinessOwnerBookingModel.fromJson(
          response.responseData,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllMyService() async {
    isLoading.value = true;
    shopMissing.value = false;
    shopMissingMessage.value = '';

    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.getMyService,
        token: AuthService.accessToken,
      );

      if (kDebugMode) {
        debugPrint('[services] isSuccess=${res.isSuccess}');
        debugPrint('[services] status=${res.statusCode}');
        debugPrint('[services] dataType=${res.responseData.runtimeType}');
        debugPrint('[services] data=${res.responseData}');
      }

      dynamic data = res.responseData;

      if (data is String) {
        try {
          data = json.decode(data);
        } catch (_) {
          // keep as string
        }
      }

      if (res.isSuccess && data is List) {
        final list = data.map((e) => GetMyServiceModel.fromJson(e)).toList();
        allServiceList.assignAll(list);
        return;
      }

      String? detail;
      if (data is Map && data['detail'] != null) {
        detail = data['detail'].toString();
      } else if (data is String) {
        detail = data;
      }

      final lowerDetail = detail?.toLowerCase() ?? '';
      final isForbidden = (res.statusCode == 401 || res.statusCode == 403);
      if (lowerDetail.contains('create a shop') || isForbidden) {
        shopMissing.value = true;
        shopMissingMessage.value = detail?.isNotEmpty == true
            ? detail!
            : 'You must create a shop before accessing services.';
        allServiceList.clear();
        return;
      }

      allServiceList.clear();
    } catch (e) {
      allServiceList.clear();
      if (kDebugMode) debugPrint('[services] error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get canAddService => !shopMissing.value && isShopVerified.value;
}
