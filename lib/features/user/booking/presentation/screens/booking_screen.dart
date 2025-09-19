// lib/features/user/booking/presentation/screens/booking_screen.dart
// lib/features/user/booking/presentation/screens/booking_screen.dart
import 'dart:ui';

import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/commom/widgets/fallBack_image.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/user_booking_model.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';
import '../../controller/booking_controller.dart';
import 'booking_details_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BookingController());

    final activeScroll = ScrollController();
    final historyScroll = ScrollController();

    activeScroll.addListener(() {
      if (activeScroll.position.pixels >=
          activeScroll.position.maxScrollExtent - 160) {
        c.loadMoreActive();
      }
    });
    historyScroll.addListener(() {
      if (historyScroll.position.pixels >=
          historyScroll.position.maxScrollExtent - 160) {
        c.loadMoreHistory();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        elevation: 0,
        title: CustomText(
          text: "Bookings",
          fontWeight: FontWeight.w700,
          fontSize: getWidth(20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
        child: Column(
          children: [
            Obx(() => _TabSwitcher(
                  isActive: c.isActiveBooking.value,
                  onActive: () => c.toggleTab(true),
                  onHistory: () => c.toggleTab(false),
                )),
            SizedBox(height: getHeight(16)),
            Expanded(
              child: Obx(() {
                if (c.initialLoading.value) {
                  return const Center(child: ShowProgressIndicator());
                }

                final isActive = c.isActiveBooking.value;
                final items = isActive
                    ? c.active.toList()
                    : [...c.history.toList(), ...c.cancelled.toList()];
                final isPaging =
                    isActive ? c.pagingActive.value : c.pagingHistory.value;
                final scroll = isActive ? activeScroll : historyScroll;

                if (items.isEmpty) {
                  return _EmptyState(
                    title:
                        isActive ? "No Active Booking" : "No booking history",
                    subtitle: isActive
                        ? "You don't have any upcoming bookings yet."
                        : "When you complete or cancel bookings, they'll appear here.",
                  );
                }

                return RefreshIndicator(
                  onRefresh: c.refreshAll,
                  child: ListView.separated(
                    controller: scroll,
                    itemCount: items.length + (isPaging ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: ShowProgressIndicator()),
                        );
                      }
                      final b = items[index];
                      return _BookingCard(
                        booking: b,
                        isActive: isActive,
                        onTap: () => Get.to(
                          () => BookingDetailsScreen(booking: b),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 220),
                        ),
                        onCancel: isActive ? () => c.cancel(b) : null,
                        onRebook: !isActive && b.status == 'cancelled'
                            ? () {
                                Get.to(() =>
                                    ServiceDetailsScreen(serviceId: b.serviceId));
                              }
                            : null,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final bool isActive;
  final VoidCallback onActive;
  final VoidCallback onHistory;
  const _TabSwitcher({
    required this.isActive,
    required this.onActive,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(getWidth(4)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillButton(
              label: "Active booking",
              selected: isActive,
              onTap: onActive,
            ),
          ),
          Expanded(
            child: _PillButton(
              label: "History",
              selected: !isActive,
              onTap: onHistory,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PillButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: selected ? Colors.white : Colors.transparent,
        foregroundColor: selected ? const Color(0xff0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        padding: EdgeInsets.symmetric(vertical: getHeight(10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: getWidth(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingItem booking;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;

  const _BookingCard({
    required this.booking,
    required this.isActive,
    this.onTap,
    this.onCancel,
    this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEE, d MMM').format(booking.slotTime);
    final timeText = DateFormat('hh:mm a').format(booking.slotTime);
    final status = booking.status; // "active" or others

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Top row: image + title + address + rating + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetThumb(
                  url: booking.shopImg,
                  w: getWidth(92),
                  h: getHeight(76),
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              booking.shopName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(text: status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Color(0xff7A49A5)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.shopAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Color(0xff7A49A5)),
                          const SizedBox(width: 4),
                          Text(
                            "${booking.avgRating.toStringAsFixed(1)}  (${booking.totalReviews})",
                            style: const TextStyle(fontSize: 13.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            // Middle: chips for date, time, service
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(
                    icon: Icons.event,
                    label: dateText,
                  ),
                  _Chip(
                    icon: Icons.schedule,
                    label: timeText,
                  ),
                  _Chip(
                    icon: Icons.cut,
                    label: booking.serviceTitle,
                  ),
                  if ((booking.serviceDuration).isNotEmpty)
                    _Chip(
                      icon: Icons.timer_outlined,
                      label: "${booking.serviceDuration} min",
                    ),
                ],
              ),
            ),
            if (isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: AppColors.primaryColor, width: 1.2),
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(14),
                        vertical: getHeight(10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              )
            else if (booking.status == 'completed')
              // Review button for history tab
              Obx(() {
                final controller = Get.find<BookingController>();
                final isReviewed =
                    controller.reviewedBookingIds.contains(booking.id);
                if (isReviewed) {
                  return const Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      label: Text('Reviewed'),
                      backgroundColor: AppColors.primaryColor,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                    onPressed: () => _showReviewSheet(context, booking),
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: AppColors.primaryColor, width: 1.2),
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(14),
                        vertical: getHeight(10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Review',
                      style: TextStyle(fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  )
                  );
                }
              })
            else if (booking.status == 'cancelled')
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                    onPressed: onRebook,
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: AppColors.primaryColor, width: 1.2),
                      foregroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: getWidth(14),
                        vertical: getHeight(10),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Book Again',
                      style: TextStyle(fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  )
              ),
          ],
        ),
      ),
    );
  }
}

void _showReviewSheet(BuildContext context, BookingItem booking) {
  final controller = Get.find<BookingController>();

  // reset for a fresh review each time the sheet opens
  controller.rating.value = 0;
  controller.reviewText.value = '';

  Get.bottomSheet(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Leave a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // ⭐ Whole-number only
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                allowHalfRating: false, // <- changed
                direction: Axis.horizontal,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  controller.rating.value = rating;
                },
              ),

              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  controller.reviewText.value = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Write your review here...',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // ✅ Enable only when both rating & review are present
              Obx(() {
                final canSubmit = controller.rating.value >= 1 &&
                    controller.reviewText.value.trim().isNotEmpty;

                return OutlinedButton(
                  onPressed: canSubmit
                      ? () {
                          controller.submitReview(booking);
                          Get.back();
                        }
                      : null, // disabled when invalid
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor, width: 1.2),
                    foregroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: getWidth(14),
                      vertical: getHeight(10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(10),
        vertical: getHeight(6),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  const _StatusBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final lower = text.toLowerCase();
    final isActive = lower == 'active';
    final isCancelled = lower.contains('cancel');
    final bg = isActive
        ? const Color(0xFFE6F4EA)
        : (isCancelled ? const Color(0xFFFFEBEE) : const Color(0xFFEFF6FF));
    final fg = isActive
        ? const Color(0xFF137333)
        : (isCancelled ? const Color(0xFFB00020) : const Color(0xFF1E3A8A));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        lower[0].toUpperCase() + lower.substring(1),
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: getHeight(120)),
        Icon(Icons.event_busy, size: 56, color: Colors.black.withOpacity(.20)),
        const SizedBox(height: 12),
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
// 