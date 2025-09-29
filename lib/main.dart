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

@pragma('vm:entry-point')
Future<void> _bg(RemoteMessage m) => firebaseMessagingBackgroundHandler(m);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Framework errors (build/layout/paint etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Forward to Flutter's default (prints red screen in debug),
    // but ALSO print the stack so you see the exact file:line.
    FlutterError.presentError(details);
    debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint('STACK:\n${details.stack}');
    }
  };

  // 2) Uncaught async errors on the engine/platform side
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('⚠️ Platform/Zone error: $error');
    debugPrint('STACK:\n$stack');
    // return true if you consider it "handled" and want to prevent crash
    return false; // let it propagate in debug
  };

  // 3) Catch everything else in the zone (timers/streams/futures)
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    debugPrint('⚠️ Uncaught in zone: $error');
    debugPrint('STACK:\n$stack');
  });
  Stripe.publishableKey = 'pk_test_51S56r33eKAUTJHyfzxn8z3GbxLpdNdl2ynBLGoLwEOx4bR2qoJdWwt6CWYoFzu3lPlHfBikm5gt0DqhA49w3Nj4700TIDOqiGr';

  // Only the absolute minimum before UI:
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_bg);
FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // print a full stack to console
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
  };

  // Then do the rest without blocking startup
  // (log each step + add timeouts so nothing hangs forever)
  unawaited(_postBootInit());
}



Future<void> _postBootInit() async {
  try {
    debugPrint('[boot] NotificationService.init');
    await NotificationService.I.init().timeout(const Duration(seconds: 10));
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