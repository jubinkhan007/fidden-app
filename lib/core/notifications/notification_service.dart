// lib/core/notifications/notification_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../features/business_owner/home/controller/business_owner_controller.dart';
import '../../features/inbox/screens/chat_screen.dart';
import '../../features/user/booking/controller/booking_controller.dart';
import '../../features/user/booking/presentation/screens/booking_details_screen.dart';
import '../../routes/app_routes.dart';
import '../services/Auth_service.dart';

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
    const initSettings = InitializationSettings(
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
          handlePayloadTap(data);
        } catch (_) {}
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
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
    final type = (data['type'] ?? '').toString();
    final action = (data['action'] ?? '').toString();
    final slotId = data['slot_id']?.toString();
    final bookingId = data['booking_id']?.toString();

    if (type == 'autofill_offer' &&
        action == 'book_offer' &&
        slotId != null &&
        slotId.isNotEmpty) {
      // Build the label from ISO so your _slotFmt parser isn't needed here
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

      // Map to the BookingSummaryScreen's expected arguments
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
          'shop_id': toInt(data['shop_id']) ?? 0,
          'service_id': toInt(data['service_id']) ?? 0,
        },
        // optional: preload block (empty for now—can be used to seed slot chips)
        'preload': const <String, dynamic>{},
      };

      Get.toNamed(
        AppRoute.bookingSummaryScreen,
        arguments: args,
      ); // e.g., '/booking-summary'
      return;
    }

    // --- CHAT MESSAGE NOTIFICATION HANDLING ---
    // When user taps on a chat notification, navigate to chat screen
    if (type == 'chat' ||
        type == 'chat_message' ||
        type == 'notification' ||
        type == 'message') {
      final threadId = int.tryParse('${data['thread_id'] ?? 0}') ?? 0;
      final shopId = int.tryParse('${data['shop_id'] ?? 0}') ?? 0;
      final shopName =
          data['shop_name']?.toString() ??
          data['sender_email']?.toString() ??
          'Chat';
      final isOwner =
          data['is_owner']?.toString().toLowerCase() == 'true' ||
          AuthService.role?.toLowerCase() == 'owner';

      if (threadId > 0) {
        Get.to(
          () => ChatScreen(
            threadId: threadId,
            shopId: shopId,
            shopName: shopName,
            shopAvatarUrl: '',
            isOwner: isOwner,
          ),
        );
        return;
      }
    }
    // --- END CHAT MESSAGE NOTIFICATION HANDLING ---

    // --- CHECKOUT NOTIFICATION HANDLING ---
    // When owner initiates checkout, customer receives this notification type
    if (type == 'checkout_ready' || type == 'checkout_initiated') {
      if (bookingId != null && bookingId.isNotEmpty) {
        final id = int.tryParse(bookingId);
        if (id != null) {
          Get.toNamed(AppRoute.checkoutScreen, arguments: {'bookingId': id});
          return;
        }
      }
    }
    // --- END CHECKOUT NOTIFICATION HANDLING ---

    // --- CHECKOUT COMPLETED HANDLER (Owner receives when customer pays) ---
    if (type == 'checkout_completed') {
      // Refresh the owner's bookings list so the "Checkout Customer" button disappears
      if (Get.isRegistered<BusinessOwnerController>()) {
        Get.find<BusinessOwnerController>().fetchBusinessOwnerBooking();
      }

      // Show confirmation snackbar
      final customerEmail = data['customer_email']?.toString() ?? 'Customer';
      final totalPaid = data['total_paid']?.toString() ?? '';
      final tipAmount = data['tip_amount']?.toString();

      String message = 'Payment received from $customerEmail';
      if (totalPaid.isNotEmpty) {
        message += ' - \$$totalPaid';
        if (tipAmount != null &&
            tipAmount.isNotEmpty &&
            tipAmount != '0' &&
            tipAmount != '0.0') {
          message += ' (includes \$$tipAmount tip)';
        }
      }

      Get.snackbar(
        'Payment Completed ✓',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    // --- END CHECKOUT COMPLETED HANDLER ---

    // --- BOOKING REMINDER HANDLING (Customer) ---
    // Handles specific 'reminder' type OR generic notifications with a booking ID
    // that don't match other types handled above.
    if (type == 'reminder' ||
        type == 'booking_reminder' ||
        (type == 'notification' && bookingId != null)) {
      final bId = int.tryParse(bookingId ?? '');

      // If we have a booking ID, try to fetch and show it
      if (bId != null && bId > 0) {
        _handleBookingNavigation(bId);
        return;
      }
    }
    // --- END BOOKING REMINDER HANDLING ---

    // Deep link/web fallbacks (optional)
    final deeplink = data['deeplink']?.toString();
    final url = data['url']?.toString();
    if (deeplink != null && deeplink.isNotEmpty) {
      launchUrlString(deeplink, mode: LaunchMode.externalApplication);
      return;
    }
    if (url != null && url.isNotEmpty) {
      launchUrlString(url, mode: LaunchMode.externalApplication);
      return;
    }
  }

  /// Helper to fetch booking and navigate
  static Future<void> _handleBookingNavigation(int bookingId) async {
    // 1. Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 2. Ensure Auth is ready (critical for background/terminated launches)
      await AuthService.getValidAccessToken();

      // 3. Fetch booking details
      // Ensure controller is available (it might not be if app was terminated)
      final controller = Get.isRegistered<BookingController>()
          ? Get.find<BookingController>()
          : Get.put(BookingController());

      final booking = await controller.fetchBookingById(bookingId);

      // 4. Dismiss loading
      if (Get.isDialogOpen ?? false) Get.back();

      // 5. Navigate if successful
      if (booking != null) {
        Get.to(() => BookingDetailsScreen(booking: booking));
      } else {
        // Optional: show error or just open bookings list
        Get.snackbar(
          'Booking Not Found',
          'Could not retrieve details for booking #$bookingId',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Dismiss loading on error
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error navigating to booking: $e');
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

    print(
      '[NOTIF DEBUG] showMessage called: title="$title", body="$body", uniqueId=$uniqueId',
    );

    // --- DE-DUPLICATION CHECK ---
    // If we have a unique ID and we've already seen it, ignore this call.
    if (uniqueId != null && uniqueId.isNotEmpty) {
      if (_seenIds.contains(uniqueId)) {
        print(
          "[NOTIF DEBUG] Duplicate notification ignored with ID: $uniqueId",
        );
        return; // Stop processing
      }
      // Clean up the cache to prevent it from growing indefinitely.
      if (_seenIds.length > 200) _seenIds.clear();
      _seenIds.add(uniqueId);
    }
    // --- END DE-DUPLICATION CHECK ---

    print('[NOTIF DEBUG] Showing notification...');

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
