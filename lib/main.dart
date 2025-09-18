import 'dart:ui';

import 'package:fidden/app.dart';
import 'package:fidden/core/notifications/notification_service.dart';
import 'package:fidden/core/notifications/push.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/permission_handler.dart';
import 'package:fidden/core/ws/ws_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

@pragma('vm:entry-point') // keep as well on the handler itself
Future<void> _bg(RemoteMessage m) => firebaseMessagingBackgroundHandler(m);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51S56r33eKAUTJHyfzxn8z3GbxLpdNdl2ynBLGoLwEOx4bR2qoJdWwt6CWYoFzu3lPlHfBikm5gt0DqhA49w3Nj4700TIDOqiGr';

  await Firebase.initializeApp();
  DartPluginRegistrant.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_bg);

  await NotificationService.I.init();
  final permissionController = Get.put(PermissionController());

  // Now, request the permission using the controller
  permissionController.requestNotificationPermission();

  await initPush(); // FCM handlers
  // Initialize Google Sign-In
  await GoogleSignIn.instance.initialize(
    // Get this from your Google Cloud Console for your project
    serverClientId:
        '772435903240-ggmvqdtveoq8i717jgiksor33v00s153.apps.googleusercontent.com',
  );

  await AuthService.init();
  Get.put(WsService(), permanent: true).ensureConnected();
  runApp(const MyApp());
}
