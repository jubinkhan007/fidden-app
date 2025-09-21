import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/features/business_owner/transactions/data/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final bool isPayment = transaction.transactionType == 'payment';
    final Color amountColor = isPayment ? AppColors.success : AppColors.error;
    final IconData iconData = isPayment ? Icons.arrow_downward : Icons.arrow_upward;
    final String title = isPayment ? 'Payment Received' : 'Refund Issued';
    final String formattedDate = DateFormat('MMM d, yyyy hh:mm a').format(DateTime.parse(transaction.createdAt!));

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: amountColor.withOpacity(0.1),
              child: Icon(iconData, color: amountColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'For: ${transaction.serviceTitle}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '${isPayment ? '+' : '-'} \$${transaction.amount}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}