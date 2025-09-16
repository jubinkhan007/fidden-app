// lib/core/services/device_registry.dart

import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ... (DeviceCacheKeys and DevicePayload classes remain the same) ...
class DeviceCacheKeys {
  static const deviceToken = 'device_token';
  static const deviceType = 'device_type';
  static const fcmToken = 'fcm_token';
}

class DevicePayload {
  final String deviceToken; // our "id"
  final String deviceType; // "android" | "ios" | "other"
  final String? fcmToken;

  const DevicePayload(
      {required this.deviceToken, required this.deviceType, this.fcmToken});

  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'device_type': deviceType,
    if (fcmToken != null) 'fcm_token': fcmToken,
  };
}


class DeviceRegistry {
  DeviceRegistry._();
  static final DeviceRegistry instance = DeviceRegistry._();

  Future<DevicePayload> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedToken = prefs.getString(DeviceCacheKeys.deviceToken);
    final cachedType = prefs.getString(DeviceCacheKeys.deviceType);
    final cachedFcmToken = prefs.getString(DeviceCacheKeys.fcmToken);

    if (cachedToken != null &&
        cachedToken.isNotEmpty &&
        cachedType != null &&
        cachedFcmToken != null) {
      return DevicePayload(
          deviceToken: cachedToken,
          deviceType: cachedType,
          fcmToken: cachedFcmToken);
    }

    final payload = await _computePayload();

    await prefs.setString(DeviceCacheKeys.deviceToken, payload.deviceToken);
    await prefs.setString(DeviceCacheKeys.deviceType, payload.deviceType);
    if (payload.fcmToken != null) {
      await prefs.setString(DeviceCacheKeys.fcmToken, payload.fcmToken!);
    }

    return payload;
  }

  Future<DevicePayload> refresh() async {
    final payload = await _computePayload();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(DeviceCacheKeys.deviceToken, payload.deviceToken);
    await prefs.setString(DeviceCacheKeys.deviceType, payload.deviceType);
    if (payload.fcmToken != null) {
      await prefs.setString(DeviceCacheKeys.fcmToken, payload.fcmToken!);
    }
    return payload;
  }

  /// Compute the platform + a stable device identifier.
  Future<DevicePayload> _computePayload() async {
    final plugin = DeviceInfoPlugin();
    String? fcmToken;
    try {
      // ✅ START: FIX FOR iOS
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          print('Failed to get APNS token for iOS');
          // You might want to wait and retry here.
        }
      }
      // ✅ END: FIX FOR iOS
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Failed to get FCM token: $e');
    }

    String deviceType = 'other';
    String token = 'unknown';

    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        token = info.id;
        deviceType = 'android';
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        token = info.identifierForVendor ?? 'unknown';
        deviceType = 'ios';
      } else {
        deviceType = Platform.operatingSystem;
        token = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (_) {
      token = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return DevicePayload(
        deviceToken: token, deviceType: deviceType, fcmToken: fcmToken);
  }
}