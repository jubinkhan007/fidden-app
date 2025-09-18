import 'dart:convert';
import 'package:fidden/features/business_owner/home/model/business_owner_booking_model.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:fidden/features/business_owner/home/model/revenue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../profile/controller/busines_owner_profile_controller.dart';

final RxnInt myShopId = RxnInt();
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

class BusinessOwnerController extends GetxController {
  final pageController = PageController();
  var isLoading = false.obs;
  var allServiceList = <GetMyServiceModel>[].obs;
  final RxList<GetMyServiceModel> discountedServices =
      <GetMyServiceModel>[].obs;
  var allBusinessOwnerBookingOne = OwnerBookingsResponse(next: null, previous: null, results: []).obs;
  final shopMissing = false.obs;
  final shopMissingMessage = ''.obs;

  final isShopVerified = false.obs;
  final verificationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Fetch whenever myShopId becomes available
    ever<int?>(myShopId, (id) {
      if (id != null && id > 0) {
        debugPrint('[revenue] myShopId updated -> $id, fetching…');
        fetchShopRevenues(shopId: id);
      }
    });

    // Ensure we fetch after guards resolve the shop id
    _initProfileAndGuards().then((_) async {
      final id = myShopId.value;
      if (id != null && id > 0) {
        await fetchShopRevenues(shopId: id);
      }
      await fetchAllMyService();
      await fetchBusinessOwnerBooking();
    });
  }

  Future<void> refreshGuardsAndServices() async {
    await _initProfileAndGuards();
    await fetchAllMyService();
    final id = myShopId.value;
    if (id != null && id > 0) {
      await fetchShopRevenues(shopId: id);
    }
  }

  Future<void> _initProfileAndGuards() async {
    try {
      final profileController = Get.find<BusinessOwnerProfileController>();
      await profileController.fetchProfileDetails();

      final data = profileController.profileDetails.value.data;

      if (data == null) {
        shopMissing.value = true;
        shopMissingMessage.value =
            'You must create a shop before adding services.';
        isShopVerified.value = false;
        verificationMessage.value = '';
        myShopId.value = null; // <- no shop
        return;
      }

      // capture shop id (adapt if your field name differs)
      // If your profile data nests shop info, change `data.id` accordingly.
      myShopId.value = _asInt(data.id);

      shopMissing.value = false;
      shopMissingMessage.value = '';

      // treat null as verified; set strict if you prefer
      final verified = (data.isVarified != false);
      isShopVerified.value = verified;
      verificationMessage.value = verified
          ? ''
          : 'Your shop is pending verification. Please complete verification to add services.';
    } catch (e) {
      debugPrint("Error initializing guards: $e");
      shopMissing.value = false;
      shopMissingMessage.value = '';
      isShopVerified.value = true;
      verificationMessage.value = '';
      myShopId.value = myShopId.value; // keep whatever we had
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
    final id = myShopId.value;
    if (id == null || id <= 0) {
      allBusinessOwnerBookingOne.value =
          OwnerBookingsResponse(next: null, previous: null, results: []);
      return;
    }

    final response = await NetworkCaller().getRequest(
      AppUrls.ownerBooking(id.toString()), // <-- /payments/bookings/?shop_id={id}
      token: AuthService.accessToken,
      treat404AsEmpty: true,
  emptyPayload: const {"next": null, "previous": null, "results": []},
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      allBusinessOwnerBookingOne.value =
          OwnerBookingsResponse.fromJson(response.responseData);
    } else {
      allBusinessOwnerBookingOne.value =
          OwnerBookingsResponse(next: null, previous: null, results: []);
    }
  } catch (e) {
    Get.snackbar('Error', 'An error occurred: $e');
    allBusinessOwnerBookingOne.value =
        OwnerBookingsResponse(next: null, previous: null, results: []);
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
        treat404AsEmpty: true,
  emptyPayload: const [], 
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

  // NEW: revenue state
  final totalRevenue = 0.0.obs;
  final revenue7d = <RevenuePoint>[].obs;
  final isRevenueLoading = false.obs;

  // Optional: formatted string for the card
  final _currency = NumberFormat.simpleCurrency(); // uses device locale
  String get totalRevenueFormatted => _currency.format(totalRevenue.value);

  // Call this when you know the shop id (owner always has one)
  Future<void> fetchShopRevenues({required int shopId, int day = 7}) async {
    debugPrint("inside fetchShopRevenues");
    try {
      isRevenueLoading.value = true;

      final res = await NetworkCaller().getRequest(
        AppUrls.shopRevenues(shopId, day: day),
        token: AuthService.accessToken,
        treat404AsEmpty: true,
  emptyPayload: const {"total": 0.0, "points": []},
      );

      if (res.isSuccess && res.statusCode == 200) {
        final map = (res.responseData is Map)
            ? Map<String, dynamic>.from(res.responseData as Map)
            : json.decode(res.responseData.toString()) as Map<String, dynamic>;

        final parsed = RevenueResponse.fromJson(map);
        totalRevenue.value = parsed.totalRevenue;

        final pts = [...parsed.points]..sort((a, b) => a.ts.compareTo(b.ts));
        revenue7d.assignAll(pts);
        debugPrint(
          '[revenue] points=${revenue7d.length} total=${totalRevenue.value}',
        );
        debugPrint(
          '[revenue] ${pts.map((p) => '${DateFormat('EEE').format(p.ts)}=${p.revenue}').join(', ')}',
        );
      } else {
        // keep old values; optionally log
        if (kDebugMode) {
          debugPrint(
            '[revenue] status=${res.statusCode} isSuccess=${res.isSuccess}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[revenue] error: $e');
    } finally {
      isRevenueLoading.value = false;
    }
  }

  // Ensure we load it on startup (owner view)
  @override
  void onReady() {
    super.onReady();
    final id = myShopId.value;
    if (id != null && id > 0) {
      fetchShopRevenues(shopId: id);
    }
  }
}
