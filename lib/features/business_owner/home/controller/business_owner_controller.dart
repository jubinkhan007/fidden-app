import 'dart:convert';

import 'package:fidden/features/business_owner/home/model/business_owner_booking_model.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';

class BusinessOwnerController extends GetxController {
  final pageController = PageController();
  var isLoading = false.obs;
  var allServiceList = <GetMyServiceModel>[].obs;
  final RxList<GetMyServiceModel> discountedServices =
      <GetMyServiceModel>[].obs;
  var allBusinessOwnerBookingOne = BusinessOwnerBookingModel().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllMyService();
    fetchBusinessOwnerBooking();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Future<void> fetchAllMyService() async {
  //   isLoading.value = true;
  //   try {
  //     final response = await NetworkCaller().getRequest(
  //       AppUrls.getMyService,
  //       token: AuthService.accessToken,
  //     );

  //     if (response.isSuccess) {
  //       if (response.responseData is List) {
  //         final serviceData = List<GetMyServiceModel>.from(
  //           response.responseData.map((x) => GetMyServiceModel.fromJson(x)),
  //         );
  //         allServiceList.value = serviceData;
  //         discountedServices.value = serviceData
  //             .where(
  //               (item) =>
  //                   item.discountPrice != null &&
  //                   double.tryParse(item.discountPrice!)! > 0,
  //             )
  //             .toList();
  //       } else {
  //         throw Exception('Unexpected response data format');
  //       }
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'An error occurred: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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

  /// NEW: flag + message when API says “You must create a shop…”
  final shopMissing = false.obs;
  final shopMissingMessage = ''.obs;

  Future<void> fetchAllMyService() async {
    isLoading.value = true;
    shopMissing.value = false;
    shopMissingMessage.value = '';

    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.getMyService,
        token: AuthService.accessToken,
      );

      // ---- debug: see exactly what came back
      if (kDebugMode) {
        debugPrint('[services] isSuccess=${res.isSuccess}');
        debugPrint('[services] status=${res.statusCode}');
        debugPrint('[services] dataType=${res.responseData.runtimeType}');
        debugPrint('[services] data=${res.responseData}');
      }

      dynamic data = res.responseData;

      // If body came as String, try parse JSON
      if (data is String) {
        try {
          data = json.decode(data);
        } catch (_) {
          // keep as string
        }
      }

      // Success case: list => shop exists
      if (res.isSuccess && data is List) {
        final list = data.map((e) => GetMyServiceModel.fromJson(e)).toList();
        allServiceList.assignAll(list);
        return;
      }

      // If backend sent {detail: "..."} with 200 or non-200
      String? detail;
      if (data is Map && data['detail'] != null) {
        detail = data['detail'].toString();
      } else if (data is String) {
        // sometimes it's plain string
        detail = data;
      }

      // If it's the “create shop” message or a 401/403-ish gate, flip the flag
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

      // Any other non-list or error => treat as empty (optional: toast)
      allServiceList.clear();
    } catch (e) {
      allServiceList.clear();
      if (kDebugMode) debugPrint('[services] error: $e');
      // optional: Get.snackbar('Error', 'Failed to load services');
    } finally {
      isLoading.value = false;
    }
  }

  /// Guard to prevent adding services if shop missing
  bool get canAddService => !shopMissing.value;
}
