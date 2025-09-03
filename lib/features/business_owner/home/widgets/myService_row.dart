import 'package:fidden/core/services/safe_network_image.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:fidden/features/business_owner/home/model/get_my_service_model.dart';
import 'package:flutter/material.dart';

/// =========================
/// Loading (shimmer-ish) row
/// =========================
class ServicesShimmerRow extends StatelessWidget {
  const ServicesShimmerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(150),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: EdgeInsets.zero,
        separatorBuilder: (_, __) => SizedBox(width: getWidth(12)),
        itemBuilder: (_, __) => _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _pulse(
            child: Container(
              width: getWidth(84),
              height: getHeight(150),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pulse(
                    child: Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _pulse(
                    child: Container(
                      height: 12,
                      width: getWidth(160),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _pulse(
                    child: Container(
                      height: 16,
                      width: getWidth(60),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pulse({required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .6, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, _) => Opacity(opacity: value, child: child),
      onEnd: () => {},
    );
  }
}

/// ====================
/// Guard / Empty banners
/// ====================
class ServicesGuardBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const ServicesGuardBanner({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF92400E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF78350F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7C2D12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: const BorderSide(color: Color(0xFFF59E0B)),
              ),
              backgroundColor: const Color(0xFFFFF7ED),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class ServicesEmpty extends StatelessWidget {
  final VoidCallback? onCreate;
  const ServicesEmpty({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "You haven’t added any services yet.",
              style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onCreate != null)
            TextButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                backgroundColor: const Color(0xFFEEF2FF),
                foregroundColor: const Color(0xFF3730A3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ==============
/// Services lists
/// ==============
class ServicesRow extends StatelessWidget {
  final List<GetMyServiceModel> items;
  final void Function(String id) onEdit;

  const ServicesRow({super.key, required this.items, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getHeight(150),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: getWidth(12)),
        itemBuilder: (_, i) => ServiceCard(item: items[i], onEdit: onEdit),
      ),
    );
  }
}

/// ============
/// ServiceCard
/// ============
class ServiceCard extends StatelessWidget {
  final GetMyServiceModel item;
  final void Function(String id) onEdit;

  const ServiceCard({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final id = (item.id ?? '').toString();
    final price = double.tryParse(item.price ?? '0') ?? 0;
    final hasImage = (item.serviceImg != null && item.serviceImg!.isNotEmpty);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onEdit(id),
      child: Container(
        width: getWidth(300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // image (with rounded left edges + safe fallback)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: hasImage
                  ? SafeNetworkImage(
                      url: item.serviceImg,
                      width: getWidth(90),
                      height: getHeight(150),
                      fit: BoxFit.cover,
                      // If your SafeNetworkImage supports fallback/placeholder,
                      // keep passing them here. Otherwise SafeNetworkImage
                      // should already handle invalid/empty URLs gracefully.
                    )
                  : Container(
                      width: getWidth(90),
                      height: getHeight(150),
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: Image.asset(
                        IconPath.serviceIcon,
                        width: getWidth(32),
                        height: getWidth(32),
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title + edit icon
                    Row(
                      children: [
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: getWidth(15),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),

                        const SizedBox(width: 96),
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // description
                    Text(
                      item.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: getWidth(12.5),
                        color: const Color(0xFF6B7280),
                        height: 1.25,
                      ),
                    ),

                    const Spacer(),

                    // price + meta row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            price == 0
                                ? 'Free'
                                : '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: getWidth(13.5),
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // quick meta chips (optional)
                        // if ((item.duration ?? '').toString().isNotEmpty)
                        //   _chip('${item.duration} min'),
                        // if ((item.category ?? '').toString().isNotEmpty)
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 6),
                        //   child: _chip(
                        //     item.category.toString().length > 14
                        //         ? '${item.category.toString().substring(0, 12)}…'
                        //         : item.category.toString(),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF3730A3),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
