// lib/features/business_owner/home/controller/business_owner_controller.dart

import 'dart:convert';
import 'package:fidden/features/business_owner/home/model/business_owner_booking_model.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:fidden/features/business_owner/home/model/revenue_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fidden/features/business_owner/home/model/growth_suggestion_model.dart';
import '../../../../core/commom/widgets/app_snackbar.dart';
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
  final RxList<GrowthSuggestion> growthSuggestions = <GrowthSuggestion>[].obs;

  var allBusinessOwnerBookingOne = OwnerBookingsResponse(next: null, previous: null, results: []).obs;
  final shopMissing = false.obs;
  final shopMissingMessage = ''.obs;

  final isShopVerified = false.obs;
  final verificationMessage = ''.obs;

  void onInit() {
  super.onInit();

  // React only when shop id is known
  ever<int?>(myShopId, (id) {
    if (id != null && id > 0) {
      fetchShopRevenues(shopId: id);
      fetchGrowthSuggestions();
      fetchBusinessOwnerBooking();   // moved here so it runs only when we truly have shopId
    }
  });

  _boot();
}

  /// track in-flight actions to disable buttons per booking
  final RxSet<int> _busyBookingIds = <int>{}.obs;

  bool isBusy(int id) => _busyBookingIds.contains(id);

  void _setBusy(int id, bool v) {
    if (v) {
      _busyBookingIds.add(id);
    } else {
      _busyBookingIds.remove(id);
    }
    _busyBookingIds.refresh();
  }

  /// update one item in the paged list without refetching everything
  void _patchBookingStatusLocally(int bookingId, String newStatus) {
    final current = allBusinessOwnerBookingOne.value;
    final list = [...current.results];
    final idx = list.indexWhere((e) => e.id == bookingId); // <-- assumes `id` exists
    if (idx != -1) {
      final old = list[idx];
      list[idx] = old.copyWith(status: newStatus); // if you don't have copyWith, just: old.status = newStatus;
      allBusinessOwnerBookingOne.value = OwnerBookingsResponse(
        next: current.next,
        previous: current.previous,
        results: list,
        stats: current.stats,
      );
    }
  }

  String _extractServerMessage(dynamic body) {
    try {
      if (body is Map) {
        final v = body['error'] ?? body['detail'] ?? body['message'];
        if (v != null) return v.toString();
      }
      return body?.toString() ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }


  /// POST /payments/bookings/{booking_id}/mark-no-show/
  Future<void> markAsNoShow(int bookingId) async {
    if (isBusy(bookingId)) return;
    _setBusy(bookingId, true);
    try {
      await _ensureAuthReady();

      final res = await NetworkCaller().postRequest(
        AppUrls.markNoShow(bookingId),
        token: AuthService.accessToken,
      );

      if (res.isSuccess) {
        _patchBookingStatusLocally(bookingId, 'no-show');
        AppSnackBar.showSuccess('Booking marked as no-show', title: 'Updated');
      } else {
        AppSnackBar.showError(
          _extractServerMessage(res.responseData),
          title: 'Failed',
        );
      }
    } catch (e) {
      AppSnackBar.showError(e.toString());
    } finally {
      _setBusy(bookingId, false);
    }
  }

  // send a valid Stripe reason
  Future<void> cancelBookingByOwner(int bookingId) async {
    if (isBusy(bookingId)) return;
    _setBusy(bookingId, true);
    try {
      await _ensureAuthReady();

      final res = await NetworkCaller().postRequest(
        AppUrls.cancelBooking(bookingId),
        token: AuthService.accessToken,
        body: const {"reason": "requested_by_customer"}, // <-- important
      );

      if (res.isSuccess) {
        _patchBookingStatusLocally(bookingId, 'cancelled');
        AppSnackBar.showSuccess('Booking has been cancelled', title: 'Cancelled');
      } else {
        AppSnackBar.showError(_extractServerMessage(res.responseData), title: 'Failed');
      }
    } catch (e) {
      AppSnackBar.showError(e.toString());
    } finally {
      _setBusy(bookingId, false);
    }
  }



  Future<void> _ensureAuthReady() async {
  // Wait briefly until AuthService.accessToken is non-empty
  for (var i = 0; i < 100; i++) {                   // ~10s max
    final t = AuthService.accessToken;
    if (t != null && t.isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 100));
  }
  // If still not ready, just return; callers will handle gracefully.
}

