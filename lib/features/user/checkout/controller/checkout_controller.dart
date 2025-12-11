// lib/features/user/checkout/controller/checkout_controller.dart

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/checkout/data/checkout_model.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  // Reactive state
  final isLoading = false.obs;
  final checkoutData = Rxn<CheckoutInitResponse>();
  final selectedTipOption = '15'.obs; // Default to 15%
  final customTipAmount = 0.0.obs;
  final paymentResponse = Rxn<CheckoutPaymentResponse>();

  /// Calculate current tip amount based on selection
  double get tipAmount {
    final data = checkoutData.value;
    if (data == null) return 0.0;

    if (selectedTipOption.value == 'custom') {
      return customTipAmount.value;
    }
    if (selectedTipOption.value == '0') {
      return 0.0;
    }

    // Find the matching tip option
    final option = data.tipOptions.firstWhereOrNull(
      (t) => t.option == selectedTipOption.value,
    );
    return option?.amount ?? 0.0;
  }

  /// Total amount due = remaining + tip
  double get totalDue {
    final data = checkoutData.value;
    if (data == null) return 0.0;
    return data.remainingAmount + tipAmount;
  }

  /// Initiate checkout (called by owner)
  /// Returns true if successful
  /// [paymentMethod] can be 'cash' or 'app'
  Future<bool> initiateCheckout(int bookingId, {String paymentMethod = 'app'}) async {
    try {
      isLoading(true);
      final response = await NetworkCaller().postRequest(
        AppUrls.initiateCheckout(bookingId),
        token: AuthService.accessToken,
        body: {
          'payment_method': paymentMethod,
        },
      );

      if (response.isSuccess) {
        final message = paymentMethod == 'cash' 
            ? 'Cash payment recorded. Checkout complete.'
            : 'Checkout initiated. Customer will be notified.';
        AppSnackBar.showSuccess(message);
        return true;
      } else {
        final detail = response.responseData?['detail'] ?? response.errorMessage;
        AppSnackBar.showError(detail ?? 'Failed to initiate checkout');
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Fetch checkout details for customer
  /// Called when customer opens checkout screen
  Future<bool> fetchCheckoutDetails(int bookingId) async {
    try {
      isLoading(true);
      final response = await NetworkCaller().getRequest(
        AppUrls.checkoutDetails(bookingId),
        token: AuthService.accessToken,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        checkoutData.value = CheckoutInitResponse.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        // Set default tip option to 15% if available
        if (checkoutData.value!.tipOptions.any((t) => t.option == '15')) {
          selectedTipOption.value = '15';
        }
        return true;
      } else {
        final detail = response.responseData?['detail'] ?? response.errorMessage;
        AppSnackBar.showError(detail ?? 'Failed to load checkout details');
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Complete checkout with payment (called by customer)
  /// Returns CheckoutPaymentResponse with Stripe client secret
  Future<CheckoutPaymentResponse?> completeCheckout(int bookingId) async {
    try {
      isLoading(true);

      final body = <String, dynamic>{
        'tip_option': selectedTipOption.value,
      };
      if (selectedTipOption.value == 'custom') {
        body['tip_amount'] = customTipAmount.value;
      }

      final response = await NetworkCaller().postRequest(
        AppUrls.completeCheckout(bookingId),
        token: AuthService.accessToken,
        body: body,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        paymentResponse.value = CheckoutPaymentResponse.fromJson(
          response.responseData as Map<String, dynamic>,
        );
        return paymentResponse.value;
      } else {
        final detail = response.responseData?['detail'] ?? response.errorMessage;
        AppSnackBar.showError(detail ?? 'Failed to process checkout');
        return null;
      }
    } catch (e) {
      AppSnackBar.showError('Error: $e');
      return null;
    } finally {
      isLoading(false);
    }
  }

  /// Select a tip option
  void selectTipOption(String option) {
    selectedTipOption.value = option;
    if (option != 'custom') {
      customTipAmount.value = 0.0;
    }
  }

  /// Set custom tip amount
  void setCustomTipAmount(double amount) {
    customTipAmount.value = amount;
    selectedTipOption.value = 'custom';
  }

  /// Reset controller state
  void reset() {
    checkoutData.value = null;
    paymentResponse.value = null;
    selectedTipOption.value = '15';
    customTipAmount.value = 0.0;
  }
}
