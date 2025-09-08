import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService I = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fidden_messages', // must match manifest meta-data
    'Messages',
    description: 'Incoming chat messages',
    importance: Importance.high,
  );

  bool _initialized = false;
  // small LRU-ish set to prevent duplicate banners from WS/FCM
  final Set<String> _seenIds = <String>{};

  Future<void> init() async {
    if (_initialized) return;

    // Android init (use your monochrome small icon if you added one)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init
    const iosInit = DarwinInitializationSettings();

    final initSettings = const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (r) {
        final payload = r.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _handlePayloadTap(data);
        } catch (_) {}
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create channel (Android 8+)
    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  /// Call this once on app start (after [init]) to request runtime perms.
  Future<void> requestSystemPermissionIfNeeded() async {
    // This single line handles both Android and iOS permission requests.
    final status = await Permission.notification.request();

    // You can optionally check the status and handle different outcomes
    if (status.isGranted) {
      print("Notification permission granted.");
    } else if (status.isDenied) {
      print("Notification permission denied.");
    } else if (status.isPermanentlyDenied) {
      print(
        "Notification permission permanently denied. Opening app settings.",
      );
      // This will open the app's settings page for the user to manually enable permissions.
      await openAppSettings();
    }
  }

  /// Foreground/Background/Terminated tap handling
  static void _handlePayloadTap(Map<String, dynamic> data) {
    // Example navigation:
    // final threadId = int.tryParse('${data["thread_id"]}') ?? -1;
    // final shopId = int.tryParse('${data["shop_id"] ?? 0}') ?? 0;
    // final shopName = data["shop_name"]?.toString()
    //     ?? data["sender_email"]?.toString() ?? 'Chat';
    // final isOwner = (data["is_owner"]?.toString().toLowerCase() == 'true');
    // Get.to(() => ChatScreen(
    //   threadId: threadId, shopId: shopId, shopName: shopName, isOwner: isOwner,
    // ));
  }

  /// Show a message notification — call from FCM or WS
  Future<void> showMessage({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
    String? uniqueId, // e.g. message_id for de-dupe
  }) async {
    await init();

    // de-dupe: if we saw this message_id already, ignore
    if (uniqueId != null && uniqueId.isNotEmpty) {
      if (_seenIds.contains(uniqueId)) return;
      if (_seenIds.length > 200) _seenIds.clear();
      _seenIds.add(uniqueId);
    }

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

    final nDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a stable integer ID if you want updates to replace previous
    final id = uniqueId == null
        ? DateTime.now().millisecondsSinceEpoch ~/ 1000
        : uniqueId.hashCode;

    await _fln.show(id, title, body, nDetails, payload: jsonEncode(payload));
  }
}

/// Required for background action taps on Android 14+
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse r) {
  // no-op; navigation is resumed in onDidReceive… after app is resumed
}
