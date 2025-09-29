// lib/core/deeplinks/deep_link_service.dart
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();

    // 1) App launched by a deep link (cold start)
    try {
      final uri = await _appLinks.getInitialLink();  // ✅ use getInitialLink()
      if (uri != null) _handleUri(uri);
    } catch (e) {
      debugPrint('[deeplink] getInitialLink error: $e');
    }

    // 2) App receives deep link while running / resumed (warm start)
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (err) => debugPrint('[deeplink] stream error: $err'),
      cancelOnError: false,
    );

    return this;
  }

  void _handleUri(Uri uri) {
    debugPrint('[deeplink] $uri');

    final isStripe =
        (uri.scheme == 'myapp' || uri.scheme == 'fidden') && uri.host == 'stripe';

    if (isStripe) {
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
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
