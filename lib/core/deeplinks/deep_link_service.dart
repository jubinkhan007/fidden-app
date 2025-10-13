// lib/core/deeplinks/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  static const _kLastCheckoutSid = 'last_checkout_session_id';

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    // 1) Handle cold-start deep link (may replay on Android)
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) await _handleUri(uri);
    } catch (e) {
      debugPrint('[deeplink] getInitialLink error: $e');
    }

    // 2) Handle links while app is running
    _sub = _appLinks.uriLinkStream.listen(
          (uri) => _handleUri(uri),
      onError: (err) => debugPrint('[deeplink] stream error: $err'),
      cancelOnError: false,
    );

    return this;
  }

  Future<void> _handleUri(Uri uri) async {
    debugPrint('[deeplink] $uri');

    // Stripe *subscription* return/cancel (your new flow)
    final isSubscription =
        (uri.scheme == 'myapp' || uri.scheme == 'fidden') &&
            uri.host == 'subscription';

    if (isSubscription) {
      final path = uri.path; // '/success' or '/cancel'
      final prefs = await SharedPreferences.getInstance();

      if (path == '/success') {
        final sid = uri.queryParameters['session_id'] ?? '';

        // Guard: only handle a session once, even if Android replays it
        final lastSid = prefs.getString(_kLastCheckoutSid);
        if (sid.isNotEmpty && sid == lastSid) {
          debugPrint('[deeplink] success already handled for session $sid');
          return;
        }
        if (sid.isNotEmpty) {
          await prefs.setString(_kLastCheckoutSid, sid);
        }

        // Refresh backend state (plan, entitlements, etc)
        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          await Get.find<BusinessOwnerProfileController>()
              .checkStripeStatusIfPossible();
        }

        // OPTIONAL: only show the toast the first time (now guaranteed)
        Get.snackbar('Subscription', 'Purchase completed');

        return;
      }

      if (path == '/cancel') {
        Get.snackbar('Subscription', 'Checkout cancelled');
        return;
      }
    }

    // Old onboarding deep links (keep if you still use them)
    final isStripeOnboarding =
        (uri.scheme == 'myapp' || uri.scheme == 'fidden') &&
            uri.host == 'stripe';
    if (isStripeOnboarding) {
      if (uri.path == '/return') {
        if (Get.isRegistered<BusinessOwnerProfileController>()) {
          Get.find<BusinessOwnerProfileController>().checkStripeStatusIfPossible();
        }
        Get.snackbar('Stripe', 'Onboarding flow returned to app');
      } else if (uri.path == '/refresh') {
        Get.snackbar('Stripe', 'Onboarding not completed. You can retry.');
      }
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
