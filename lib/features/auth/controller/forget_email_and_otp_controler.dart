import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/auth/controller/sign_up_controller.dart';
import 'package:fidden/features/auth/presentation/screens/login/new_password_screen.dart';
import 'package:fidden/features/auth/presentation/screens/login/verify_otp_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/logging/logger.dart';
import '../../../routes/app_routes.dart';

class ForgetPasswordAndOtpController extends GetxController {
  TextEditingController otpTEController = TextEditingController();
  final emailTEController = TextEditingController();
  final signUpController = Get.put(SignUpController());

  var isLoading = false.obs; // for Verify button
  final isResending = false.obs;

  Future<void> verifyOtp(String email) async {
    var otp = int.tryParse(otpTEController.text);

    final Map<String, dynamic> requestBody = {
      "email": emailTEController.text,
      "otp": otp,
    };

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.verifyOtp,
        body: requestBody,
      );

      if (response.isSuccess) {
        Get.toNamed(AppRoute.verificationSuccessfulScreen);
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resendOtp(String email) async {
    if (isResending.value) return false;
    isResending.value = true;
    try {
      final resp = await NetworkCaller().postRequest(
        // IMPORTANT: Django needs trailing slash
        AppUrls.forgotEmail, // e.g. https://.../accounts/request-reset/
        body: {"email": email.trim()},
      );
      if (resp.isSuccess) {
        AppSnackBar.showSuccess('OTP sent to your email');
        return true;
      } else {
        AppSnackBar.showError(resp.errorMessage ?? 'Failed to resend OTP');
        return false;
      }
    } catch (e) {
      AppLoggerHelper.error('Resend OTP error: $e');
      AppSnackBar.showError('Resend failed. Please try again.');
      return false;
    } finally {
      isResending.value = false;
    }
  }

  // For Forgot Email

  Future<void> verifyOtp2(String email, String otp1) async {
    var otp = int.tryParse(otp1);

    final Map<String, dynamic> requestBody = {"email": email, "otp": otp};

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.verifyOtp,
        body: requestBody,
      );
      if (response.statusCode == 400) {
        AppSnackBar.showError("Invalid OTP");
        return;
      }

      if (response.isSuccess) {
        String? token = response.responseData['accesstoken'];
        Get.to(() => NewPasswordScreen(email: email));
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp3(String email, String otp1) async {
    var otp = int.tryParse(otp1);

    final Map<String, dynamic> requestBody = {"email": email, "otp": otp};

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.verifyOtp,
        body: requestBody,
      );

      if (response.isSuccess) {
        // signUpController.createAccount();

        Get.toNamed(AppRoute.verificationSuccessfulScreen);
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgetEmail() async {
    final Map<String, dynamic> requestBody = {'email': emailTEController.text};

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.forgotEmail,
        body: requestBody,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess("We sent OTP please check your email..");
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // For Forgot Email

  Future<void> forgetEmail2(String email) async {
    final Map<String, dynamic> requestBody = {'email': email};

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.forgotEmail,
        body: requestBody,
      );

      if (response.isSuccess) {
        Get.to(() => VerifyOtpScreen(email: email));
        AppSnackBar.showSuccess("We sent OTP please check your email..");
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
