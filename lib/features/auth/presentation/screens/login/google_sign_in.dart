// google_sign_in.dart (Your Controller File)

import 'dart:developer';

import 'package:fidden/core/services/Auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/services/network_caller.dart';
import '../../../../../core/utils/constants/api_constants.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/logging/logger.dart';
import '../../../../business_owner/nav_bar/presentation/screens/user_nav_bar.dart';
import '../../../../user/nav_bar/presentation/screens/user_nav_bar.dart';

class GoogleSignInController extends GetxController {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Returns the signed in account, and you can grab the idToken from it.
  Future<GoogleSignInAccount?> signInWithGoogle(String role) async {
    try {
      // (optional but helpful if you see reauth issues)
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      if (account == null) {
        log('Google Sign-In canceled by user');
        return null;
      }

      // ⬇️ Get the ID token here
      final auth = await account.authentication; // v7 API
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        AppLoggerHelper.error('No idToken from Google (check OAuth setup)');
        return null;
      }

      // Now send idToken (and role if your API needs it)
      await _loginWithGoogleIdToken(idToken: idToken, role: role);
      return account;
    } catch (e) {
      log('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> _loginWithGoogleIdToken({
    required String idToken,
    required String role,
  }) async {
    try {
      Get.dialog(
        const Center(
          child: SpinKitFadingCircle(color: AppColors.primaryColor, size: 50),
        ),
        barrierDismissible: false,
      );

      final resp = await NetworkCaller().postRequest(
        AppUrls.socialLogin, // e.g. https://.../accounts/login/google/
        body: {
          'token': idToken,
          'role': role.toLowerCase(), // only if your backend expects it
        },
      );

      if (Get.isDialogOpen == true) Get.back();

      if (!resp.isSuccess) {
        AppLoggerHelper.error(resp.errorMessage);
        Get.snackbar(
          'Uh-oh! Something went wrong',
          resp.errorMessage ?? 'Google login failed. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // Normalize response (some backends wrap in "data")
      final map = (resp.responseData is Map)
          ? Map<String, dynamic>.from(resp.responseData)
          : <String, dynamic>{};
      final data = (map['data'] is Map)
          ? Map<String, dynamic>.from(map['data'])
          : map;

      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      final userRole = (data['role'] ?? role).toString().toUpperCase();

      if (accessToken == null) {
        AppLoggerHelper.error('No access token returned by server');
        return;
      }

      await AuthService.saveToken(accessToken, refreshToken ?? '', userRole);

      if (userRole == 'CUSTOMER' || userRole == 'USER') {
        await Get.offAll(() => const UserNavBar());
      } else {
        await Get.offAll(() => const BusinessOwnerNavBar());
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      AppLoggerHelper.error('Error: $e');
    }
  }
}
