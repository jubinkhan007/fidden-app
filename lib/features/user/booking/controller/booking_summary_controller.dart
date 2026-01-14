// booking_summary_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

import '../presentation/paypal_webview_screen.dart';
// import your confirmation screen route or widget

// booking_summary_controller.dart

class ShopPolicy {
  final int freeH;
  final int feePct;
  final int noRefundH;
  const ShopPolicy({
    required this.freeH,
    required this.feePct,
    required this.noRefundH,
  });
}

class BookingSummaryController extends GetxController {
  final isTermsAgreed = false.obs;
  final isPaying = false.obs;

  // NEW: holds the server booking id once we get it from paymentIntent
  final RxInt paymentBookingId = 0.obs;
  final Rxn<ShopPolicy> policy = Rxn<ShopPolicy>();

  void toggleTermsAgreement(bool? v) => isTermsAgreed.value = v ?? false;

  // NEW: Helper to set payment method
  // NEW: Track selected payment method
  final selectedPaymentMethod = 'stripe'.obs;
  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // NEW: Deposit logic
  final RxBool isDepositRequired = false.obs;
  final RxInt defaultDepositPercentage = 0.obs;

  double getDepositAmount(double totalAmount) {
    if (!isDepositRequired.value || defaultDepositPercentage.value <= 0)
      return 0;
    return (totalAmount * defaultDepositPercentage.value) / 100;
  }

