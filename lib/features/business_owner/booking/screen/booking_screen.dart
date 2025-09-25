// lib/features/business_owner/booking/screen/booking_screen.dart
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/fallBack_image.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/features/business_owner/home/screens/reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../home/controller/business_owner_controller.dart';

String _capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
class CircleNetAvatar extends StatelessWidget {
  const CircleNetAvatar({
    super.key,
    required this.url,
    this.size = 56,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipOval(
        child: NetThumb(
          url: url,
          w: size,
          h: size,
          borderRadius: size / 2,
        ),
      ),
    );
  }
}

class BusinessOwnerBookingScreen extends StatelessWidget {
  const BusinessOwnerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BusinessOwnerController());
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('All Bookings'),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final results = controller.allBusinessOwnerBookingOne.value.results;

        // 1) Initial fetch -> skeleton
        if (isLoading && results.isEmpty) {
          return _BookingSkeletonList(
            itemCount: 6,
            leftRightPadding: EdgeInsets.symmetric(horizontal: getWidth(16)),
            topPadding: getHeight(12),
            spacing: getWidth(14),
          );
        }

        // 2) Empty state (with pull to refresh)
        if (results.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => controller.fetchBusinessOwnerBooking(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: getHeight(140)),
                _EmptyBookings(cs: cs),
                SizedBox(height: getHeight(60)),
              ],
            ),
          );
        }

        // 3) List with pull-to-refresh + nice cards
        return RefreshIndicator(
          onRefresh: () async => controller.fetchBusinessOwnerBooking(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(getWidth(16), getHeight(12), getWidth(16), getHeight(24)),
            itemCount: results.length,
            separatorBuilder: (_, __) => SizedBox(height: getHeight(12)),
            itemBuilder: (context, index) {
              final b = results[index];

              final displayName = (b.userName?.trim().isNotEmpty == true)
                  ? b.userName!.trim()
                  : b.userEmail;

              final date = DateFormat('EEE, d MMM yyyy').format(b.slotTime);
              final time = DateFormat('hh:mm a').format(b.slotTime);

              // The 'status' field comes directly from your data model.
              // Add a fallback in case the string is ever empty.
              final bookingStatus = b.status.isNotEmpty ? b.status : 'Pending';

              return _BookingCard(
                cs: cs,
                avatarUrl: b.profileImage,
                title: displayName,
                subtitle: b.serviceTitle,
                dateText: date,
                timeText: time,
                status: bookingStatus, // <-- PASS the status to the card
                onTap: () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _BookingDetailsSheet(
                    cs: cs,
                    avatarUrl: b.profileImage,
                    name: displayName,
                    service: b.serviceTitle,
                    when: "$time • $date",
                    shop: b.shopName,
                    status: bookingStatus, // <-- PASS the status to the bottom sheet
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Card UI for each booking item
/// Card UI for each booking item
class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.cs,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.timeText,
    required this.status, // ADD this parameter
    required this.onTap,
    // REMOVED: onReminder
  });

  final ColorScheme cs;
  final String? avatarUrl;
  final String? title;
  final String? subtitle;
  final String dateText;
  final String timeText;
  final String status;   // ADDED
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(getWidth(14)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleNetAvatar(url: avatarUrl, size: getWidth(56)),
              SizedBox(width: getWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER ROW: title + status pill
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title ?? 'Customer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(width: getWidth(8)),
                        // --- REPLACEMENT ---
                        // The FilledButton has been replaced with our new StatusPill
                        _StatusPill(status: status),
                      ],
                    ),
                    SizedBox(height: getHeight(4)),
                    Row(
                      children: [
                        const Icon(Icons.design_services, size: 16, color: Color(0xff898989)),
                        SizedBox(width: getWidth(6)),
                        Expanded(
                          child: Text(
                            subtitle ?? 'Service',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: getWidth(14), color: const Color(0xff898989)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(8)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip(icon: Icons.calendar_month, text: dateText, cs: cs),
                          const SizedBox(width: 8),
                          _chip(icon: Icons.schedule, text: timeText, cs: cs),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String text, required ColorScheme cs}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: cs.onSurface)),
        ],
      ),
    );
  }
}