Future<void> _boot() async {
  await _ensureAuthReady();          // <-- wait for token
  await _initProfileAndGuards();     // <-- sets myShopId (triggers ever above)
  await fetchAllMyService();         // services do not depend on shopId
  // DO NOT call fetchShopRevenues()/fetchBusinessOwnerBooking() here:
  // 'ever(myShopId, …)' will trigger them exactly once with a non-null id.
}


  Future<void> refreshGuardsAndServices() async {
    await _initProfileAndGuards();
    await fetchAllMyService();
    final id = myShopId.value;
    if (id != null && id > 0) {
      await fetchShopRevenues(shopId: id);
      await fetchGrowthSuggestions();
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

  final isPaging = false.obs;

Future<void> fetchBusinessOwnerBooking({bool reset = true}) async {
  if (reset) isPaging.value = false;
  isLoading.value = reset;                // only show big loader on first page
  try {
    await _ensureAuthReady();

    final id = myShopId.value;
    if (id == null || id <= 0) {
      allBusinessOwnerBookingOne.value = OwnerBookingsResponse(
        next: null, previous: null, results: [],
        stats: OwnerBookingStats(totalBookings: 0, newBookings: 0, cancelled: 0, completed: 0),
      );
      return;
    }

    final res = await NetworkCaller().getRequest(
      AppUrls.ownerBooking(id.toString()),
      token: AuthService.accessToken,
      treat404AsEmpty: true,
      emptyPayload: const {"next": null,"previous": null,"results": [],"stats":{
        "total_bookings":0,"new_bookings":0,"cancelled":0,"completed":0}}
    );

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final page1 = OwnerBookingsResponse.fromJson(
        Map<String, dynamic>.from(res.responseData),
      );
      allBusinessOwnerBookingOne.value = page1;     // first page only
    } else {
      allBusinessOwnerBookingOne.value = OwnerBookingsResponse(
        next: null, previous: null, results: [],
        stats: OwnerBookingStats(totalBookings: 0, newBookings: 0, cancelled: 0, completed: 0),
      );
    }
  } finally {
    isLoading.value = false;
  }
}

/// Call this when you’re near the bottom.
/// Uses the absolute `next` URL returned by the API.
Future<void> fetchMoreBookings() async {
  final nextUrl = allBusinessOwnerBookingOne.value.next;
  if (nextUrl == null || nextUrl.isEmpty) return;
  if (isPaging.value) return;

  isPaging.value = true;
  try {
    final res = await NetworkCaller().getRequest(
      nextUrl,                              // <-- absolute URL
      token: AuthService.accessToken,
      treat404AsEmpty: true,
      emptyPayload: const {"next": null, "previous": null, "results": []}
    );

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final nextPage = OwnerBookingsResponse.fromJson(
        Map<String, dynamic>.from(res.responseData),
      );

      // append new results; keep latest cursor & stats
      final current = allBusinessOwnerBookingOne.value;
      allBusinessOwnerBookingOne.value = OwnerBookingsResponse(
        next: nextPage.next,
        previous: current.previous,
        results: [...current.results, ...nextPage.results],
        stats: nextPage.stats ?? current.stats,
      );
    }
  } finally {
    isPaging.value = false;
  }
}


  Future<void> fetchGrowthSuggestions() async {
    try {
      final id = myShopId.value;
      if (id == null || id <= 0) {
        growthSuggestions.clear();
        return;
      }

      final res = await NetworkCaller().getRequest(
        AppUrls.growthSuggestions(id.toString()),
        token: AuthService.accessToken,
        treat404AsEmpty: true,
        emptyPayload: const [], // API returns an array
      );

      dynamic data = res.responseData;
      if (data is String) {
        try { data = json.decode(data); } catch (_) {}
      }

      if (res.isSuccess && data is List) {
        // keep max 3
        final list = data
            .map((e) => GrowthSuggestion.fromJson(Map<String, dynamic>.from(e)))
            .take(3)
            .toList();
        growthSuggestions.assignAll(list);
      } else {
        growthSuggestions.clear();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[growth] error: $e');
      growthSuggestions.clear();
    }
  }

  IconData iconForSuggestionCategory(String category) {
    switch (category.toLowerCase()) {
      case 'discount':
        return Icons.local_offer;
      case 'operational':
        return Icons.build; // or Icons.handyman
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.lightbulb;
    }
  }




  Future<void> fetchAllMyService() async {
    isLoading.value = true;
    shopMissing.value = false;
    shopMissingMessage.value = '';

    try {
      await _ensureAuthReady(); 
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
      await _ensureAuthReady();                       // <-- NEW

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
