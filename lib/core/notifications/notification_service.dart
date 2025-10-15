// lib/core/notifications/notification_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../features/inbox/screens/chat_screen.dart';
import '../../routes/app_routes.dart';

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
    final type     = (data['type'] ?? '').toString();
    final action   = (data['action'] ?? '').toString();
    final slotId   = data['slot_id']?.toString();

    if (type == 'autofill_offer' && action == 'book_offer' && slotId != null && slotId.isNotEmpty) {
      // Build the label from ISO so your _slotFmt parser isn’t needed here
      String selectedSlotLabel = '';
      final iso = data['start_time']?.toString();
      if (iso != null && iso.isNotEmpty) {
        final dt = DateTime.tryParse(iso)?.toLocal();
        if (dt != null) {
          selectedSlotLabel = DateFormat('MMMM d, yyyy, h.mm a').format(dt);
        }
      }

      // Parse numbers safely
      int? toInt(dynamic v) => int.tryParse('$v');
      double? toDouble(dynamic v) => double.tryParse('$v');

      // Map to the BookingSummaryScreen’s expected arguments
      final args = <String, dynamic>{
        'serviceName': data['serviceName'] ?? '',
        'service_img': data['service_img'] ?? '',
        'shopName': data['shopName'] ?? '',
        'shopAddress': data['shopAddress'] ?? '',
        'serviceDurationMinutes': toInt(data['serviceDurationMinutes']) ?? 0,
        'selectedSlotLabel': selectedSlotLabel,
        'price': toDouble(data['price']) ?? 0.0,
        'discountPrice': toDouble(data['discountPrice']),
        // IMPORTANT: your screen uses "bookingId" as *slot id* for paymentIntent(slotId)
        'bookingId': toInt(slotId) ?? 0,
        // You also look up shop/service IDs in a nested "booking" object:
        'booking': {
          'shop_id'   : toInt(data['shop_id']) ?? 0,
          'service_id': toInt(data['service_id']) ?? 0,
        },
        // optional: preload block (empty for now—can be used to seed slot chips)
        'preload': const <String, dynamic>{},
      };

      Get.toNamed(AppRoute.bookingSummaryScreen, arguments: args); // e.g., '/booking-summary'
      return;
    }

    // Deep link/web fallbacks (optional)
    final deeplink = data['deeplink']?.toString();
    final url      = data['url']?.toString();
    if (deeplink != null && deeplink.isNotEmpty) {
      launchUrlString(deeplink, mode: LaunchMode.externalApplication);
      return;
    }
    if (url != null && url.isNotEmpty) {
      launchUrlString(url, mode: LaunchMode.externalApplication);
      return;
    }
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