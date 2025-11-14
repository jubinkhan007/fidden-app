// lib/core/deeplinks/deep_link_service.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/routes/app_routes.dart';

import '../../features/user/shops/presentation/screens/shop_details_screen.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  static const _kLastCheckoutSid = 'last_checkout_session_id';

  bool _handledInitial = false;
  Uri? _lastUri;
  DateTime? _lastHandledAt;
  // Guards to stop re-entry / re-push
  bool watchdogArmed = false;
  String? _expectedRoute;
  DateTime? suppressDeepLinkUntil;

  bool get _isSuppressed =>
      suppressDeepLinkUntil != null &&
          DateTime.now().isBefore(suppressDeepLinkUntil!);
  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    // 1) Cold start
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _handleUri(uri);        // handle cold-start
        _handledInitial = true;
        suppressDeepLinkUntil = DateTime.now().add(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('[deeplink] getInitialLink error: $e');
    }

// ✅ ALWAYS handle stream events
    _sub = _appLinks.uriLinkStream.listen(
          (uri) async {
        await _handleUri(uri);
      },
      onError: (err) => debugPrint('[deeplink] stream error: $err'),
      cancelOnError: false,
    );

    return this;
  }




  Future<void> _handleUri(Uri uri) async {
    debugPrint('[deeplink] $uri');

    // NEW: short cool-off after we just handled a deep link
    if (_isSuppressed) {
      debugPrint('[deeplink] suppressed duplicate within cooldown');
      return;
    }

    // Debounce: ignore exact same URI within 1s
    final now = DateTime.now();
    if (_lastUri?.toString() == uri.toString() &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastUri = uri;
    _lastHandledAt = now;

    // ---------- Subscription ----------
    final isSubscription = (uri.scheme == 'myapp' || uri.scheme == 'fidden') &&
        uri.host == 'subscription';
    if (isSubscription) {
      final path = uri.path; // '/success' or '/cancel'
      final prefs = await SharedPreferences.getInstance();

      if (path == '/success') {
        final sid = uri.queryParameters['session_id'] ?? '';
        final lastSid = prefs.getString(_kLastCheckoutSid);
        if (sid.isNotEmpty && sid == lastSid) return;
        if (sid.isNotEmpty) await prefs.setString(_kLastCheckoutSid, sid);

        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          await Get.find<BusinessOwnerProfileController>()
              .checkStripeStatusIfPossible();
        }
        Get.snackbar('Subscription', 'Purchase completed');
        return;
      }

      if (path == '/cancel') {
        Get.snackbar('Subscription', 'Checkout cancelled');
        return;
      }
    }
    final isShopScheme = uri.scheme == 'fidden' && uri.host == 'shop' && uri.pathSegments.isNotEmpty;
    // ---------- Stripe onboarding ----------
    final isStripeOnboarding =
        (uri.scheme == 'myapp' || uri.scheme == 'fidden') &&
            uri.host == 'stripe';
    if (isStripeOnboarding) {
      if (uri.path == '/return') {
        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          Get.find<BusinessOwnerProfileController>()
              .checkStripeStatusIfPossible();
        }
        Get.snackbar('Stripe', 'Onboarding flow returned to app');
      } else if (uri.path == '/refresh') {
        Get.snackbar('Stripe', 'Onboarding not completed. You can retry.');
      }
      return;
    }

    // ============================
    // BOOKING SUMMARY
    // fidden://book/{bookingId}
    // https://your-app.com/book/{bookingId}
    // ============================
    final isBookScheme =
        uri.scheme == 'fidden' && uri.host == 'book' && uri.pathSegments.isNotEmpty;
    final isBookWeb =
        uri.scheme == 'https' &&
            uri.host == 'your-app.com' &&
            uri.pathSegments.isNotEmpty &&
            uri.pathSegments.first == 'book' &&
            uri.pathSegments.length >= 2;

    if (isBookScheme || isBookWeb) {
      final idStr = isBookScheme ? uri.pathSegments.first : uri.pathSegments[1];
      final bookingId = int.tryParse(idStr);
      if (bookingId != null) {
        await _openBookingSummarySticky(bookingId);
        return;
      }
    }

    // ============================
    // SERVICE DETAILS
    // fidden://service/{serviceId}[?shop_id=..&coupon=..]
    // https://your-app.com/services/{serviceId}[?shop_id=..&coupon=..]
    // ============================
    final isServiceScheme =
        uri.scheme == 'fidden' && uri.host == 'service' && uri.pathSegments.isNotEmpty;
    final isServiceWeb =
        uri.scheme == 'https' &&
            uri.host == 'your-app.com' &&
            uri.pathSegments.isNotEmpty &&
            uri.pathSegments.first == 'services' &&
            uri.pathSegments.length >= 2;

    if (isServiceScheme || isServiceWeb) {
      final idStr = isServiceScheme ? uri.pathSegments.first : uri.pathSegments[1];
      final serviceId = int.tryParse(idStr);
      if (serviceId != null) {
        final shopId = int.tryParse(uri.queryParameters['shop_id'] ?? '');
        final coupon = uri.queryParameters['coupon'];
        await _openServiceDetailsSticky(serviceId: serviceId, shopId: shopId, coupon: coupon);
        return;
      }
    }
    if (isShopScheme) {
      final shopIdStr = uri.pathSegments.first;
      final shopId = int.tryParse(shopIdStr); // Extract the shop ID from the deep link
      if (shopId != null) {
        await _openShopDetailsSticky(shopId); // Navigate to ShopDetailsScreen
      }
    }

  }

  // ---------- Sticky nav helpers (fight Home re-push) ----------

  Future<void> _openBookingSummarySticky(int bookingId) async {
    // Make it root so Home can't pop above it
    await Future.delayed(const Duration(milliseconds: 60));
    await _offAllTo(
      AppRoute.bookingSummaryScreen,
      arguments: {
        'bookingId': bookingId,
        'booking': {'shop_id': 0, 'service_id': 0},
        'preload': const <String, dynamic>{},
      },
    );
    // If Home still races us, re-push once.
    await _watchdogEnsureTop(expected: AppRoute.bookingSummaryScreen, repush: () async {
      await _offAllTo(
        AppRoute.bookingSummaryScreen,
        arguments: {
          'bookingId': bookingId,
          'booking': {'shop_id': 0, 'service_id': 0},
          'preload': const <String, dynamic>{},
        },
      );
    });
  }

  Future<void> _openServiceDetailsSticky({
    required int serviceId,
    int? shopId,
    String? coupon,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
    // Use the named route we registered so we can offAllNamed
    await _offAllTo(
      AppRoute.serviceDetailsScreen,
      arguments: {
        'serviceId': serviceId,
        if (shopId != null) 'shopId': shopId,
        if (coupon != null && coupon.isNotEmpty) 'coupon': coupon,
      },
    );
    await _watchdogEnsureTop(expected: AppRoute.serviceDetailsScreen, repush: () async {
      await _offAllTo(
        AppRoute.serviceDetailsScreen,
        arguments: {
          'serviceId': serviceId,
          if (shopId != null) 'shopId': shopId,
          if (coupon != null && coupon.isNotEmpty) 'coupon': coupon,
        },
      );
    });
  }

  Future<void> _offAllTo(String route, {Map<String, dynamic>? arguments}) async {
    try {
      // Ensure a base
      await Get.offAllNamed(AppRoute.landingScreen);

      // let landing settle
      await Future.delayed(const Duration(milliseconds: 60));

      // push target
      await Get.toNamed(route, arguments: arguments);

      // ARM watchdog just once for this deep-link session
      watchdogArmed = true;
      _expectedRoute = route;

      // NEW: cool-off to ignore duplicate link emissions from system
      suppressDeepLinkUntil = DateTime.now().add(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[deeplink] offAllTo($route) failed: $e');
      try {
        await Get.offAllNamed(route, arguments: arguments);
        watchdogArmed = true;
        _expectedRoute = route;
        suppressDeepLinkUntil = DateTime.now().add(const Duration(seconds: 5));
      } catch (_) {}
    }
  }


  Future<void> _watchdogEnsureTop({
    required String expected,
    required Future<void> Function() repush,
  }) async {
    // Only act if we armed it for this deep-link
    if (!watchdogArmed) return;

    await Future.delayed(const Duration(milliseconds: 700));

    // If user already navigated (there is a previous route), don't fight them
    if (Get.previousRoute.isNotEmpty) {
      watchdogArmed = false;
      return;
    }

    if (Get.currentRoute != expected && watchdogArmed) {
      // One corrective re-push max
      await Future.delayed(const Duration(milliseconds: 200));
      await repush();
    }

    // Disarm after first attempt (success or not)
    watchdogArmed = false;
  }


  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
  Future<void> _openShopDetailsSticky(int shopId) async {
    await Future.delayed(const Duration(milliseconds: 60));
    await Get.offAllNamed(AppRoute.landingScreen);
    await Future.delayed(const Duration(milliseconds: 60));
    await Get.to(() => ShopDetailsScreen(id: shopId.toString()));
    watchdogArmed = true;
    _expectedRoute = AppRoute.shopDetailsScreen; // optional label
    suppressDeepLinkUntil = DateTime.now().add(const Duration(seconds: 5));
  }

}


