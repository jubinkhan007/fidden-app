// booking_summary_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
// import your confirmation screen route or widget

// booking_summary_controller.dart

class ShopPolicy {
  final int freeH;
  final int feePct;
  final int noRefundH;
  const ShopPolicy({required this.freeH, required this.feePct, required this.noRefundH});
}


class BookingSummaryController extends GetxController {
  final isTermsAgreed = false.obs;
  final isPaying = false.obs;

  // NEW: holds the server booking id once we get it from paymentIntent
  final RxInt paymentBookingId = 0.obs;
  final Rxn<ShopPolicy> policy = Rxn<ShopPolicy>();

  void toggleTermsAgreement(bool? v) => isTermsAgreed.value = v ?? false;


  Future<void> fetchPolicy(int shopId) async {
    if (shopId <= 0) return;
    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.shopDetails(shopId.toString()),
        token: AuthService.accessToken,
      );
      if (!res.isSuccess || res.responseData is! Map<String, dynamic>) return;

      final m = res.responseData as Map<String, dynamic>;

      // keys must be present in your ShopDetailSerializer (backend):
      // free_cancellation_hours, cancellation_fee_percentage, no_refund_hours
      final freeH   = (m['free_cancellation_hours'] as num?)?.toInt() ?? 24;
      final feePct  = (m['cancellation_fee_percentage'] as num?)?.toInt() ?? 0;
      final noRefH  = (m['no_refund_hours'] as num?)?.toInt() ?? 0;

      policy.value = ShopPolicy(freeH: freeH, feePct: feePct, noRefundH: noRefH);
    } catch (_) {
      // swallow or log
    }
  }

  Future<void> payForBooking({
    required int slotId,
    int? couponId,                    // <— NEW
    Map<String, dynamic>? successArgs,
  }) async {
    if (slotId == 0) {
      Get.snackbar('Error', 'Missing booking id');
      return;
    }

    isPaying.value = true;
    try {
      final body = <String, dynamic>{};
      if (couponId != null && couponId > 0) body['coupon_id'] = couponId; // only send if chosen

      final res = await NetworkCaller().postRequest(
        AppUrls.paymentIntent(slotId),
        token: AuthService.accessToken,
        body: body,
      );

      if (!res.isSuccess || res.responseData is! Map<String, dynamic>) {
        Get.snackbar('Error', res.errorMessage ?? 'Failed to start payment');
        return;
      }

      final data = res.responseData as Map<String, dynamic>;
      final bookingId = data['booking_id'] as int?;
      final clientSecret = data['client_secret'] .toString();
      final ephemeralKey = data['ephemeral_key'] .toString();
      final customerId = data['customer_id'] .toString();

      // Save the REAL booking id for later (cancel/back)
      if (bookingId != null) {
        paymentBookingId.value = bookingId;
      }

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

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Fidden',
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final mergedArgs = <String, dynamic>{
        if (successArgs != null) ...successArgs!,
        if (bookingId != null) 'bookingId': bookingId,
      };

      Get.offAllNamed('/booking-confirmation', arguments: mergedArgs);
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        Get.snackbar('Payment Error', e.error.message ?? 'Payment failed');
      }
    } catch (e) {
      Get.snackbar('Payment Failed', '$e');
    } finally {
      isPaying.value = false;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    if (bookingId <= 0) return;
    try {
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
