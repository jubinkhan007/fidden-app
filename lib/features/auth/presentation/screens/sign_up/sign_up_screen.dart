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
              padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerticalSpace(height: getHeight(24)),
                    // Logo
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        ImagePath.splashLogo,
                        height: getHeight(124),
                        width: getWidth(186),
                      ),
                    ),
                    VerticalSpace(height: getHeight(16)),
                    // Title
                    Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        text: "Create Account",
                        fontSize: getWidth(28),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191A1A),
                      ),
                    ),
                    VerticalSpace(height: getHeight(40)),

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
                    CustomText(
                      text: "Choose your role",
                      color: _label,
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: getHeight(10)),
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
                          hint: Text(
                            "Select",
                            style: TextStyle(
                              color: _hint,
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          items: signUpController.items.map((e) {
                            return DropdownMenuItem<String>(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontSize: getWidth(16),
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
                    VerticalSpace(height: getHeight(20)),

                    // Email
                    CustomText(
                      text: "Email",
                      color: _label,
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: getHeight(10)),
                    CustomTexFormField(
                      controller: signUpController.emailTEController,
                      hintText: "example@gmail.com",
                      inputDecoration: _decor("example@gmail.com"),
                      validator: AppValidator.validateEmail,
                    ),
                    VerticalSpace(height: getHeight(20)),

                    // Password
                    CustomText(
                      text: "Password",
                      color: _label,
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: getHeight(10)),
                    CustomTexFormField(
                      controller: signUpController.passwordTEController,
                      hintText: "Enter your password",
                      inputDecoration: _decor("Enter your password"),
                      isPassword: true,
                      validator: AppValidator.validatePassword,
                    ),

                    VerticalSpace(height: getHeight(24)),
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
                              height: getHeight(64),
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
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: getWidth(18),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),

                    VerticalSpace(height: getHeight(28)),
                    // Or continue with
                    Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        text: "Or continue with",
                        fontSize: getWidth(14),
                        color: _label,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    VerticalSpace(height: getHeight(16)),

                    // Google button (white, bordered)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Get.to(() => RoleSelectionScreen()),
                      child: Container(
                        height: getHeight(56),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _divider),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google_logo.png", // replace if your asset differs
                              height: getHeight(22),
                              width: getHeight(22),
                            ),
                            SizedBox(width: getWidth(10)),
                            Text(
                              "Google",
                              style: TextStyle(
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    VerticalSpace(height: getHeight(24)),
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "Already have an account?",
                          fontWeight: FontWeight.normal,
                          fontSize: getWidth(16),
                          color: const Color(0xFF677674),
                        ),
                        HorizontalSpace(width: getWidth(5)),
                        CustomTextButton(
                          isUnderline: true,
                          fontSize: getWidth(18),
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
                    VerticalSpace(height: getHeight(40)),
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
