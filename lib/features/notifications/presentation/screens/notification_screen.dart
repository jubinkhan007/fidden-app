// lib/features/user/profile/presentation/screens/notification_screen.dart
import 'package:fidden/features/notifications/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const _NotificationSkeleton();
        }
        if (c.notifications.isEmpty) {
          return const _EmptyState();
        }
        return RefreshIndicator(
          onRefresh: c.fetchNotifications,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: c.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final notification = c.notifications[i];
              return _NotificationTile(
                message: notification.message,
                time: c.timeAgo(notification.createdAt),
                isRead: notification.isRead,
                onTap: () {
                  c.markAsRead(notification.id);
                  // TODO: Handle navigation based on notification type
                  // For example:
                  // if (notification.notificationType == 'chat') {
                  //   final threadId = notification.data['thread_id'];
                  //   Get.to(() => ChatScreen(threadId: threadId, ...));
                  // }
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.message,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  final String message;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? const Color(0xFFEDEEF1) : const Color(0xFFBFDBFE),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRead
                    ? const Color(0xFFF3F4F6)
                    : const Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: isRead
                    ? const Color(0xFF6B7280)
                    : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            // Message and Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Unread Indicator
            if (!isRead)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
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
          children: const [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Color(0xFF9AA3B2),
            ),
            SizedBox(height: 12),
            Text(
              'No Notifications',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 6),
            Text(
              "You'll see notifications about your account here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8494)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = double.infinity, double h = 14}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF1),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEEF1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDEEF1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(w: 200, h: 16),
                  const SizedBox(height: 8),
                  bar(w: 80, h: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
