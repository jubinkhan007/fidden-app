import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_button.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/validators/app_validator.dart';
import 'package:fidden/features/auth/controller/sign_up_controller.dart';
import 'package:fidden/features/auth/presentation/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/app_spacers.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../login/role_selection_screen.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final SignUpController signUpController = Get.put(SignUpController());

  // 🎨 Tokens tuned to the screenshot
  static const _bg = Color(0xFFF4F4F5);
  static const _label = Color(0xFF141414);
  static const _hint = Color(0xFF9AA2A1);
  static const _fieldFill = Colors.white;
  static const _fieldStroke = Color(0xFFE8E8EC);
  static const _primary = Color(0xFFDC143C);
  static const _divider = Color(0xFFEDEDED);

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 16, height: 1.25),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxW = 520.0; // keeps a tight column on large phones/tablets

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 0,
                bottom: MediaQuery.of(context).viewPadding.bottom + 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        ImagePath.splashLogo,
                        height: 100,
                        width: 150,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF191A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // // User Name
                    // CustomText(
                    //   text: "User Name",
                    //   color: _label,
                    //   fontSize: getWidth(15),
                    //   fontWeight: FontWeight.w700,
                    // ),
                    // SizedBox(height: getHeight(10)),
                    // CustomTexFormField(
                    //   controller: signUpController.userNameTEController,
                    //   hintText: "Jason Morgan",
                    //   inputDecoration: _decor("Jason Morgan"),
                    //   validator: (v) => (v == null || v.trim().isEmpty)
                    //       ? 'Name is required'
                    //       : null,
                    // ),
                    // VerticalSpace(height: getHeight(20)),

                    // Role
                    const Text(
                      "Choose your role",
                      style: TextStyle(
                        color: _label,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _fieldFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _fieldStroke),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          value: signUpController.selectedValue.value,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                          ),
                          hint: const Text(
                            "Select",
                            style: TextStyle(
                              color: _hint,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          items: signUpController.items.map((e) {
                            return DropdownMenuItem<String>(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }).toList(),
                          validator: (v) =>
                              v == null ? 'Please select a role' : null,
                          onChanged: (v) =>
                              signUpController.selectedValue.value = v!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: _label,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTexFormField(
                      controller: signUpController.emailTEController,
                      hintText: "example@gmail.com",
                      inputDecoration: _decor("example@gmail.com"),
                      validator: AppValidator.validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Password
                    const Text(
                      "Password",
                      style: TextStyle(
                        color: _label,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTexFormField(
                      controller: signUpController.passwordTEController,
                      hintText: "Enter your password",
                      inputDecoration: _decor("Enter your password"),
                      isPassword: true,
                      validator: AppValidator.validatePassword,
                    ),

                    const SizedBox(height: 24),
                    // Primary CTA
                    Obx(
                      () => signUpController.isLoading.value
                          ? const Center(
                              child: SpinKitWave(
                                color: AppColors.primaryColor,
                                size: 30.0,
                              ),
                            )
                          : SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    signUpController.createAccount();
                                  }
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 28),
                    // Or continue with
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Or continue with",
                        style: TextStyle(
                          fontSize: 14,
                          color: _label,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Google button (white, bordered)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Get.to(() => RoleSelectionScreen()),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _divider),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google_logo.png",
                              height: 22,
                              width: 22,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F1F1F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF677674),
                            ),
                          ),
                        ),
                        CustomTextButton(
                          isUnderline: true,
                          fontSize: 18,
                          onPressed: () {
                            Get.to(
                              () => LoginScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          },
                          text: "Sign In",
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
