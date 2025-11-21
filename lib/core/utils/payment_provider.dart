// lib/core/utils/payment_provider.dart

import 'package:flutter/material.dart';

enum PaymentProvider { stripe, paypal }

extension PaymentProviderX on PaymentProvider {
  String get apiValue {
    switch (this) {
      case PaymentProvider.stripe:
        return 'stripe';
      case PaymentProvider.paypal:
        return 'paypal';
    }
  }

  String get label {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Card (Stripe)';
      case PaymentProvider.paypal:
        return 'PayPal';
    }
  }
}

/// Simple bottom sheet to pick Stripe vs PayPal
Future<PaymentProvider?> _pickPaymentProvider(
    BuildContext context,
    ) {
  return showModalBottomSheet<PaymentProvider>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Choose payment method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(PaymentProvider.stripe.label),
              subtitle: const Text('Pay with debit/credit card'),
              onTap: () =>
                  Navigator.of(ctx).pop(PaymentProvider.stripe),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(PaymentProvider.paypal.label),
              subtitle: const Text('Pay with your PayPal account'),
              onTap: () =>
                  Navigator.of(ctx).pop(PaymentProvider.paypal),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}