import 'package:flutter/material.dart';

/// Verification badge widget for displaying shop verification status
///
/// Displays different badges based on shop status:
/// - verified: Green checkmark
/// - unverified: Orange info icon
/// - pending: Grey hourglass
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({super.key, required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    if (status == null || status!.isEmpty) return const SizedBox.shrink();

    final config = _getBadgeConfig(status!);
    if (config == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.iconColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig? _getBadgeConfig(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return _BadgeConfig(
          icon: Icons.verified,
          label: 'Verified',
          backgroundColor: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          textColor: const Color(0xFF166534),
        );
      case 'unverified':
        return _BadgeConfig(
          icon: Icons.info_outline,
          label: 'Unverified',
          backgroundColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFF59E0B),
          textColor: const Color(0xFF92400E),
        );
      case 'pending':
        return _BadgeConfig(
          icon: Icons.hourglass_top,
          label: 'Pending Review',
          backgroundColor: const Color(0xFFF3F4F6),
          iconColor: const Color(0xFF6B7280),
          textColor: const Color(0xFF374151),
        );
      default:
        return null;
    }
  }
}

class _BadgeConfig {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  _BadgeConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });
}
