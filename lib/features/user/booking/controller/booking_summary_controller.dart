import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

import '../presentation/paypal_webview_screen.dart';
import 'package:fidden/features/user/design_requests/services/client_design_request_service.dart';

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

  // NEW: Design Request Link
  final designRequestData = <String, dynamic>{}.obs;

  Future<void> submitDesignRequest(int shopId, int bookingId) async {
    final desc = designRequestData['description'] as String?;
    if (desc == null || desc.trim().isEmpty) return;
    try {
      // Directly instantiate service (not registered with GetX)
      final service = ClientDesignRequestService();

      // Get placement and size with defaults if not provided (backend requires these)
      final placement = designRequestData['placement'] as String?;
      final size = designRequestData['size'] as String?;
      final niche = designRequestData['serviceNiche'] as String?;

      final request = await service.createDesignRequest(
        shopId: shopId,
        description: desc,
        // Don't pass bookingId - booking may not be committed yet
        // The design request can be linked manually by shop owner
        bookingId: null,
        placement: placement?.isNotEmpty == true ? placement : 'Other',
        sizeApprox: size?.isNotEmpty == true ? size : 'Custom Style',
        serviceNiche: niche, // Pass niche for filtering on dashboards
      );

      final image = designRequestData['image'];
      if (image != null && image is File) {
        try {
          await service.uploadDesignImage(request.id, image);
        } catch (e) {
          print('Failed to upload design request image: $e');
        }
      }
      print('✅ Design request submitted successfully: ${request.id}');
    } catch (e) {
      print("Failed to auto-submit design request: $e");
    }
  }

  Future<void> processPayment({
    required int slotId,
    required int shopId, // NEW
    int? couponId,
    List<int>? addOnIds,
    Map<String, dynamic>? successArgs,
  }) async {
    if (selectedPaymentMethod.value == 'paypal') {
      await _payWithPayPal(
        slotId: slotId,
        shopId: shopId,
        couponId: couponId,
        addOnIds: addOnIds,
        successArgs: successArgs,
      );
    } else {
      await _payWithStripe(
        slotId: slotId,
        shopId: shopId,
        couponId: couponId,
        addOnIds: addOnIds,
        successArgs: successArgs,
      );
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

  // --- STRIPE LOGIC (Your existing payForBooking logic moved here) ---
  Future<void> _payWithStripe({
    required int slotId,
    required int shopId,
    int? couponId,
    List<int>? addOnIds,
    Map<String, dynamic>? successArgs,
  }) async {
    if (slotId == 0) {
      Get.snackbar('Error', 'Missing booking id');
      return;
    }
    isPaying.value = true;

    try {
      // ... [PASTE YOUR ORIGINAL payForBooking LOGIC HERE] ...
      // Make sure to use 'AppUrls.paymentIntent(slotId)'
      // and handle Stripe.instance.presentPaymentSheet()
      // ---------------------------------------------------
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

      // AUTO-SUBMIT DESIGN REQUEST
      if (bookingId != null) {
        await submitDesignRequest(shopId, bookingId);
      }

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
    required int slotId,
    required int shopId,
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
        AppUrls.createPayPalOrder(slotId.toString()),
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
      final int bookingId = data['booking_id'];

      paymentBookingId.value = bookingId; // Store for cancel logic

      // 2. Open WebView©∫
      final bool? approved = await Get.to(
        () => PayPalWebViewScreen(url: approveUrl),
      );

      if (approved == true) {
        // 3. Capture Order
        await _capturePayPalOrder(orderId, bookingId, shopId, successArgs);
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
    int shopId,
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
        // AUTO-SUBMIT DESIGN REQUEST
        await submitDesignRequest(shopId, bookingId);

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
