import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../utils/constants/app_colors.dart';
import '../../utils/constants/app_sizes.dart';

bool _loadingOpen = false;

void showProgressIndicator() {
  if (_loadingOpen) return; // prevent stacking
  _loadingOpen = true;
  Get.dialog(
    Center(
      child: SpinKitFadingCircle(
        color: AppColors.primaryColor,
        size: getWidth(50),
      ),
    ),
    barrierDismissible: false,
    useSafeArea: false,
  );
}

void hideProgressIndicator() {
  // Close normal dialog if open
  if (Get.isDialogOpen == true) {
    Get.back(closeOverlays: true);
    _loadingOpen = false;
    return;
  }
  // Fallback: ensure no orphaned popup remains
  final overlay = Get.overlayContext;
  if (overlay != null) {
    final nav = Navigator.of(overlay, rootNavigator: true);
    // Try to pop a single lingering route if it’s our dialog
    if (nav.canPop()) {
      nav.pop();
    }
  }
  _loadingOpen = false;
}
