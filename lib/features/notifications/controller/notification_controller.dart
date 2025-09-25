// lib/features/user/profile/controller/notification_controller.dart
import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/notifications/data/notification_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


  class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = true.obs;
  final hasUnread = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();

    // If the token changes/refreshes, refetch automatically
    ever(AuthService.tokenRefreshCount, (_) {
      // ignore if the controller is not mounted anymore
      if (!Get.isRegistered<NotificationController>()) return;
      fetchNotifications(silentAuthErrors: true);
    });
  }

  Future<void> _init() async {
    await AuthService.waitForToken();                // <-- wait for a real token
    await fetchNotifications(silentAuthErrors: true); // <-- no toast on 401 at boot
  }

  Future<void> fetchNotifications({bool silentAuthErrors = false}) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.notifications,
        token: AuthService.accessToken,
        // Optional if your NetworkCaller supports it:
        // treat404AsEmpty: true,
        // emptyPayload: const [],
      );

      if (response.isSuccess && response.responseData is List) {
        final List<dynamic> responseData = response.responseData;
        notifications.value = responseData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        _updateUnreadStatus();
        return;
      }

      // Suppress startup noise when auth isn't ready yet
      final sc = response.statusCode ?? 0;
      if (silentAuthErrors && (sc == 401 || sc == 403)) {
        notifications.clear();
        hasUnread.value = false;
        return;
      }

      AppSnackBar.showError(
        response.errorMessage ?? "Failed to load notifications.",
      );
    } catch (e) {
      if (silentAuthErrors) {
        // quiet on boot; just clear state
        notifications.clear();
        hasUnread.value = false;
      } else {
        AppSnackBar.showError('An error occurred: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    // Exit if the notification is not found or is already marked as read
    if (index == -1 || notifications[index].isRead) {
      return;
    }

    // Keep a copy of the original notification in case we need to revert
    final originalNotification = notifications[index];

    // 1. Optimistically update the UI for a snappy feel
    notifications[index] = NotificationModel(
      id: originalNotification.id,
      message: originalNotification.message,
      notificationType: originalNotification.notificationType,
      data: originalNotification.data,
      isRead: true, // Set to read
      createdAt: originalNotification.createdAt,
    );
    notifications.refresh();

    // 2. Call the backend API to update the server state
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.markNotificationAsRead(notificationId),
        token: AuthService.accessToken,
      );

      // 3a. If the API call fails, revert the UI change and show an error
      if (!response.isSuccess) {
        _updateUnreadStatus();
        notifications[index] = originalNotification;
        notifications.refresh();
        AppSnackBar.showError(
          response.errorMessage ?? "Failed to mark as read. Please try again.",
        );
      }
      // 3b. If the API call succeeds, we don't need to do anything else.
    } catch (e) {
      // 3c. If a network error occurs, revert the change and show an error
      notifications[index] = originalNotification;
      notifications.refresh();
      AppSnackBar.showError("An error occurred: $e");
    }
  }
  
  void _updateUnreadStatus() {
    hasUnread.value = notifications.any((n) => !n.isRead);
  }
}