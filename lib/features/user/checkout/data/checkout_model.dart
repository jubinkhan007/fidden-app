// lib/features/user/checkout/data/checkout_model.dart

import 'dart:convert';

/// Response from /payments/initiate-checkout/{bookingId}/
class CheckoutInitResponse {
  final int bookingId;
  final double servicePrice;
  final double depositPaid;
  final double remainingAmount;
  final double tipBase;
  final List<TipOption> tipOptions;
  final String shopName;
  final String serviceTitle;

  CheckoutInitResponse({
    required this.bookingId,
    required this.servicePrice,
    required this.depositPaid,
    required this.remainingAmount,
    required this.tipBase,
    required this.tipOptions,
    required this.shopName,
    required this.serviceTitle,
  });

  factory CheckoutInitResponse.fromJson(Map<String, dynamic> json) {
    final tipList = (json['tip_options'] as List<dynamic>? ?? [])
        .map((e) => TipOption.fromJson(e as Map<String, dynamic>))
        .toList();

    return CheckoutInitResponse(
      bookingId: json['booking_id'] as int? ?? 0,
      servicePrice: _parseDouble(json['service_price']),
      depositPaid: _parseDouble(json['deposit_paid']),
      remainingAmount: _parseDouble(json['remaining_amount']),
      tipBase: _parseDouble(json['tip_base']),
      tipOptions: tipList,
      shopName: json['shop_name']?.toString() ?? '',
      serviceTitle: json['service_title']?.toString() ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

/// Tip option model
class TipOption {
  final String option; // "10", "15", "20", "custom", "0"
  final double amount;

  TipOption({
    required this.option,
    required this.amount,
  });

  factory TipOption.fromJson(Map<String, dynamic> json) {
    return TipOption(
      option: json['option']?.toString() ?? '',
      amount: CheckoutInitResponse._parseDouble(json['amount']),
    );
  }

  String get label {
    if (option == 'custom') return 'Custom';
    if (option == '0') return 'No Tip';
    return '$option%';
  }
}

/// Response from /payments/complete-checkout/{bookingId}/
class CheckoutPaymentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final String ephemeralKey;
  final String customerId;
  final double finalAmount;
  final double remainingAmount;
  final double tipAmount;

  CheckoutPaymentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.ephemeralKey,
    required this.customerId,
    required this.finalAmount,
    required this.remainingAmount,
    required this.tipAmount,
  });

  factory CheckoutPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentResponse(
      clientSecret: json['client_secret']?.toString() ?? '',
      paymentIntentId: json['payment_intent_id']?.toString() ?? '',
      ephemeralKey: json['ephemeral_key']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      finalAmount: CheckoutInitResponse._parseDouble(json['final_amount']),
      remainingAmount: CheckoutInitResponse._parseDouble(json['remaining_amount']),
      tipAmount: CheckoutInitResponse._parseDouble(json['tip_amount']),
    );
  }
}

/// Deposit status enum
enum DepositStatus {
  held,
  credited,
  forfeited,
  unknown;

  static DepositStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'held':
        return DepositStatus.held;
      case 'credited':
        return DepositStatus.credited;
      case 'forfeited':
        return DepositStatus.forfeited;
      default:
        return DepositStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case DepositStatus.held:
        return 'Deposit Held';
      case DepositStatus.credited:
        return 'Checked Out';
      case DepositStatus.forfeited:
        return 'Forfeited';
      default:
        return 'Unknown';
    }
  }
}
