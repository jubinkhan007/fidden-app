import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/constants/app_sizes.dart';
import '../../controller/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: CustomText(
          text: "Notifications",
          color: Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.inProgress.value) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: getHeight(350)),
                ShowProgressIndicator(),
              ],
            ),
          );
        }
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No Notifications",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            var notification = controller.notifications[index];

            return GestureDetector(
              //onTap: () => controller.markAsRead(index),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Read Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Text(
                                notification.title ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // if (!notification.isRead)
                          //   CircleAvatar(radius: 5, backgroundColor: Colors.red),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Message Preview (Only Two Lines) or Full Message
                      Text(
                        notification.body ?? '',
                        style: TextStyle(fontSize: 14),
                        maxLines: notification.isExpanded
                            ? null
                            : 2, // Show only 2 lines if not expanded
                        overflow: notification.isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis, // Show "..." if truncated
                      ),

                      SizedBox(height: 8),

                      // Time & "See More"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatNotificationTime(notification.updatedAt),
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => controller.toggleExpand(index),
                            child: Text(
                              notification.isExpanded ? "See Less" : "See More",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String formatNotificationTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inDays > 7) {
      // Format as: 23rd April 25
      final day = DateFormat('d').format(dateTime);
      final suffix = getDaySuffix(int.parse(day));
      return '${day}${suffix} ${DateFormat('MMMM yy').format(dateTime)}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago'; // Days first if >= 1 day
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago'; // Otherwise, show hours
    }

    return '${difference.inMinutes}m ago'; // Otherwise, show minutes
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
