import 'dart:ui';

import 'package:fidden/app.dart';
import 'package:fidden/core/notifications/notification_service.dart';
import 'package:fidden/core/notifications/push.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/ws/ws_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

@pragma('vm:entry-point') // keep as well on the handler itself
Future<void> _bg(RemoteMessage m) => firebaseMessagingBackgroundHandler(m);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  DartPluginRegistrant.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_bg);

  await NotificationService.I.init();
  await NotificationService.I.requestSystemPermissionIfNeeded();
  await initPush(); // FCM handlers
  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize(
    // Get this from your Google Cloud Console for your project
    serverClientId:
        '910463978621-34r0n3pbn9rq81ort6fgcglef6hbnu3a.apps.googleusercontent.com',
  );

  await AuthService.init();
  Get.put(WsService(), permanent: true).ensureConnected();
  runApp(const MyApp());
}
