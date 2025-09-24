// lib/features/business_owner/coupons/screens/all_coupons_screen.dart
import 'package:fidden/features/business_owner/coupons/controller/coupon_controller.dart';
import 'package:fidden/features/business_owner/coupons/data/coupon_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllCouponsScreen extends StatelessWidget {
  const AllCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('My Coupons', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Add coupon',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Get.toNamed('/add-coupon'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const _ListSkeleton();
        if (controller.coupons.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          onRefresh: () async => controller.fetchCoupons(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: controller.coupons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = controller.coupons[index];
              return _CouponCard(
                coupon: c,
                onEdit: () => Get.toNamed('/edit-coupon', arguments: c),
                onToggleActive: () async {
                  await controller.setActive(c.id, !c.isActive);
                },
                onDelete: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete coupon?'),
                      content: Text('This will permanently remove ${c.code}.'),
                      actions: [
                        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await controller.deleteCoupon(c.id);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}

/// helpers
String _amountLabel(Coupon c) {
  if (c.inPercentage) {
    final asInt = c.amount.truncateToDouble() == c.amount;
    return '${c.amount.toStringAsFixed(asInt ? 0 : 2)}%';
  }
  final n = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  return n.format(c.amount);
}

String _validityBadgeText(DateTime until) {
  final now = DateTime.now();
  final d = DateTime(until.year, until.month, until.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = d.difference(today).inDays;
  if (diff < 0) return 'Expired';
  if (diff == 0) return 'Expires today';
  if (diff == 1) return 'Expires tomorrow';
  return 'valid • ${DateFormat.yMMMd().format(until)}';
}

/// card
class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final Coupon coupon;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const double pad = 14; // ↓ from 14
    const double leading = 64; // ↓ from 64
    const double gapS = 4;
    const double gapM = 6;

    final statusColor = coupon.isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    final badgeBg = coupon.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6);
    final servicesCount = coupon.services.length;

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.all(pad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // leading
            Container(
              width: leading,
              height: leading,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _amountLabel(coupon),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12, // ↓
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 10), // ↓
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // code + menu (single row where possible)
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6, // ↓
                          runSpacing: 2, // ↓
                          children: [
                            Text(
                              coupon.code,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15, // ↓
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // ↓
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6, // ↓
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    coupon.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: coupon.isActive
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF4B5563),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11, // ↓
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero, // ↓
                        onSelected: (v) {
                          switch (v) {
                            case 'edit': onEdit(); break;
                            case 'toggle': onToggleActive(); break;
                            case 'delete': onDelete(); break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                          ),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.more_horiz_rounded, size: 20), // ↓
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: gapS),
                  Text(
                    coupon.description,
                    maxLines: 2, // cap lines
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5, // ↓
                      height: 1.25, // tighter
                    ),
                  ),

                  const SizedBox(height: gapM),
                  // compact meta line(s)
                  Wrap(
                    spacing: 10, // ↓
                    runSpacing: 6, // ↓
                    children: [
                      _metaChip(Icons.layers_rounded,
                          servicesCount == 0 ? 'All services' : '${servicesCount} svc'),
                      _metaChip(Icons.calendar_month_rounded,
                          _validityBadgeText(coupon.validityDate)),
                      _metaChip(Icons.person_outline_rounded,
                          'Max ${coupon.maxUsagePerUser}'),
                    ],
                  ),

                  const SizedBox(height: gapM),
                  // compact actions
                  Row(
                    children: [
                      _smallAction(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _smallAction(
                        icon: coupon.isActive
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        label: coupon.isActive ? 'Deactivate' : 'Activate',
                        onPressed: onToggleActive,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), // ↓
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(9), // ↓
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)), // ↓
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12, // ↓
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16), // ↓
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // ↓
        minimumSize: const Size(0, 0), // allow compact height
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // ↓
      ),
    );
    }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_offer_outlined, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            const Text('No coupons yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(
              'Create your first coupon to reward customers and boost conversions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/add-coupon'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Coupon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 104,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
