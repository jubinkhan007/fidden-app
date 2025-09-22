import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_button.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/app_spacers.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/auth/presentation/screens/login/role_selection_screen.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController loginController = Get.find<LoginController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 🎨 Design tokens tuned to the screenshot
  static const _bg = Color(0xFFF4F4F5); // page background
  static const _label = Color(0xFF141414); // label text
  static const _hint = Color(0xFF9AA2A1); // placeholder
  static const _fieldFill = Color(0xFFF7F7F9); // textfield fill
  static const _fieldStroke = Color(0xFFE8E8EC);
  static const _muted = Color(0xFF898989); // forgot password
  static const _primary = Color(0xFFDC143C); // button + brand red
  static const _divider = Color(0xFFEDEDED);


  InputDecoration _decor(String hint, {bool isPassword = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 16, height: 1.2),
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
      // Let your CustomTexFormField handle the eye icon if isPassword==true
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxW = 480.0; // keeps it neat on tablets/large phones
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VerticalSpace(height: getHeight(48)),
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
                        // Big title
                        Align(
                          alignment: Alignment.center,
                          child: CustomText(
                            text: "Welcome back",
                            fontSize: getWidth(28), // matches mock
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        VerticalSpace(height: getHeight(40)),

                        // Email label + field
                        CustomText(
                          text: "Email",
                          color: _label,
                          fontSize: getWidth(15),
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: getHeight(10)),
                        // Keep your widget; we style via InputDecoration
                        CustomTexFormField(
                          controller: loginController.emailController,
                          hintText: "example@gmail.com",
                          inputDecoration: _decor("example@gmail.com"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            final ok = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value);
                            if (!ok)
                              return 'Please enter a valid email address';
                            return null;
                          },
                        ),

                        VerticalSpace(height: getHeight(20)),
                        // Password
                        CustomText(
                          text: "Password",
                          color: _label,
                          fontSize: getWidth(15),
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: getHeight(10)),
                  Obx(() => CustomTexFormField(
                    controller: loginController.passwordController,
                    hintText: "Enter your password",
                    obscureText: loginController.obscurePassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        loginController.obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => loginController
                          .togglePasswordVisibility(loginController.obscurePassword),
                    ),
                    isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                  ),

                        SizedBox(height: getHeight(12)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CustomTextButton(
                            fontSize: 12,
                            isUnderline: true,
                            onPressed: () =>
                                Get.toNamed(AppRoute.forgetEmailScreen),
                            text: "Forgot password?",
                            fontWeight: FontWeight.w500,
                            color: _muted,
                          ),
                        ),

                        VerticalSpace(height: getHeight(18)),
                        // Primary button – pill radius
                        SizedBox(
                          height: getHeight(66),
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
                              if (_formKey.currentState?.validate() ?? false) {
                                loginController.login();
                              }
                            },
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: getWidth(18),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        VerticalSpace(height: getHeight(24)),
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

                        // Google button (exact look)
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
                            padding: EdgeInsets.symmetric(
                              horizontal: getWidth(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Use your asset or the official vector
                                Image.asset(
                                  "assets/images/google_logo.png",
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

                        VerticalSpace(height: getHeight(28)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              // Matching the mock text literally
                              text: "I don't have a account?",
                              fontWeight: FontWeight.normal,
                              fontSize: getWidth(16),
                              color: const Color(0xFF677674),
                            ),
                            HorizontalSpace(width: getWidth(5)),
                            CustomTextButton(
                              isUnderline: true,
                              fontSize: getWidth(18),
                              onPressed: () =>
                                  Get.toNamed(AppRoute.signUpScreen),
                              text: "Sign up",
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ],
                        ),
                        VerticalSpace(height: getHeight(24)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
