import 'package:flutter/material.dart';
import '../../id_verification/data/id_verification_model.dart';
import 'package:intl/intl.dart';

/// Compact ID verification card for dashboard
class DashboardIDVerificationCard extends StatelessWidget {
  final IDVerificationRequest verification;
  final VoidCallback? onTap;

  const DashboardIDVerificationCard({
    super.key,
    required this.verification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE5E7),
          child: Text(
            verification.customerName.isNotEmpty
                ? verification.customerName[0].toUpperCase()
                : 'C',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE63946),
            ),
          ),
        ),
        title: Text(
          verification.customerName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Submitted ${DateFormat('MMM dd, yyyy').format(verification.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFB8500).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Review',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFB8500),
            ),
          ),
        ),
      ),
    );
  }
}
