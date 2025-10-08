import 'dart:developer';
import 'dart:io';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/painting.dart'; // imageCache
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class AppDataUtils {
  static bool _busy = false;

  // ---------- Helpers ----------
  static Future<void> _clearInMemoryImages() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }

  static bool _isDbClosedError(Object e) =>
      e.toString().contains('database_closed');

  /// Try emptying DefaultCacheManager; if DB is closed, fall back to deleting files.
  static Future<void> _safeClearDefaultCache() async {
    // Try the API first.
    final cm = DefaultCacheManager();
    try {
      await cm.emptyCache(); // may throw if DB already closed
    } catch (e) {
      if (_isDbClosedError(e)) {
        // Fallback: delete cache folders by hand.
        await _deleteKnownCacheDirectories();
      } else {
        rethrow;
      }
    }

    // Try disposing, but don't fail whole flow if it’s already closed.
    try {
      await cm.dispose();
    } catch (_) {
      // ignore
    }
  }

  /// Remove common cache folders used by flutter_cache_manager / cached_network_image.
  static Future<void> _deleteKnownCacheDirectories() async {
    try {
      final tmpDir = await getTemporaryDirectory();

      // These names are commonly used by flutter_cache_manager/cached_network_image
      // across Android/iOS. We delete if present—safe fallback when DB is closed.
      final candidates = <Directory>[
        Directory('${tmpDir.path}/libCachedImageData'),
        Directory('${tmpDir.path}/image_cache'),
        Directory('${tmpDir.path}/cache'),
        Directory('${tmpDir.path}/flutter_cache_manager'),
      ];

      for (final d in candidates) {
        if (d.existsSync()) {
          d.deleteSync(recursive: true);
          log('Deleted cache dir: ${d.path}');
        }
      }
    } catch (e) {
      log('Fallback cache folder delete failed: $e');
    }
  }

  // ---------- Public APIs ----------
  /// Clears cache and logs out.
  static Future<void> clearAppData() async {
    if (_busy) return;
    _busy = true;
    log('--- Starting Clear App Data ---');
    try {
      await _safeClearDefaultCache();
      await _clearInMemoryImages();

      await AuthService.logoutUser();
      log('Cache cleared successfully.');
    } catch (e, s) {
      log('Clear App Data error: $e\n$s');
    } finally {
      _busy = false;
      log('--- Finished Clear App Data ---');
    }
  }

  /// Wipes app data and restarts flow.
  static Future<void> deactivateAccount() async {
    if (_busy) return;
    _busy = true;
    log('--- Starting Deactivate Account ---');
    try {
      // 1) Clear caches safely
      await _safeClearDefaultCache();
      await _clearInMemoryImages();

      // 2) Delete temp/app support contents
      try {
        final cacheDir = await getTemporaryDirectory();
        if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
      } catch (e) {
        log('Deleting temp failed: $e');
      }

      try {
        final appSupport = await getApplicationSupportDirectory();
        if (appSupport.existsSync()) {
          for (final e in appSupport.listSync(recursive: false)) {
            e.deleteSync(recursive: true);
          }
        }
      } catch (e) {
        log('Clearing app support failed: $e');
      }

      // 3) Clear prefs/secure storage
      await AuthService.clearAllDataForDeactivation();

      // 4) Restart flow
      Get.offAll(() => SplashScreen());
    } catch (e, s) {
      log('Error during account deactivation: $e\n$s');
    } finally {
      _busy = false;
      log('--- Finished Deactivate Account ---');
    }
  }
}