  Future<void> processPayment({
    required int slotId, // Legacy
    // Rule-Based Args
    String? startAt,
    int? serviceId,
    int? shopId,
    int? providerId,
    String? timezoneId,

    int? couponId,
    List<int>? addOnIds,
    Map<String, dynamic>? successArgs,
  }) async {
    isPaying.value = true;
    try {
      // 1. Create Booking First
      // Pass null for providerId if it wasn't selected (Any Provider)
      // The backend handles assignment if provider is missing but shop/service is there
      final bookingId = await _createBooking(
        startAt: startAt,
        serviceId: serviceId,
        shopId: shopId,
        providerId: providerId,
        timezoneId: timezoneId,
        note: successArgs?['note'],
      );

      if (bookingId == null) {
        return; // Error shown in helper
      }

      paymentBookingId.value = bookingId;

      // 2. Process Payment with Booking ID
      if (selectedPaymentMethod.value == 'paypal') {
        await _payWithPayPal(
          bookingId: bookingId,
          couponId: couponId,
          addOnIds: addOnIds,
          successArgs: successArgs,
        );
      } else {
        await _payWithStripe(
          bookingId: bookingId,
          couponId: couponId,
          addOnIds: addOnIds,
          successArgs: successArgs,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    } finally {
      isPaying.value = false;
    }
  }

  // NEW: Create booking via Rule-Based API
  Future<int?> _createBooking({
    required String? startAt,
    required int? serviceId,
    required int? shopId,
    required int? providerId,
    String? timezoneId,
    String? note,
  }) async {
    if (startAt == null || serviceId == null || shopId == null) {
      Get.snackbar(
        'Error',
        'Missing booking details (start time, service, or shop)',
      );
      return null;
    }

    final body = {
      'shop_id': shopId,
      'service_id': serviceId,
      'start_at': startAt,
      // 'timezone_id': timezoneId, // Optional validation
      if (providerId != null) 'provider_id': providerId,
      if (note != null) 'note': note,
    };

    final res = await NetworkCaller().postRequest(
      AppUrls.bookings,
      token: AuthService.accessToken,
      body: body,
    );

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final rawBookingId = res.responseData['booking_id'];
      // The backend expects slot_id for payment-intent endpoint (legacy behavior or specific to rule-based)
      final rawSlotId = res.responseData['slot_id'];

      final id = (rawSlotId is int) ? rawSlotId : int.tryParse('$rawSlotId');

      return id;
    } else {
      // Handle Specific Errors
      if (res.statusCode == 409) {
        Get.snackbar(
          'Slot Unavailable',
          'This slot is no longer available. Please choose another time.',
        );
      } else if (res.statusCode == 400 &&
          res.errorMessage?.contains('INVALID_TIME') == true) {
        Get.snackbar(
          'Invalid Time',
          'That time isn’t available due to daylight savings time. Please pick another time.',
        );
      } else {
        Get.snackbar(
          'Booking Error',
          res.errorMessage ?? 'Failed to create booking.',
        );
      }
      return null;
    }
  }

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
      final freeH = (m['free_cancellation_hours'] as num?)?.toInt() ?? 24;
      final feePct = (m['cancellation_fee_percentage'] as num?)?.toInt() ?? 0;
      final noRefH = (m['no_refund_hours'] as num?)?.toInt() ?? 0;

      policy.value = ShopPolicy(
        freeH: freeH,
        feePct: feePct,
        noRefundH: noRefH,
      );

      // NEW: Deposit settings
      isDepositRequired.value =
          m['is_deposit_required'] == true ||
          m['is_deposit_required'] == 'true';
      defaultDepositPercentage.value =
          (m['default_deposit_percentage'] as num?)?.toInt() ?? 0;
    } catch (_) {
      // swallow or log
    }
  }

  // --- STRIPE LOGIC (Updated to use bookingId) ---
  Future<void> _payWithStripe({
    required int bookingId,
    int? couponId,
    List<int>? addOnIds,
    Map<String, dynamic>? successArgs,
  }) async {
    if (bookingId == 0) {
      Get.snackbar('Error', 'Invalid booking ID');
      return;
    }
    // isPaying.value = true; // Set in processPayment

    try {
      final body = <String, dynamic>{};
      if (couponId != null && couponId > 0) body['coupon_id'] = couponId;
      if (addOnIds != null && addOnIds.isNotEmpty)
        body['add_on_ids'] = addOnIds;

      // NEW: Send deposit info if applicable
      if (isDepositRequired.value && defaultDepositPercentage.value > 0) {
        body['is_deposit'] = true;
        // Optional: you can send the percentage or let backend look it up.
        // Sending 'deposit_percentage' might be safer if backend logic varies.
        body['deposit_percentage'] = defaultDepositPercentage.value;
      }

      final res = await NetworkCaller().postRequest(
        AppUrls.paymentIntent(bookingId),
        token: AuthService.accessToken,
        body: body,
      );

      if (!res.isSuccess || res.responseData is! Map<String, dynamic>) {
        Get.snackbar('Error', res.errorMessage ?? 'Failed to start payment');
        return;
      }

      final data = res.responseData as Map<String, dynamic>;
      // bookingId is already passed in argument, no need to re-read or shadow
      final clientSecret = data['client_secret'].toString();
      final ephemeralKey = data['ephemeral_key'].toString();
      final customerId = data['customer_id'].toString();

      if (bookingId != null) paymentBookingId.value = bookingId;

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
      // ---------------------------------------------------
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

  // --- NEW PAYPAL LOGIC ---
  Future<void> _payWithPayPal({
    required int bookingId,
    int? couponId,
    List<int>? addOnIds,
    Map<String, dynamic>? successArgs,
  }) async {
    isPaying.value = true;
    try {
      final body = <String, dynamic>{};
      if (couponId != null && couponId > 0) body['coupon_id'] = couponId;
      if (addOnIds != null && addOnIds.isNotEmpty)
        body['add_on_ids'] = addOnIds;

      // NEW: Send deposit info if applicable
      if (isDepositRequired.value && defaultDepositPercentage.value > 0) {
        body['is_deposit'] = true;
        body['deposit_percentage'] = defaultDepositPercentage.value;
      }

      // 1. Create Order
      final res = await NetworkCaller().postRequest(
        AppUrls.createPayPalOrder(bookingId.toString()),
        token: AuthService.accessToken,
        body: body,
      );

      if (!res.isSuccess) {
        Get.snackbar('Error', res.errorMessage ?? 'PayPal Init Failed');
        isPaying.value = false;
        return;
      }

      final data = res.responseData;
      final String approveUrl = data['approve_url'];
      final String orderId = data['order_id'];
      // final int bookingId = data['booking_id']; // Passed in argument

      paymentBookingId.value = bookingId; // Store for cancel logic

      // 2. Open WebView
      final bool? approved = await Get.to(
        () => PayPalWebViewScreen(url: approveUrl),
      );

      if (approved == true) {
        // 3. Capture Order
        await _capturePayPalOrder(orderId, bookingId, successArgs);
      } else {
        Get.snackbar('Cancelled', 'PayPal payment cancelled');
        isPaying.value = false;
      }
    } catch (e) {
      isPaying.value = false;
      Get.snackbar('Error', 'PayPal Error: $e');
    }
  }

  Future<void> _capturePayPalOrder(
    String orderId,
    int bookingId,
    Map<String, dynamic>? successArgs,
  ) async {
    print(
      '🔍 DEBUG: Starting PayPal capture for order: $orderId, booking: $bookingId',
    );
    try {
      final res = await NetworkCaller().postRequest(
        AppUrls.capturePayPalOrder,
        token: AuthService.accessToken,
        body: {'order_id': orderId},
      );

      print(
        '🔍 DEBUG: Capture response - isSuccess: ${res.isSuccess}, statusCode: ${res.statusCode}',
      );

      if (res.isSuccess) {
        final mergedArgs = <String, dynamic>{
          if (successArgs != null) ...successArgs!,
          'bookingId': bookingId,
        };
        print(
          '🔍 DEBUG: Navigating to booking-confirmation with args: $mergedArgs',
        );

        // Navigate to confirmation screen
        Get.offAllNamed('/booking-confirmation', arguments: mergedArgs);
      } else {
        print('🔍 DEBUG: Capture failed - ${res.errorMessage}');
        Get.snackbar(
          'Error',
          res.errorMessage ?? 'Payment Verification Failed',
        );
      }
    } catch (e) {
      print('🔍 DEBUG: Capture exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred during payment verification: $e',
      );
    } finally {
      isPaying.value = false;
      print('🔍 DEBUG: isPaying set to false');
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
