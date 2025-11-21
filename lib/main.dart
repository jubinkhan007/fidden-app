//lib/main.dart
import 'dart:async';
import 'dart:ui';
import 'package:fidden/core/deeplinks/deep_link_service.dart';
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
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> _bg(RemoteMessage m) => firebaseMessagingBackgroundHandler(m);

Future<void> main() async {
  // Use runZonedGuarded to catch all errors in the same zone.
  runZonedGuarded(() async {
    // Ensure bindings are initialized inside the zone.
    WidgetsFlutterBinding.ensureInitialized();

    // Set up global error handlers
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
      if (details.stack != null) {
        debugPrint('STACK:\n${details.stack}');
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('⚠️ Platform/Zone error: $error');
      debugPrint('STACK:\n$stack');
      return false; // Let it propagate in debug
    };

    // Initialize Firebase and other services before runApp
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_bg);

    Stripe.publishableKey =
    'pk_test_51SUjSZPvn52W2hluUeYJXFyQPFsXXBwwfB4KhWszroRPBhPx5lROrON6mYvQIAhtnWAaEo813nTRUbYUjvi2CUtW0048Gm4z91';

    // Run the app
    runApp(const MyApp());

    // Initialize other services without blocking startup
    unawaited(_postBootInit());

  }, (Object error, StackTrace stack) {
    debugPrint('⚠️ Uncaught in zone: $error');
    debugPrint('STACK:\n$stack');
  });
}



Future<void> _postBootInit() async {
  try {
    debugPrint('[boot] NotificationService.init');
    await NotificationService.I.init().timeout(const Duration(seconds: 10));
    await NotificationService.I.requestSystemPermissionIfNeeded(); // ← add this
    final p = await Permission.notification.status;
    debugPrint('📣 POST_NOTIFICATIONS status: $p');
  } catch (e, st) { debugPrint('[boot] NotificationService failed: $e\n$st'); }

  try {
    debugPrint('[boot] initPush');
    await initPush().timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] initPush failed: $e\n$st'); }

  try {
    debugPrint('[boot] GoogleSignIn.initialize');
    await GoogleSignIn.instance.initialize(
      serverClientId: '7724...153.apps.googleusercontent.com',
    ).timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] Google init failed: $e\n$st'); }

  try {
    debugPrint('[boot] AuthService.init');
    await AuthService.init().timeout(const Duration(seconds: 10));
  } catch (e, st) { debugPrint('[boot] AuthService failed: $e\n$st'); }

  // 🔗 Deep links (after DI/auth is ready so controllers exist)
  try {
    debugPrint('[boot] DeepLinkService.init');
    await Get.put(DeepLinkService(), permanent: true).init();
  } catch (e, st) { debugPrint('[boot] DeepLinkService failed: $e\n$st'); }

  try {
    debugPrint('[boot] WsService.ensureConnected');
    Get.put(WsService(), permanent: true).ensureConnected();
  } catch (e, st) { debugPrint('[boot] WS failed: $e\n$st'); }

  debugPrint('[boot] complete');
}