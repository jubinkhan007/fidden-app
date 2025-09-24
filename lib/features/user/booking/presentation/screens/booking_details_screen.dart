import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/fallBack_image.dart'; // <-- fallback image
import 'package:fidden/features/inbox/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/icon_path.dart';
import '../../data/user_booking_model.dart';
import '../api_time_format.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.booking});

  final BookingItem booking;

  @override
  Widget build(BuildContext context) {
    final dateText = formatApiDate(booking.slotTimeIso); // e.g. "Sun, 21 Sep 2025"
    final timeText = formatApiTime(booking.slotTimeIso); // e.g. "01:30 PM"
    final chatController = Get.put(
  ChatController(
    threadId: 0,                    // no existing thread yet
    shopId: booking.shop,           // <- from your booking
    shopName: booking.shopName,     // <- from your booking
    isOwner: false,                 // this is the USER app
  ),
  tag: 'bk_msg_${booking.id}',      // unique tag, avoids clashes
);

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: CustomText(
          text: "Booking",
          fontWeight: FontWeight.w700,
          fontSize: getWidth(20),
        ),
        actions: [
          IconButton(
            onPressed: () => _showMessageDialog(context, chatController),
            icon: const Icon(Icons.message_outlined),
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Card: Shop summary =========================================================
            Container(
              padding: EdgeInsets.all(getWidth(10)),
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NetThumb( // <-- safe network image with fallback
                    url: booking.shopImg,
                    w: getWidth(100),
                    h: getHeight(80),
                    borderRadius: 10,
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded( // <-- prevents overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // top row: title + status badge
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
                                  color: Color(0xff111827),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(width: getWidth(8)),
                            _StatusBadge(text: booking.status),
                          ],
                        ),
                        SizedBox(height: getHeight(8)),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16,
                                color: const Color(0xff7A49A5).withOpacity(.7)),
                            SizedBox(width: getWidth(6)),
                            Expanded(
                              child: Text(
                                booking.shopAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xff7A49A5).withOpacity(.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: getHeight(8)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                size: 16,
                                color: const Color(0xff7A49A5).withOpacity(.7)),
                            SizedBox(width: getWidth(6)),
                            Text(
                              "${booking.avgRating.toStringAsFixed(1)}  (${booking.totalReviews})",
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xff7A49A5).withOpacity(.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: getHeight(20)),
            const Divider(height: 1),

            // === Date & time ================================================================
            SizedBox(height: getHeight(18)),
            Row(
              children: [
                Image.asset(
                  "assets/images/date_time.png",
                  height: getHeight(22),
                  width: getWidth(22),
                  color: Colors.black87,
                ),
                SizedBox(width: getWidth(10)),
                CustomText(
                  text: "Date & time",
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            SizedBox(height: getHeight(10)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.event, label: dateText),
                _InfoChip(icon: Icons.schedule, label: timeText),
              ],
            ),

            // === Service selected ===========================================================
            SizedBox(height: getHeight(24)),
            Row(
              children: [
                Image.asset(
                  IconPath.serviceIcon,
                  height: getHeight(18),
                  width: getWidth(18),
                ),
                SizedBox(width: getWidth(8)),
                CustomText(
                  text: "Service selected",
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: getHeight(10)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(8),
                vertical: getHeight(8),
              ),
              decoration: BoxDecoration(
                color: const Color(0xffFFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: getWidth(26),
                  backgroundImage:
                      const AssetImage("assets/images/barber_image.png"),
                ),
                title: Text(
                  booking.serviceTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff111827),
                  ),
                ),
                subtitle: Text(
                  "Duration: ${booking.serviceDuration} min",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: const Color(0xff6B7280),
                  ),
                ),
              ),
            ),

            SizedBox(height: getHeight(12)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(icon: Icons.confirmation_number_outlined, label: "Booking #${booking.id}"),
                // _InfoChip(icon: Icons.store_mall_directory_outlined, label: "Shop ID: ${booking.shop}"),
                _InfoChip(icon: Icons.person_outline, label: booking.userEmail),
              ],
            ),

            // NOTE: No "Pay now" button (by request)
            SizedBox(height: getHeight(24)),
          ],
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context, ChatController chatController) {
    final messageController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("Message Shop"),
        content: TextFormField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: "Type your message...",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  Get.back(); // close dialog

  await chatController.send(text);

  // toast/snackbar
  AppSnackBar.showSuccess('Message sent');
},
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

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
      padding: EdgeInsets.symmetric(
        horizontal: getWidth(10),
        vertical: getHeight(5),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
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