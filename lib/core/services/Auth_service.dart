import 'dart:developer';
import 'package:fidden/core/services/device_registry.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/auth/presentation/screens/login/login_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _roleKey = 'role';
  static const String _isSeeOnboardingKey = 'isSeeOnboarding';

  static SharedPreferences? _preferences;

  static String? _accessToken;
  static String? _refreshToken;
  static String? _role;

  static final RxInt tokenRefreshCount = 0.obs;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
    _accessToken = _preferences!.getString(_accessTokenKey);
    _refreshToken = _preferences!.getString(_refreshTokenKey);
    _role = _preferences!.getString(_roleKey);
  }

  static Future<String?> getValidAccessToken() async {
    await init();
    return _accessToken;
  }

  // --- NEW: Added the missing method for the refresh token ---
  static Future<String?> getValidRefreshToken() async {
    await init();
    return _refreshToken;
  }

  static Future<void> clearAuthData() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.remove(_accessTokenKey);
      await _preferences!.remove(_refreshTokenKey);
      await _preferences!.remove(_roleKey);
      _accessToken = null;
      _refreshToken = null;
      _role = null;
      log('Auth data cleared.');
    } catch (e) {
      log('Error clearing auth data: $e');
    }
  }

  static Future<void> waitForToken({Duration timeout = const Duration(seconds: 10)}) async {
    final start = DateTime.now();
    while (true) {
      final t = await getValidAccessToken();
      if (t != null && t.isNotEmpty) return;
      if (DateTime.now().difference(start) > timeout) return;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  static bool hasToken() {
    return _preferences?.containsKey(_accessTokenKey) ?? false;
  }

  static Future<void> saveToken(
      String accessToken,
      String refreshToken,
      String role,
      ) async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(_accessTokenKey, accessToken);
      await _preferences!.setString(_refreshTokenKey, refreshToken);
      await _preferences!.setString(_roleKey, role);
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _role = role;
      log(
        'Token and role saved successfully: $accessToken, $refreshToken, $role',
      );
      tokenRefreshCount.value++;
    } catch (e) {
      log('Error saving token and role: $e');
    }
  }

  static Future<void> setOnboardingSeen(bool seen) async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setBool(_isSeeOnboardingKey, seen);
      log('Onboarding flag saved: $seen');
    } catch (e) {
      log('Error saving onboarding flag: $e');
    }
  }

  static bool hasSeenOnboarding() {
    return _preferences?.getBool(_isSeeOnboardingKey) ?? false;
  }

  static Future<void> logoutUser() async {
    await clearAuthData();
    log("+++++++++++++ Logout called, navigating to login");
    Get.offAll(() => LoginScreen());
  }

  static Future<void> clearAllDataForDeactivation() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    await prefs.clear();
    log('All SharedPreferences data has been cleared for deactivation.');
  }


  static Future<void> goToLogin() async {
    Get.offAll(() => LoginScreen());
  }

  static Future<void> registerDeviceIfNeeded() async {
    try {
      final payload = await DeviceRegistry.instance.getOrCreate();
      final response = await NetworkCaller().postRequest(
        AppUrls.registerDevice,
        body: payload.toJson(),
      );

      if (response.isSuccess) {
        log(
          '[DeviceRegistry] ✅ Device registered successfully: ${payload.toJson()}',
        );
      } else {
        log(
          '[DeviceRegistry] ❌ Device registration failed: '
              'status=${response.statusCode}, '
              'error=${response.errorMessage}',
        );
      }
    } catch (e) {
      log('[DeviceRegistry] ❌ Exception during device registration: $e');
    }
  }

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get role => _role;
}