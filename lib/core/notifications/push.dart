// lib/core/notifications/push.dart

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'notification_service.dart';

/// Background handler — must be a top-level or static function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[PUSH DEBUG] Background handler received: data=${message.data}, notification=${message.notification?.title}');
  // If backend sent a notification block, let OS show it. Do not mirror.
  if (message.notification != null) {
    print('[PUSH DEBUG] Background: Has notification block, letting OS handle');
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DartPluginRegistrant.ensureInitialized();

  await NotificationService.I.init();
  await _showFromRemoteMessage(message);
}

Future<void> initPush() async {
  // iOS permission
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // When app is in the FOREGROUND, listen for messages.
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('[PUSH DEBUG] Foreground received: data=${message.data}, notification=${message.notification?.title}');
    // Foreground duplicate guard: ignore notification-messages.
    if (message.notification != null) {
      print('[PUSH DEBUG] Foreground: Has notification block, skipping (OS handles)');
      return;
    }
    await _showFromRemoteMessage(message);
  });

  // When app was in the BACKGROUND and user taps the banner.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Navigation logic can be handled here or in NotificationService.
    final data = message.data;
    debugPrint('[push] onMessageOpenedApp: ${message.data}');
    NotificationService.handlePayloadTap(data);
  });

  // When app is launched from TERMINATED by tapping a push notification.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    debugPrint('[push] getInitialMessage: ${initial.data}');
    NotificationService.handlePayloadTap(initial.data);
  }

  // Ensure foreground presentation options are set for iOS.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // --- CRITICAL FIX ---
  // This line registers your handler. It's often placed in main.dart, but
  // having it here ensures it's set up whenever push notifications are initialized.
  // Your main.dart already registers it, which is correct. This is for robustness.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// A helper function to parse the message and show a local notification.
Future<void> _showFromRemoteMessage(RemoteMessage message) async {
  await NotificationService.I.init();

  final data = message.data;
  // assume data-only; if missing, bail (prevents duplicating notification messages)
  if (data.isEmpty) return;

  final title = data['title']?.toString()
      ?? data['shop_name']?.toString()
      ?? data['sender_email']?.toString()
      ?? 'New message';

  final body  = data['body']?.toString()
      ?? data['content']?.toString()
      ?? 'You have a new message';

  final uniqueId = data['message_id']?.toString();

  // Use consistent ID format with 'msg_' prefix to dedup across all sources
  final dedupId = uniqueId != null && uniqueId.isNotEmpty ? 'msg_$uniqueId' : null;

  await NotificationService.I.showMessage(
    title: title,
    body: body,
    payload: {
      'type': data['type'] ?? 'chat_message',
      'thread_id': data['thread_id'],
      'message_id': data['message_id'],
      'shop_id': data['shop_id'],
      'shop_name': data['shop_name'],
      'sender_email': data['sender_email'],
      'is_owner': data['is_owner'],
      'content': data['content'],
    },
    uniqueId: dedupId,
  );
}
