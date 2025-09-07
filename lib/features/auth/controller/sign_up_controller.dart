import 'dart:developer';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/auth/presentation/screens/sign_up/sign_up_verify_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/Auth_service.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/logging/logger.dart';

class SignUpController extends GetxController {
  final TextEditingController userNameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  var selectedValue = 'USER'.obs; // Allows null values
  List<String> items = ['USER', 'OWNER'];

  var isLoading = false.obs;

  Future<void> createAccount() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final body = {
      "email": emailTEController.text.trim(),
      "role": selectedValue.value.toLowerCase(), // "user" or "owner"
      "password": passwordTEController.text,
    };

    try {
      final resp = await NetworkCaller().postRequest(
        AppUrls.createAccount,
        body: body,
      );

      // Normalize response
      final root = resp.responseData;
      final map = (root is Map)
          ? Map<String, dynamic>.from(root)
          : <String, dynamic>{};
      final msg = map['message']?.toString() ?? 'Check your email for OTP';

      if (resp.isSuccess /* 201 per your log */ ) {
        await AuthService.registerDeviceIfNeeded();
        AppSnackBar.showSuccess(msg);
        // No tokens at this step. Go to OTP screen.
        Get.to(
          () => SignUpVerifyOtpScreen(email: emailTEController.text.trim()),
        );
        return;
      }

      // Non-success
      AppSnackBar.showError(resp.errorMessage ?? msg);
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
      AppSnackBar.showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgetEmail(String email) async {
    final Map<String, dynamic> requestBody = {'email': email};

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
}
