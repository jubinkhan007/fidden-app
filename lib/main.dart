import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fidden/app.dart';
import 'package:fidden/core/notifications/notification_service.dart';
import 'package:fidden/core/notifications/push.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/permission_handler.dart';
import 'package:fidden/core/ws/ws_service.dart';

@pragma('vm:entry-point')
Future<void> _bg(RemoteMessage m) => firebaseMessagingBackgroundHandler(m);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51S56r33eKAUTJHyfzxn8z3GbxLpdNdl2ynBLGoLwEOx4bR2qoJdWwt6CWYoFzu3lPlHfBikm5gt0DqhA49w3Nj4700TIDOqiGr';

  // Only the absolute minimum before UI:
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_bg);

  // Show the app immediately
  runApp(const MyApp());

  // Then do the rest without blocking startup
  // (log each step + add timeouts so nothing hangs forever)
  unawaited(_postBootInit());
}

Future<void> _postBootInit() async {
  try {
    debugPrint('[boot] NotificationService.init');
    await NotificationService.I.init().timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] NotificationService failed: $e\n$st'); }

  // try {
  //   debugPrint('[boot] Request notification permission');
  //   final permissionController = Get.put(PermissionController());
  //   // don't await if it may show a dialog
  //   permissionController.requestNotificationPermission();
  // } catch (e, st) { debugPrint('[boot] permission failed: $e\n$st'); }

  try {
    debugPrint('[boot] initPush');
    await initPush().timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] initPush failed: $e\n$st'); }

  try {
    debugPrint('[boot] GoogleSignIn.initialize');
    await GoogleSignIn.instance.initialize(
      serverClientId: '772435903240-ggmvqdtveoq8i717jgiksor33v00s153.apps.googleusercontent.com',
    ).timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] Google init failed: $e\n$st'); }

  try {
    debugPrint('[boot] AuthService.init');
    await AuthService.init().timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] AuthService failed: $e\n$st'); }

  try {
    debugPrint('[boot] WsService.ensureConnected');
    Get.put(WsService(), permanent: true).ensureConnected(); // not awaited
  } catch (e, st) { debugPrint('[boot] WS failed: $e\n$st'); }

  debugPrint('[boot] complete');
}
