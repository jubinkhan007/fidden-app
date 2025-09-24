import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../coupons/controller/user_coupons_controller.dart';
import '../../../coupons/data/user_coupon_model.dart';

class SelectCouponScreen extends StatelessWidget {
  const SelectCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final shopId = args['shopId'] as int? ?? 0;
    final serviceId = args['serviceId'] as int? ?? 0;
    final c = Get.put(UserCouponsController());

    if (c.coupons.isEmpty) {
      // first-visit load
      c.fetch(shopId: shopId, serviceId: serviceId);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Available Coupons', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(), // no selection
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const _ShimmerList();
        }
        if (c.coupons.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: c.coupons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _CouponRow(
            coupon: c.coupons[i],
            onApply: (coupon) => Get.back(result: coupon),
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: OutlinedButton.icon(
          onPressed: () => Get.back(result: null), // clear any selection
          icon: const Icon(Icons.close_rounded),
          label: const Text('Don’t use a coupon', style: TextStyle(fontWeight: FontWeight.w800)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.coupon, required this.onApply});
  final UserCoupon coupon;
  final ValueChanged<UserCoupon> onApply;

  @override
  Widget build(BuildContext context) {
    final statusColor = coupon.isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    final badgeBg = coupon.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6);
    final until = DateFormat.yMMMd().format(coupon.validityDate);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onApply(coupon),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // left badge
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  coupon.shortAmountLabel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              // info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(coupon.code, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(coupon.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: coupon.isActive ? const Color(0xFF065F46) : const Color(0xFF4B5563),
                                  fontWeight: FontWeight.w800, fontSize: 11)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(coupon.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 6),
                        Text('valid • $until', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => onApply(coupon),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer_outlined, size: 56, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text('No coupons available', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey.shade900)),
            const SizedBox(height: 6),
            Text('There aren’t any coupons for this service right now.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 88,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F5),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
