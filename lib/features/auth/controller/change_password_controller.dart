import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State management
  var isLoading = false.obs;
  var obscureCurrentPassword = true.obs;
  var obscureNewPassword = true.obs;
  var obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Method to toggle password visibility
  void togglePasswordVisibility(RxBool obscureVar) {
    obscureVar.value = !obscureVar.value;
  }

  // Main method to handle the password change process
  Future<void> changePassword() async {
    // 1. Validate the form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // 2. Check if new passwords match
    if (newPasswordController.text != confirmPasswordController.text) {
      AppSnackBar.showError('New passwords do not match.');
      return;
    }

    isLoading.value = true;

    try {
      // 3. Prepare the data for the API
      final body = {
        "old_password": currentPasswordController.text,
        "new_password": newPasswordController.text,
      };

      // 4. Call the API
      final response = await NetworkCaller().postRequest(
        AppUrls.changePassword,
        body: body,
        token: AuthService.accessToken,
      );

      // 5. --- CORRECTED: Handle the response ---
      if (response.isSuccess) {
        // On success, just close the sheet and return 'true'
        Get.back(result: true);
      } else {
        // On failure, show the error from within the sheet
        AppSnackBar.showError(response.errorMessage ?? 'Failed to change password. Please try again.');
      }
    } catch (e) {
      AppSnackBar.showError('An unexpected error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

