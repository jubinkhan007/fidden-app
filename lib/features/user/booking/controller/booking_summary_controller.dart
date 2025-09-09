import 'dart:developer';

import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:get/get.dart';

class BookingSummaryController extends GetxController {
  final RxBool isTermsAgreed = false.obs;

  void toggleTermsAgreement(bool? value) {
    isTermsAgreed.value = value ?? false;
  }

  Future<void> cancelBooking(int bookingId) async {
    // Safety check: Don't proceed if bookingId is invalid (e.g., 0 or null)
    if (bookingId == 0) {
      log('Cannot cancel booking: Invalid bookingId provided.');
      return;
    }

    log(
      'Cancelling booking with ID: $bookingId at URL: ${AppUrls.cancelSlotBooking(bookingId)}',
    );
    try {
      await NetworkCaller().postRequest(
        AppUrls.cancelSlotBooking(bookingId),
        body: {}, // The body is empty as per the endpoint's requirement
        token: AuthService
            .accessToken, // <-- THIS LINE FIXES THE AUTHENTICATION ISSUE
      );
    } catch (e) {
      log('Failed to cancel slot booking for bookingId: $bookingId. Error: $e');
    }
  }
}
