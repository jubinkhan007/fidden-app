// lib/features/auth/presentation/screens/login/google_sign_in.dart
import 'dart:async';
import 'dart:developer';

import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/logging/logger.dart';
import 'package:fidden/features/business_owner/nav_bar/presentation/screens/user_nav_bar.dart';
import 'package:fidden/features/user/nav_bar/presentation/screens/user_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInController extends GetxController {
  // ❗ IMPORTANT: Replace this with your actual Web Client ID from Google Cloud Console.
  static const _webClientId =
      '772435903240-ggmvqdtveoq8i717jgiksor33v00s153.apps.googleusercontent.com';

  // Use the singleton instance provided by the package.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // We need to store the role temporarily when sign-in is initiated.
  String _roleForSignIn = '';

  @override
  void onInit() {
    super.onInit();
    // Initialize GoogleSignIn when the controller is created.
    _initializeGoogleSignIn();
  }

  /// Initializes the GoogleSignIn client and sets up a listener for authentication events.
  /// This is the new required first step for google_sign_in v7+.
  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _webClientId);
      // Listen for authentication events (sign-ins, sign-outs).
      _googleSignIn.authenticationEvents.listen(
        _handleAuthEvent,
        onError: _handleAuthError,
      );
    } catch (e) {
      log("Google Sign-In Initialization Error: $e");
      Get.snackbar('Setup Error', 'Could not initialize Google Sign-In.');
    }
  }

  /// This is the method you will call from your UI (e.g., from an ElevatedButton).
  Future<void> signInWithGoogle(String role) async {
    // Store the role so the event listener can use it after authentication.
    _roleForSignIn = role;
    try {
      // The `authenticate` method now triggers the sign-in UI.
      // The result is handled by the `authenticationEvents` stream listener.
      await _googleSignIn.authenticate();
    } catch (e) {
      log('Error triggering Google authentication: $e');
      Get.snackbar('Sign-In Error', 'Could not start the sign-in process.');
    }
  }

  /// Handles events from the `authenticationEvents` stream.
  Future<void> _handleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    // We only care about successful sign-in events.
    if (event is GoogleSignInAuthenticationEventSignIn && event.user != null) {
      final user = event.user!;
      final auth = await user.authentication;
      final idToken = auth.idToken;
      debugPrint("google IdToken: $idToken");

      if (idToken != null && idToken.isNotEmpty) {
        // Now that we have the token, proceed with your backend login.
        await _loginWithBackend(idToken: idToken, role: _roleForSignIn);
      } else {
        AppLoggerHelper.error('Failed to get idToken from Google.');
        Get.snackbar('Sign-In Failed', 'Could not get authentication token.');
      }
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      log('User signed out via Google.');
    }
  }

  /// Handles errors from the authentication stream.
  void _handleAuthError(Object error) {
    log('Google Sign-In Stream Error: $error');
    Get.snackbar('Sign-In Error', 'An authentication error occurred.');
  }

  /// Your existing method to communicate with your backend. No changes needed here.
  Future<void> _loginWithBackend({
    required String idToken,
    required String role,
  }) async {
    Get.dialog(
      const Center(
        child: SpinKitFadingCircle(color: AppColors.primaryColor, size: 50),
      ),
      barrierDismissible: false,
    );

    try {
      final resp = await NetworkCaller().postRequest(
        AppUrls.socialLogin,
        body: {'token': idToken, 'role': role.toLowerCase()},
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (!resp.isSuccess) {
        AppLoggerHelper.error(resp.errorMessage);
        Get.snackbar(
          'Login Failed',
          resp.errorMessage ?? 'Could not log in with Google.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      final map = resp.responseData as Map<String, dynamic>? ?? {};
      final data = map['data'] as Map<String, dynamic>? ?? map;
      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      final userRole = (data['role'] ?? role).toString().toUpperCase();

      if (accessToken == null) {
        AppLoggerHelper.error('No access token returned by server');
        Get.snackbar('Login Error', 'Failed to retrieve access token.');
        return;
      }

      await AuthService.saveToken(accessToken, refreshToken ?? '', userRole);

      if (userRole == 'CUSTOMER' || userRole == 'USER') {
        Get.offAll(() => const UserNavBar());
      } else {
        Get.offAll(() => const BusinessOwnerNavBar());
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppLoggerHelper.error('Error during backend login: $e');
      Get.snackbar('Login Error', 'An unexpected server error occurred.');
    }
  }
}
