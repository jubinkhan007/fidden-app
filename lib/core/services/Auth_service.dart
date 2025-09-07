import 'dart:developer';
import 'package:fidden/features/auth/presentation/screens/login/login_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _roleKey = 'role';
  static const String _isSeeOnboardingKey = 'isSeeOnboarding'; // ✅ New key

  static late SharedPreferences _preferences;

  static String? _accessToken;
  static String? _refreshToken;
  static String? _role;

  static final RxInt tokenRefreshCount = 0.obs;

  // Initialize SharedPreferences (call during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _accessToken = _preferences.getString(_accessTokenKey);
    _refreshToken = _preferences.getString(_refreshTokenKey);
    _role = _preferences.getString(_roleKey);
  }

  static bool hasToken() {
    return _preferences.containsKey(_accessTokenKey);
  }

  static Future<void> saveToken(
    String accessToken,
    String refreshToken,
    String role,
  ) async {
    try {
      await _preferences.setString(_accessTokenKey, accessToken);
      await _preferences.setString(_refreshTokenKey, refreshToken);
      await _preferences.setString(_roleKey, role);
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _role = role;
      log(
        'Token and role saved successfully: $accessToken, $refreshToken, $role',
      );

      // Notify listeners of the token change
      tokenRefreshCount.value++;
    } catch (e) {
      log('Error saving token and role: $e');
    }
  }

  /// ✅ Save the "isSeeOnboarding" bool
  static Future<void> setOnboardingSeen(bool seen) async {
    try {
      await _preferences.setBool(_isSeeOnboardingKey, seen);
      log('Onboarding flag saved: $seen');
    } catch (e) {
      log('Error saving onboarding flag: $e');
    }
  }

  /// ✅ Get the "isSeeOnboarding" value
  static bool hasSeenOnboarding() {
    return _preferences.getBool(_isSeeOnboardingKey) ?? false; // default: false
  }

  static Future<void> logoutUser() async {
    try {
      await _preferences.remove(_accessTokenKey);
      await _preferences.remove(_roleKey);
      //await _preferences.remove(_isSeeOnboardingKey); // 👈 explicitly remove onboarding flag
      _accessToken = null;
      _refreshToken = null;
      _role = null;
      log("+++++++++++++ Logout called");
      await goToLogin();
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  static Future<void> goToLogin() async {
    Get.offAll(() => LoginScreen());
  }

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get role => _role;
}
