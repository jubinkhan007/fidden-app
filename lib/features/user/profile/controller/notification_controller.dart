import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/notification_model_1.dart';

/// A wrapper around NotificationDatum to handle UI-only states
class NotificationItem extends NotificationDatum {
  bool isExpanded;
  bool isRead;

  NotificationItem({
    required NotificationDatum datum,
    this.isExpanded = false,
    bool? isReadOverride,
  }) : isRead = isReadOverride ?? datum.read ?? false,
       super(
         id: datum.id,
         senderId: datum.senderId,
         receiverId: datum.receiverId,
         title: datum.title,
         body: datum.body,
         read: datum.read,
         createdAt: datum.createdAt,
         updatedAt: datum.updatedAt,
       );
}

class NotificationController extends GetxController {
  var inProgress = false.obs;

  /// Full API response (for future use)
  var allNotificationDetails = GetMyNotificationModel().obs;

  /// Processed list for UI (includes extra flags)
  var notifications = <NotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotification();
  }

  /// Fetch notifications from API
  Future<void> fetchNotification() async {
    inProgress.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.allMyNotification,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          final model = GetMyNotificationModel.fromJson(response.responseData);
          allNotificationDetails.value = model;

          /// Convert each NotificationDatum to NotificationItem with added flags
          notifications.value =
              model.data
                  ?.map((datum) => NotificationItem(datum: datum))
                  .toList() ??
              [];
        } else {
          throw Exception('Unexpected response data format');
        }
      } else {
        debugPrint('Failed to load notifications');
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    } finally {
      inProgress.value = false;
    }
  }

  /// Mark notification as read
  void markAsRead(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  /// Toggle expand and mark as read
  void toggleExpand(int index) {
    if (index >= 0 && index < notifications.length) {
      notifications[index].isExpanded = !notifications[index].isExpanded;
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }
}
