import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Background handler — must be a top-level or static function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("---------- FCM BACKGROUND HANDLER FIRED! ----------");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DartPluginRegistrant.ensureInitialized();

  await NotificationService.I.init();
  await _showFromRemoteMessage(message);
}

Future<void> initPush() async {
  // iOS permission
  if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    // Optionally check settings.authorizationStatus
  }

  // When app is foreground, show banners using local notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if (message.notification != null) return;
    await _showFromRemoteMessage(message);
  });

  // When app was background and user taps the banner
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    // We rely on payload/tap handler inside NotificationService too,
    // but for "notification" messages (auto-shown by system), use this to navigate:
    // final data = message.data;
    // NotificationService._handlePayloadTap(data); // (make it public if you prefer)
  });

  // When app is launched by tapping a push while terminated
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    // Same as above: navigate to the chat
    // NotificationService._handlePayloadTap(initial.data);
  }

  // Ensure foreground presentation on iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Background handler
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// Extract title/body/thread/message from your backend payload and show
Future<void> _showFromRemoteMessage(RemoteMessage message) async {
  await NotificationService.I.init();

  final data = message.data; // prefer sending DATA-only pushes from backend
  // If backend also uses 'notification' payload, you can fallback:
  final title =
      data['title']?.toString() ??
      message.notification?.title ??
      (data['shop_name']?.toString() ??
          data['sender_email']?.toString() ??
          'New message');

  final body =
      data['body']?.toString() ??
      message.notification?.body ??
      data['content']?.toString() ??
      'You have a new message';

  final uniqueId = data['message_id']
      ?.toString(); // use server message id to dedupe

  // Put everything you need for navigation into payload
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
    uniqueId: uniqueId,
  );
}
