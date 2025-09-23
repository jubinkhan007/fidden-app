// lib/features/settings/presentation/utils/app_data_utils.dart

import 'dart:developer';
import 'dart:io';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AppDataUtils {
  /// Clears cache and logs out, navigating to LoginScreen.
  static Future<void> clearAppData() async {
    log('--- Starting Clear App Data ---');
    // Gracefully shut down the cache manager BEFORE clearing data.
    await DefaultCacheManager().dispose();
    await DefaultCacheManager().emptyCache();
    log('Cache cleared successfully.');
    await AuthService.logoutUser();
    log('--- Finished Clear App Data ---');
  }

  /// Wipes all app data and navigates to SplashScreen to restart the app flow.
  static Future<void> deactivateAccount() async {
    log('--- Starting Deactivate Account ---');
    try {
      // 1. Gracefully shut down the cache manager to prevent I/O errors.
      await DefaultCacheManager().dispose();
      log('Cache Manager disposed.');

      // 2. Delete file system cache and data
      final cacheDir = await getTemporaryDirectory();
      final appDir = await getApplicationSupportDirectory();

      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
        log('Cache directory deleted: ${cacheDir.path}');
      }

      if (appDir.existsSync()) {
        final entities = appDir.listSync(recursive: false);
        for (final FileSystemEntity entity in entities) {
          entity.deleteSync(recursive: true);
        }
        log('Contents of App support directory cleared: ${appDir.path}');
      }

      // 3. Wipe all SharedPreferences data
      await AuthService.clearAllDataForDeactivation();

      // 4. Navigate to the SplashScreen
      Get.offAll(() => SplashScreen());

    } catch (e) {
      log('Error during account deactivation: $e');
    }
    log('--- Finished Deactivate Account ---');
  }
}