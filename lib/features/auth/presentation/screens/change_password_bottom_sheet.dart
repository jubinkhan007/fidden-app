import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/auth/controller/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordBottomSheet extends StatelessWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Current Password Field - Now using `obscureText`
              Obx(() => CustomTexFormField(
                controller: controller.currentPasswordController,
                hintText: 'Current Password',
                obscureText: controller.obscureCurrentPassword.value,
                validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your current password' : null,
                suffixIcon: IconButton(
                  icon: Icon(controller.obscureCurrentPassword.value ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => controller.togglePasswordVisibility(controller.obscureCurrentPassword),
                ),
              )),
              const SizedBox(height: 16),

              // New Password Field - Now using `obscureText`
              Obx(() => CustomTexFormField(
                controller: controller.newPasswordController,
                hintText: 'New Password',
                obscureText: controller.obscureNewPassword.value,
                validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a new password' : null,
                suffixIcon: IconButton(
                  icon: Icon(controller.obscureNewPassword.value ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => controller.togglePasswordVisibility(controller.obscureNewPassword),
                ),
              )),
              const SizedBox(height: 16),

              // Confirm New Password Field - Now using `obscureText`
              Obx(() => CustomTexFormField(
                controller: controller.confirmPasswordController,
                hintText: 'Confirm New Password',
                obscureText: controller.obscureConfirmPassword.value,
                validator: (value) => (value?.isEmpty ?? true) ? 'Please confirm your new password' : null,
                suffixIcon: IconButton(
                  icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => controller.togglePasswordVisibility(controller.obscureConfirmPassword),
                ),
              )),
              const SizedBox(height: 30),

              // Submit Button - CORRECTED to use `child` and `isLoading`
              Obx(() => CustomButton(
                isLoading: controller.isLoading.value,
                onPressed: controller.changePassword,
                child: const Text('Update Password', style: TextStyle(color: Colors.white),),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
