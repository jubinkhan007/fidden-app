// lib/features/user/booking/controller/booking_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/models/response_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/user_booking_model.dart';

class BookingController extends GetxController {
  // Tab
  var isActiveBooking = true.obs;
  void toggleTab(bool v) => isActiveBooking.value = v;

  // Data
  final active = <BookingItem>[].obs;
  final history = <BookingItem>[].obs;
  final cancelled = <BookingItem>[].obs; // New list for cancelled bookings

  // Pagination cursors
  String? _nextActiveUrl;
  String? _nextHistoryUrl;

  // Loading flags
  var initialLoading = false.obs;
  var pagingActive = false.obs;
  var pagingHistory = false.obs;

  // Email cache (fetched from /accounts/profile/)
  String? _email;

  //review
  var rating = 0.0.obs;
  var reviewText = ''.obs;
  final reviewedBookingIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    active.clear();
    history.clear();
    cancelled.clear(); // Clear cancelled list on refresh
    _nextActiveUrl = null;
    _nextHistoryUrl = null;

    initialLoading.value = true;
    try {
      await _ensureEmail(); // <- make sure we have the email before hitting bookings
      await Future.wait([
        _fetchActive(reset: true),
        _fetchHistory(reset: true),
      ]);
    } finally {
      initialLoading.value = false;
    }
  }

  Future<void> loadMoreActive() async {
    if (pagingActive.value || _nextActiveUrl == null) return;
    await _fetchActive();
  }

  Future<void> loadMoreHistory() async {
    if (pagingHistory.value || _nextHistoryUrl == null) return;
    await _fetchHistory();
  }

  Future<void> _fetchActive({bool reset = false}) async {
    pagingActive.value = true;
    try {
      // First page should include active items
      final firstPage = AppUrls.userBookings(_email!, excludeActive: false);
      final url = _nextActiveUrl ?? firstPage;

      final resp = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final parsed = BookingListResponse.fromJson(
          Map<String, dynamic>.from(resp.responseData),
        );

        _nextActiveUrl = parsed.next;

        if (reset) active.clear();
        // defensive: keep only active
        active.addAll(parsed.results.where((b) => b.status == 'active'));
      } else {
        // your existing error handling (optional)
      }
    } finally {
      pagingActive.value = false;
    }
  }

  final historyAll = <BookingItem>[].obs; // non-active, API order

  Future<void> _fetchHistory({bool reset = false}) async {
    pagingHistory.value = true;
    try {
      // First page must exclude active
      final firstPage = AppUrls.userBookings(_email!, excludeActive: true);
      final url = _nextHistoryUrl ?? firstPage;

      final resp = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final parsed = BookingListResponse.fromJson(
          Map<String, dynamic>.from(resp.responseData),
        );

        _nextHistoryUrl = parsed.next;

        if (reset) {
          historyAll.clear();
          history.clear();
          cancelled.clear();
        }

        // server already excludes active; keep a defensive filter anyway
        for (final b in parsed.results.where((b) => b.status != 'active')) {
          historyAll.add(b);                       // preserve API order
          if (b.status == 'completed') history.add(b);
          if (b.status == 'cancelled') cancelled.add(b);
        }
      } else {
        // your existing error handling (optional)
      }
    } finally {
      pagingHistory.value = false;
    }
  }

  Future<void> submitReview(BookingItem booking) async {
    final body = {
      "shop": booking.shop,
      "service":
          booking.serviceId,
          "booking_id":booking.id, // Assuming booking.id is the service id as per the API doc
      "rating": rating.value.toInt(),
      "review": reviewText.value,
      "review_img": null,
    };

    final response = await NetworkCaller().postRequest(
      AppUrls.createReview,
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      AppSnackBar.showSuccess('Review submitted successfully!');
      reviewedBookingIds.add(booking.id);
    } else {
      AppSnackBar.showError(response.errorMessage ?? 'Failed to submit review.1');
    }
  }

  // --- Helpers ---------------------------------------------------------------

  Future<void> _ensureEmail() async {
    if ((_email ?? '').isNotEmpty) return;

    final resp = await NetworkCaller().getRequest(
      AppUrls.getMyProfile,
      token: AuthService.accessToken,
    );

    if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
      final m = resp.responseData as Map<String, dynamic>;
      // Try common shapes safely
      _email = (m['email'] ??
              (m['data'] is Map ? (m['data']['email']) : null) ??
              (m['user'] is Map ? (m['user']['email']) : null))
          ?.toString();

      // Fallback if API doesn’t send email for some reason
      _email ??= "protim@example.com";
    } else {
      _email = "protim@example.com";
    }
  }

  Future<void> cancelBooking(BookingItem booking) async {
    // --- No changes needed in the dialog or network call logic ---
    Get.defaultDialog(
      title: "Cancel Booking",
      middleText: "Are you sure you want to cancel this booking?",
      textConfirm: "Yes, Cancel",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        ResponseData? response;
        try {
          response = await NetworkCaller().postRequest(
            AppUrls.cancelBooking(booking.id),
            token: AuthService.accessToken,
          );
        } catch (e) {
          response = null;
        } finally {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
        }

        if (response != null && response.isSuccess) {
          AppSnackBar.showSuccess(
              "Booking canceled successfully and refund initiated.");

          // ✅ THE FIX: Update all relevant lists for a seamless UI update.

          // 1. Create the new "cancelled" version of the booking.
          final cancelledBooking = booking.copyWith(status: 'cancelled');

          // 2. Remove the booking from the 'active' list.
          active.removeWhere((b) => b.id == booking.id);

          // 3. Add it to the top of the dedicated 'cancelled' list.
          cancelled.insert(0, cancelledBooking);

          // 4. ✨ CRUCIAL STEP: Add it to the top of the 'historyAll' list,
          //    which controls the UI's display order.
          historyAll.insert(0, cancelledBooking);

        } else {
          AppSnackBar.showError(
              response?.errorMessage ?? "Failed to cancel booking.");
        }
      },
    );
  }
  
}

// 