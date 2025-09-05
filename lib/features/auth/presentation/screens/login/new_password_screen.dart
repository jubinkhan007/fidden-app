import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_spacers.dart';
import '../../../controller/new_password_controller.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key, required this.email});
  final String email;

  // 🎨 tokens tuned to the screenshot
  static const _bg = Color(0xFFF6F8FB);
  static const _label = Color(0xFF141414);
  static const _hint = Color(0xFF9AA2A1);
  static const _fieldFill = Colors.white;
  static const _fieldStroke = Color(0xFFE5E7EB);
  static const _primary = Color(0xFFDC143C);

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 16, height: 1.25),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _fieldStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewPasswordController());
    final newPasswordTEController = TextEditingController();
    final confirmPasswordTEController = TextEditingController();

    // keep layout tidy on big phones/tablets + respect keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const maxW = 520.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getHeight(8)),
                  const CustomAppBar(
                    firstText: 'Set New Password',
                    secondText:
                        'Create your new password so you can share your memories again.',
                  ),
                  SizedBox(height: getHeight(28)),

                  // Label casing matches mock
                  CustomText(
                    text: "New password",
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w700,
                    color: _label,
                  ),
                  VerticalSpace(height: getHeight(10)),
                  CustomTexFormField(
                    controller: newPasswordTEController,
                    isPassword: true,
                    hintText: "Enter your password",
                    inputDecoration: _decor("Enter your password"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password is required";
                      if (v.length < 8) {
                        return "Password must be at least 8 characters";
                      }
                      return null;
                    },
                  ),

                  VerticalSpace(height: getHeight(20)),
                  CustomText(
                    text: "Confirm password",
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w700,
                    color: _label,
                  ),
                  VerticalSpace(height: getHeight(10)),
                  CustomTexFormField(
                    controller: confirmPasswordTEController,
                    isPassword: true,
                    hintText: "Enter your password",
                    inputDecoration: _decor("Enter your password"),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Confirm Password is required";
                      }
                      if (v != newPasswordTEController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: getHeight(48)),
                  // CTA — pill red, full width
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(
                            child: SpinKitWave(
                              color: AppColors.primaryColor,
                              size: 30.0,
                            ),
                          )
                        : SizedBox(
                            height: getHeight(56),
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: () {
                                controller.newPassword(
                                  email,
                                  newPasswordTEController.text.trim(),
                                  confirmPasswordTEController.text.trim(),
                                );
                              },
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: getWidth(18),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
