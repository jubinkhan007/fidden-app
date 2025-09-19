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
      final url = _nextActiveUrl ?? AppUrls.userBookings(_email!);

      final resp = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final parsed = BookingListResponse.fromJson(resp.responseData);
        _nextActiveUrl = parsed.next;

        final chunk = parsed.results.where((b) => b.status == 'active');
        if (reset) active.clear();
        active.addAll(chunk);
      }
    } finally {
      pagingActive.value = false;
    }
  }

  Future<void> _fetchHistory({bool reset = false}) async {
    pagingHistory.value = true;
    try {
      final url = _nextHistoryUrl ?? AppUrls.userBookings(_email!);

      final resp = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final parsed = BookingListResponse.fromJson(resp.responseData);
        _nextHistoryUrl = parsed.next;

        final chunk = parsed.results.where((b) => b.status != 'active');
        if (reset) {
          history.clear();
          cancelled.clear();
        }
        history.addAll(chunk.where((b) => b.status == 'completed'));
        cancelled.addAll(chunk.where((b) => b.status == 'cancelled'));
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
  // Show a confirmation dialog
  Get.defaultDialog(
    title: "Cancel Booking",
    middleText: "Are you sure you want to cancel this booking?",
    textConfirm: "Yes, Cancel",
    textCancel: "No",
    confirmTextColor: Colors.white,
    onConfirm: () async {
      Get.back(); // Close the confirmation dialog

      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      ResponseData? response;
      try {
        // Await the network call and store the response
        response = await NetworkCaller().postRequest(
          AppUrls.cancelBooking(booking.id),
          token: AuthService.accessToken,
        );
      } catch (e) {
        // In case of an exception, ensure the response is null
        response = null;
      } finally {
        // This is the crucial part:
        // ALWAYS close the loading dialog before proceeding.
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
      }

      // Now, handle the result AFTER the dialog is closed
      if (response != null && response.isSuccess) {
        AppSnackBar.showSuccess(
            "Booking canceled successfully and refund initiated.");
        // Move the booking from the active list to the cancelled list
        active.removeWhere((b) => b.id == booking.id);
        cancelled.insert(0, booking.copyWith(status: 'cancelled'));
      } else {
        AppSnackBar.showError(
            response?.errorMessage ?? "Failed to cancel booking.");
      }
    },
  );
}
  
}

// 