// lib/core/deeplinks/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/features/business_owner/subscription/controller/subscription_controller.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleUri(uri);
    } catch (e) {
      debugPrint('[deeplink] getInitialLink error: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
          (uri) => _handleUri(uri),
      onError: (err) => debugPrint('[deeplink] stream error: $err'),
      cancelOnError: false,
    );

    return this;
  }

  void _handleUri(Uri uri) {
    debugPrint('[deeplink] $uri');

    // --- Existing onboarding handler (keep this) ---
    final isStripeOnboarding =
        (uri.scheme == 'myapp' || uri.scheme == 'fidden') && uri.host == 'stripe';
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

    // --- NEW: Subscription checkout handler ---
    final isSubscription = uri.scheme == 'myapp' && uri.host == 'subscription';
    if (isSubscription) {
      final sessionId = uri.queryParameters['session_id'];
      if (uri.path == '/success') {
        // Optional: verify using sessionId, then refresh local subscription state
        if (Get.isRegistered<SubscriptionController>()) {
          final c = Get.find<SubscriptionController>();
          c.handleReturnFromStripeCheckout(sessionId);
        }
        Get.snackbar('Subscription', 'Payment successful');
      } else if (uri.path == '/cancel') {
        Get.snackbar('Subscription', 'Purchase cancelled');
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