/// Details bottom sheet
/// Details bottom sheet
class _BookingDetailsSheet extends StatelessWidget {
  const _BookingDetailsSheet({
    required this.cs,
    required this.avatarUrl,
    required this.name,
    required this.service,
    required this.when,
    required this.shop,
    required this.status, // ADD this parameter
    // REMOVED: onReminder
  });

  final ColorScheme cs;
  final String? avatarUrl;
  final String? name;
  final String? service;
  final String when;
  final String? shop;
  final String status;   // ADDED

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(getWidth(16), getHeight(8), getWidth(16), getHeight(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleNetAvatar(url: avatarUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name ?? 'Customer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          row('Service', service ?? '—'),
          row('When', when),
          row('Shop', shop ?? '—'),
          // ADD this status row for displaying the booking status
          row('Status', _capitalize(status)),
          const SizedBox(height: 20),
          // REMOVED the FilledButton and TextButton for a cleaner, display-only sheet.
        ],
      ),
    );
  }
}

/// Empty state
class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.event_busy, size: 56, color: cs.onSurfaceVariant),
        const SizedBox(height: 12),
        const Text('No bookings found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Pull down to refresh.', style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

/// Skeletons while loading
class _BookingSkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry leftRightPadding;
  final double topPadding;
  final double spacing;

  const _BookingSkeletonList({
    this.itemCount = 6,
    this.leftRightPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.topPadding = 8,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    Widget bar({double h = 14, double w = 120, double r = 8}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(r)),
        );

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ListView.separated(
        padding: leftRightPadding,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(getWidth(14)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 56, width: 56, decoration: BoxDecoration(color: highlight, shape: BoxShape.circle)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(w: MediaQuery.of(context).size.width * 0.35, h: 16),
                      const SizedBox(height: 8),
                      bar(w: MediaQuery.of(context).size.width * 0.50),
                      const SizedBox(height: 8),
                      bar(w: MediaQuery.of(context).size.width * 0.40),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(height: 32, width: 90, decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(8))),
              ],
            ),
          );
        },
      ),
    );
  }
}
// In /lib/features/business_owner/booking/screen/booking_screen.dart

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final IconData iconData;

    // Use .toLowerCase() for case-insensitive matching from the API
    switch (status.toLowerCase()) {
    // --- STYLE SWAPPED ---
    // 'completed' and 'confirmed' now use the green checkmark
      case 'completed':
      case 'confirmed':
        backgroundColor = const Color(0xFFE6F4EA); // Light Green
        foregroundColor = const Color(0xFF2E7D32); // Dark Green
        iconData = Icons.check_circle;
        break;

    // --- STYLE SWAPPED ---
    // 'active' now has its own distinct "in-progress" style
      case 'active':
        backgroundColor = const Color(0xFFE3F2FD); // Light Blue
        foregroundColor = const Color(0xFF1565C0); // Dark Blue
        iconData = Icons.timelapse; // Icon for in-progress/active
        break;

      case 'cancelled':
        backgroundColor = const Color(0xFFFFEBEE); // Light Red
        foregroundColor = const Color(0xFFC62828); // Dark Red
        iconData = Icons.cancel;
        break;

      case 'pending':
      default:
        backgroundColor = const Color(0xFFFFF3E0); // Light Orange
        foregroundColor = const Color(0xFFF57C00); // Dark Orange
        iconData = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(10),
        vertical: getHeight(5),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: foregroundColor, size: 14),
          SizedBox(width: getWidth(6)),
          Text(
            _capitalize(status), // Use the helper for a clean look
            style: TextStyle(
              color: foregroundColor,
              fontSize: getWidth(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}