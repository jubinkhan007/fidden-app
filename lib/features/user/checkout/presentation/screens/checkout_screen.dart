// lib/features/user/checkout/presentation/screens/checkout_screen.dart

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/user/checkout/controller/checkout_controller.dart';
import 'package:fidden/features/user/checkout/data/checkout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Customer checkout screen for completing payment with tip
class CheckoutScreen extends StatefulWidget {
  final int bookingId;

  const CheckoutScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutController _controller;
  final _customTipController = TextEditingController();
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CheckoutController());
    _controller.fetchCheckoutDetails(widget.bookingId);
  }

  @override
  void dispose() {
    _customTipController.dispose();
    Get.delete<CheckoutController>();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Complete Checkout'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.checkoutData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = _controller.checkoutData.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Failed to load checkout details'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchCheckoutDetails(widget.bookingId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Summary Card
              _buildServiceSummaryCard(data),
              const SizedBox(height: 16),

              // Price Breakdown Card
              _buildPriceBreakdownCard(data),
              const SizedBox(height: 16),

              // Tip Selection Card
              _buildTipSelectionCard(data),
              const SizedBox(height: 16),

              // Total Due Card
              _buildTotalDueCard(),
              const SizedBox(height: 24),

              // Pay Button
              _buildPayButton(),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServiceSummaryCard(CheckoutInitResponse data) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A49A5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.content_cut, color: Color(0xFF7A49A5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.serviceTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data.shopName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(CheckoutInitResponse data) {
    return _SectionCard(
      title: 'Price Breakdown',
      child: Column(
        children: [
          _PriceRow(
            label: 'Service Total',
            value: _formatCurrency(data.servicePrice),
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Deposit Paid',
            value: '-${_formatCurrency(data.depositPaid)}',
            valueColor: const Color(0xFF10B981),
          ),
          const Divider(height: 24),
          _PriceRow(
            label: 'Remaining',
            value: _formatCurrency(data.remainingAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTipSelectionCard(CheckoutInitResponse data) {
    return _SectionCard(
      title: 'Add a Tip',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Show your appreciation for great service',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          // Tip option buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // No tip option
              _TipOptionButton(
                label: 'No Tip',
                amount: '\$0',
                isSelected: _controller.selectedTipOption.value == '0',
                onTap: () => _controller.selectTipOption('0'),
              ),
              // Preset options
              ...data.tipOptions.map((option) {
                if (option.option == 'custom') return const SizedBox.shrink();
                return _TipOptionButton(
                  label: '${option.option}%',
                  amount: _formatCurrency(option.amount),
                  isSelected: _controller.selectedTipOption.value == option.option,
                  onTap: () => _controller.selectTipOption(option.option),
                );
              }),
              // Custom option
              _TipOptionButton(
                label: 'Custom',
                amount: _controller.selectedTipOption.value == 'custom'
                    ? _formatCurrency(_controller.customTipAmount.value)
                    : null,
                isSelected: _controller.selectedTipOption.value == 'custom',
                onTap: () => _showCustomTipDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDueCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A49A5), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A49A5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatCurrency(_controller.checkoutData.value?.remainingAmount ?? 0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_controller.tipAmount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '+${_formatCurrency(_controller.tipAmount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Due',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(_controller.totalDue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildPayButton() {
    return Obx(() => ElevatedButton(
      onPressed: _controller.isLoading.value || _isProcessingPayment
          ? null
          : _processPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
      child: _isProcessingPayment
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'Pay ${_formatCurrency(_controller.totalDue)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    ));
  }

  void _showCustomTipDialog() {
    _customTipController.text = _controller.customTipAmount.value > 0
        ? _controller.customTipAmount.value.toStringAsFixed(2)
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Tip'),
        content: TextField(
          controller: _customTipController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: '0.00',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_customTipController.text) ?? 0.0;
              _controller.setCustomTipAmount(amount);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessingPayment = true);

    try {
      // Get payment intent from backend
      final paymentResponse = await _controller.completeCheckout(widget.bookingId);
      if (paymentResponse == null) {
        setState(() => _isProcessingPayment = false);
        return;
      }

      // Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentResponse.clientSecret,
          merchantDisplayName: 'Fidden',
          customerId: paymentResponse.customerId,
          customerEphemeralKeySecret: paymentResponse.ephemeralKey,
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      AppSnackBar.showSuccess('Payment successful!');
      Get.back(result: true);
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        AppSnackBar.showError(e.error.localizedMessage ?? 'Payment failed');
      }
    } catch (e) {
      AppSnackBar.showError('Payment error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }
}

// --- Helper Widgets ---

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _TipOptionButton extends StatelessWidget {
  final String label;
  final String? amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipOptionButton({
    required this.label,
    this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A49A5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A49A5) : const Color(0xFFE5E7EB),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7A49A5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (amount != null) ...[
              const SizedBox(height: 2),
              Text(
                amount!,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
