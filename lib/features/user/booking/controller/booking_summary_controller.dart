// booking_summary_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
// import your confirmation screen route or widget

class BookingSummaryController extends GetxController {
  final isTermsAgreed = false.obs;
  final isPaying = false.obs;

  void toggleTermsAgreement(bool? v) => isTermsAgreed.value = v ?? false;

  // In lib/features/user/booking/controller/booking_summary_controller.dart

  Future<void> payForBooking({
    required int slotId,
    Map<String, dynamic>? successArgs, // <-- This is preserved
  }) async {
    if (slotId == 0) {
      Get.snackbar('Error', 'Missing booking id');
      return;
    }

    isPaying.value = true;
    try {
      // 1. Ask backend for all payment secrets
      final res = await NetworkCaller().postRequest(
        AppUrls.paymentIntent(slotId),
        token: AuthService.accessToken,
        body: const {},
      );

      if (!res.isSuccess || res.responseData is! Map<String, dynamic>) {
        Get.snackbar('Error', res.errorMessage ?? 'Failed to start payment');
        return;
      }

      final data = res.responseData as Map<String, dynamic>;

      // --- ⬇️ MODIFIED BLOCK ⬇️ ---
      // Extract all three required keys now
      final bookingId = data['booking_id'] as int?;
      final clientSecret = data['client_secret'] as String?;
      final ephemeralKey = data['ephemeral_key'] as String?;
      final customerId = data['customer_id'] as String?;

      // Add robust checks for all keys
      if (clientSecret == null || clientSecret.isEmpty) {
        Get.snackbar('Error', 'Missing client_secret from server.');
        return;
      }
      if (ephemeralKey == null || ephemeralKey.isEmpty) {
        Get.snackbar('Error', 'Missing ephemeral_key from server.');
        return;
      }
      if (customerId == null || customerId.isEmpty) {
        Get.snackbar('Error', 'Missing customer_id from server.');
        return;
      }
      // --- ⬆️ END OF MODIFIED BLOCK ⬆️ ---

      // 2. Init PaymentSheet with customer information
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fidden',
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
          // --- ⬇️ ADD CUSTOMER INFO HERE ⬇️ ---
          // This is what enables the "Save Card" feature
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final mergedArgs = <String, dynamic>{
  if (successArgs != null) ...successArgs!,
  if (bookingId != null) 'bookingId': bookingId, // ← ensure server ID wins
};

      // 3. Success navigation is preserved exactly as you had it
      Get.offAllNamed('/booking-confirmation', arguments: mergedArgs ?? {});
    } on StripeException catch (e) {
      // Your existing Stripe error handling is preserved
      if (e.error.code != FailureCode.Canceled) {
        Get.snackbar('Payment Error', e.error.message ?? 'Payment failed');
      }
    } catch (e) {
      // Your existing generic error handling is preserved
      Get.snackbar('Payment Failed', '$e');
    } finally {
      isPaying.value = false;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    if (bookingId <= 0) return; // nothing to cancel
    try {
      // Adjust the endpoint to match your backend.
      // Example patterns:
      //   POST  /api/users/bookings/{id}/cancel/
      //   or    DELETE /api/users/bookings/{id}/
      final res = await NetworkCaller().postRequest(
        AppUrls.cancelSlotBooking(bookingId),
        token: AuthService.accessToken,
        body: const {},
      );

      if (!res.isSuccess) {
        debugPrint('[cancelBooking] ${res.errorMessage}');
      }
    } catch (e) {
      debugPrint('[cancelBooking] error: $e');
    }
  }
}
