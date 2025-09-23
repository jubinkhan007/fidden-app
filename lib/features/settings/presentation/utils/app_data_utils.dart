// lib/features/settings/presentation/utils/app_data_utils.dart

import 'dart:developer';
import 'dart:io'; // Make sure 'dart:io' is imported
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AppDataUtils {
  // This function is correct and does not need changes.
  static Future<void> clearAppData() async {
    log('--- Starting Clear App Data ---');
    await DefaultCacheManager().emptyCache();
    log('Cache cleared successfully.');
    await AuthService.logoutUser();
    log('--- Finished Clear App Data ---');
  }

  /// Wipes all app data and navigates to SplashScreen to restart the app flow.
  static Future<void> deactivateAccount() async {
    log('--- Starting Deactivate Account ---');
    try {
      // 1. Delete file system cache and data (Corrected Logic)
      final cacheDir = await getTemporaryDirectory();
      final appDir = await getApplicationSupportDirectory();

      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
        log('Cache directory deleted: ${cacheDir.path}');
      }

      // --- START: MODIFIED CODE ---
      if (appDir.existsSync()) {
        // Delete the CONTENTS of the directory, not the directory itself.
        final entities = appDir.listSync(recursive: false);
        for (final FileSystemEntity entity in entities) {
          entity.deleteSync(recursive: true);
        }
        log('Contents of App support directory cleared: ${appDir.path}');
      }
      // --- END: MODIFIED CODE ---

      // 2. Wipe all SharedPreferences data
      await AuthService.clearAllDataForDeactivation();

      // 3. Navigate to the SplashScreen to trigger the "first time" logic
      Get.offAll(() => SplashScreen());

    } catch (e) {
      log('Error during account deactivation: $e');
    }
    log('--- Finished Deactivate Account ---');
  }
}