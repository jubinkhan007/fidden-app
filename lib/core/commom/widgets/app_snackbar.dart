import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackBar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showError(String message, {String title = 'Error'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: const Color(0xffDC143C),
      icon: Icons.error_outline,
    );
  }

  static void showSuccess(String message, {String title = 'Success'}) {
    _show(
      title: title,
      message: message,
      backgroundColor: Colors.green.withOpacity(0.9),
      icon: Icons.check_circle_outline,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Always use post-frame callback to ensure widget tree is stable
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSnackbarSafely(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
      );
    });
  }

  static void _showSnackbarSafely({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Prefer ScaffoldMessenger as it's more reliable
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      _showWithMessenger(
        messenger,
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        icon: icon,
      );
      return;
    }

    // Fallback to Get.snackbar only if ScaffoldMessenger is unavailable
    // and GetX overlay context is available
    try {
      final overlayContext = Get.overlayContext;
      if (overlayContext != null) {
        // Verify the overlay is actually accessible
        final overlay = Overlay.maybeOf(overlayContext);
        if (overlay != null) {
          Get.snackbar(
            title,
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: backgroundColor,
            colorText: Colors.white,
            borderRadius: 10.0,
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(15.0),
            duration: const Duration(seconds: 3),
            icon: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            isDismissible: true,
            snackStyle: SnackStyle.FLOATING,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('AppSnackBar Get.snackbar failed: $e');
    }

    debugPrint('AppSnackBar skipped: no valid overlay or messenger available.');
  }

  static void _showWithMessenger(
    ScaffoldMessengerState messenger, {
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(10.0),
        duration: const Duration(seconds: 3),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
