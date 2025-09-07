// lib/core/services/device_registry.dart
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache keys
class DeviceCacheKeys {
  static const deviceToken = 'device_token';
  static const deviceType = 'device_type';
}

/// Simple POJO
class DevicePayload {
  final String deviceToken; // our "id"
  final String deviceType; // "android" | "ios" | "other"
  const DevicePayload({required this.deviceToken, required this.deviceType});

  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'device_type': deviceType,
  };
}

/// Singleton utility to fetch + cache device identifiers.
class DeviceRegistry {
  DeviceRegistry._();
  static final DeviceRegistry instance = DeviceRegistry._();

  /// Public: read from cache (if exists) or compute & persist.
  Future<DevicePayload> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedToken = prefs.getString(DeviceCacheKeys.deviceToken);
    final cachedType = prefs.getString(DeviceCacheKeys.deviceType);

    if (cachedToken != null && cachedToken.isNotEmpty && cachedType != null) {
      return DevicePayload(deviceToken: cachedToken, deviceType: cachedType);
    }

    final payload = await _computePayload();

    await prefs.setString(DeviceCacheKeys.deviceToken, payload.deviceToken);
    await prefs.setString(DeviceCacheKeys.deviceType, payload.deviceType);

    return payload;
  }

  /// Force refresh (rarely needed).
  Future<DevicePayload> refresh() async {
    final payload = await _computePayload();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(DeviceCacheKeys.deviceToken, payload.deviceToken);
    await prefs.setString(DeviceCacheKeys.deviceType, payload.deviceType);
    return payload;
  }

  /// Compute the platform + a stable device identifier.
  Future<DevicePayload> _computePayload() async {
    final plugin = DeviceInfoPlugin();

    String deviceType = 'other';
    String token = 'unknown';

    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        // ANDROID_ID (SSAID) – stable per device+signing key (good enough for your use case)
        token = info.id; // device_info_plus exposes `id` (non-nullable)
        deviceType = 'android';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        // IDFV – stable for apps from the same vendor
        token = info.identifierForVendor ?? 'unknown';
        deviceType = 'ios';
      } else {
        deviceType = Platform.operatingSystem; // e.g. "macos"
        token = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (_) {
      // as a last resort, a pseudo token
      token = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return DevicePayload(deviceToken: token, deviceType: deviceType);
  }
}
