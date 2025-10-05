// lib/core/notifications/notification_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/inbox/screens/chat_screen.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fidden_messages', // must match manifest meta-data
    'Messages',
    description: 'Incoming chat messages',
    importance: Importance.high,
  );

  bool _initialized = false;

  // --- START: ESSENTIAL DE-DUPLICATION LOGIC ---
  // A small cache to store recent message IDs. This prevents duplicate notifications
  // if an event arrives from both FCM and WebSocket, or if a hybrid FCM payload
  // is processed by both the OS and our background handler.
  final Set<String> _seenIds = <String>{};
  // --- END: ESSENTIAL DE-DUPLICATION LOGIC ---

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (r) {
        final payload = r.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          handlePayloadTap(data);
        } catch (_) {}
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  // Your requestSystemPermissionIfNeeded method remains the same...
  Future<void> requestSystemPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      // iOS permissions are requested in initPush()
    }
  }

  /// Foreground/Background/Terminated tap handling
  static void handlePayloadTap(Map<String, dynamic> data) {
    // This is where you will implement navigation when a notification is tapped.
    // Example:
    // final threadId = int.tryParse('${data["thread_id"]}') ?? -1;
    // if (threadId != -1) {
    //   Get.to(() => ChatScreen(...));
    // }
  }

  /// Show a message notification — call from FCM or WS
  Future<void> showMessage({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String? uniqueId, // e.g., message_id for de-dupe
  }) async {
    await init();

    // --- DE-DUPLICATION CHECK ---
    // If we have a unique ID and we've already seen it, ignore this call.
    if (uniqueId != null && uniqueId.isNotEmpty) {
      if (_seenIds.contains(uniqueId)) {
        print("Duplicate notification ignored with ID: $uniqueId");
        return; // Stop processing
      }
      // Clean up the cache to prevent it from growing indefinitely.
      if (_seenIds.length > 200) _seenIds.clear();
      _seenIds.add(uniqueId);
    }
    // --- END DE-DUPLICATION CHECK ---

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: const DefaultStyleInformation(true, true),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final nDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final id = uniqueId == null
        ? DateTime.now().millisecondsSinceEpoch ~/ 1000
        : uniqueId.hashCode;

    await _fln.show(id, title, body, nDetails, payload: jsonEncode(payload));
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse r) {
  // no-op; navigation is handled in onDidReceiveNotificationResponse.
}