// lib/core/services/permission_handler.dart

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PermissionController extends GetxController {
  var notificationStatus = Rx<PermissionStatus>(PermissionStatus.denied);
  static const _permissionRequestedKey = 'notification_permission_requested';

  @override
  void onInit() {
    super.onInit();
    // Check the current status when the app starts.
    checkNotificationPermission();
  }

  /// Checks the current notification permission status without requesting it.
  void checkNotificationPermission() async {
    final status = await Permission.notification.status;
    notificationStatus.value = status;
  }

  /// Requests notification permission *only if it hasn't been requested before*.
  /// This prevents the redirect-to-settings loop on hot restart.
  Future<void> requestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasBeenRequested = prefs.getBool(_permissionRequestedKey) ?? false;

    // If we have a definitive status already (granted or permanently denied),
    // and we've asked before, don't do anything.
    if (hasBeenRequested && (notificationStatus.value.isGranted || notificationStatus.value.isPermanentlyDenied)) {
      return;
    }

    // Request the permission.
    final status = await Permission.notification.request();
    notificationStatus.value = status;

    // Mark that we have now requested the permission at least once.
    await prefs.setBool(_permissionRequestedKey, true);

    // If, after requesting, it's permanently denied, open settings.
    // if (status.isPermanentlyDenied) {
    //   openAppSettings();
    // }
  }
}