// lib/core/deeplinks/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/routes/app_routes.dart'; // <-- make sure this exports AppRoute.bookingSummaryScreen

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  static const _kLastCheckoutSid = 'last_checkout_session_id';

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    // 1) Cold start
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) await _handleUri(uri);
    } catch (e) {
      debugPrint('[deeplink] getInitialLink error: $e');
    }

    // 2) Warm/foreground
    _sub = _appLinks.uriLinkStream.listen(
          (uri) => _handleUri(uri),
      onError: (err) => debugPrint('[deeplink] stream error: $err'),
      cancelOnError: false,
    );

    return this;
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint('[deeplink] $uri');

    // ---------- Subscription deep links (unchanged) ----------
    final isSubscription = (uri.scheme == 'myapp' || uri.scheme == 'fidden') && uri.host == 'subscription';
    if (isSubscription) {
      final path = uri.path; // '/success' or '/cancel'
      final prefs = await SharedPreferences.getInstance();

      if (path == '/success') {
        final sid = uri.queryParameters['session_id'] ?? '';
        final lastSid = prefs.getString(_kLastCheckoutSid);
        if (sid.isNotEmpty && sid == lastSid) {
          debugPrint('[deeplink] success already handled for session $sid');
          return;
        }
        if (sid.isNotEmpty) await prefs.setString(_kLastCheckoutSid, sid);

        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          await Get.find<BusinessOwnerProfileController>().checkStripeStatusIfPossible();
        }
        Get.snackbar('Subscription', 'Purchase completed');
        return;
      }

      if (path == '/cancel') {
        Get.snackbar('Subscription', 'Checkout cancelled');
        return;
      }
    }

    // ---------- Stripe onboarding (unchanged) ----------
    final isStripeOnboarding = (uri.scheme == 'myapp' || uri.scheme == 'fidden') && uri.host == 'stripe';
    if (isStripeOnboarding) {
      if (uri.path == '/return') {
        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          Get.find<BusinessOwnerProfileController>().checkStripeStatusIfPossible();
        }
        Get.snackbar('Stripe', 'Onboarding flow returned to app');
      } else if (uri.path == '/refresh') {
        Get.snackbar('Stripe', 'Onboarding not completed. You can retry.');
      }
      return;
    }

    // ---------- NEW: Booking deep links ----------
    // fidden://book/{slotId}
    final isBookScheme = uri.scheme == 'fidden' && uri.host == 'book' && uri.pathSegments.isNotEmpty;
    // https://your-app.com/book/{slotId}
    final isBookWeb = uri.scheme == 'https' && uri.host == 'your-app.com'
        && uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'book' && uri.pathSegments.length >= 2;

    String? slotIdStr;
    if (isBookScheme) {
      slotIdStr = uri.pathSegments.first;
    } else if (isBookWeb) {
      slotIdStr = uri.pathSegments[1];
    }

    if (slotIdStr != null && slotIdStr.isNotEmpty) {
      final slotId = int.tryParse(slotIdStr);
      if (slotId == null) return;

      Get.offAllNamed(
        AppRoute.bookingSummaryScreen,
        arguments: {
          'bookingId': slotId,                 // 👈 what your screen expects
          'booking': {'shop_id': 0, 'service_id': 0},
          'preload': const <String, dynamic>{},
        },
      );
      return;
    }

    // ---------- Legacy offer deep links (if still used) ----------
    final isOfferScheme = uri.scheme == 'fidden' && uri.host == 'offer';
    if (isOfferScheme) {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (id != null && id.isNotEmpty) {
        // If offers should also open the booking summary, map them the same way:
        final slotId = int.tryParse(id);
        if (slotId != null) {
          Get.offAllNamed(AppRoute.bookingSummaryScreen, arguments: {
            'bookingId': slotId,
            'booking': {'shop_id': 0, 'service_id': 0},
            'preload': const <String, dynamic>{},
          });
        } else {
          Get.toNamed('/offer', arguments: {'slotId': id});
        }
      }
      return;
    }

    final isOfferWeb = uri.scheme == 'https' && uri.host == 'your-app.com'
        && uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'book';
    if (isOfferWeb) {
      final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      if (id != null && id.isNotEmpty) {
        final slotId = int.tryParse(id);
        if (slotId != null) {
          Get.offAllNamed(AppRoute.bookingSummaryScreen, arguments: {
            'bookingId': slotId,
            'booking': {'shop_id': 0, 'service_id': 0},
            'preload': const <String, dynamic>{},
          });
        } else {
          Get.toNamed('/offer', arguments: {'slotId': id});
        }
      }
      return;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
