import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_button.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/auth/presentation/screens/login/role_selection_screen.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../../../core/common/styles/get_text_style.dart';
// import '../../../../../core/common/widgets/custom_button.dart';
// import '../../../../../core/common/widgets/custom_text.dart';
// import '../../../../../core/common/widgets/custom_text_button.dart';
// import '../../../../../core/common/widgets/custom_text_form_field.dart';

import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/app_spacers.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../../../controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController loginController = Get.find<LoginController>();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
            child: Form(
              key: _formKey, // Form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpace(height: getHeight(100)),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      ImagePath.splashLogo,
                      height: getHeight(124),
                      width: getWidth(186),
                    ),
                  ),
                  VerticalSpace(height: getHeight(20)),
                  Align(
                    alignment: Alignment.center,
                    child: CustomText(
                      text: "Welcome back",
                      fontSize: getWidth(28),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  VerticalSpace(height: getHeight(60)),

                  CustomText(
                    text: "Email",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  CustomTexFormField(
                    controller: loginController.emailController,
                    hintText: "Enter your email",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  VerticalSpace(height: getHeight(20)),
                  CustomText(
                    text: "Password",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),

                  CustomTexFormField(
                    hintText: "Enter your password",
                    controller: loginController.passwordController,
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
                  SizedBox(height: getHeight(20)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                      isUnderline: true,
                      onPressed: () {
                        Get.toNamed(AppRoute.forgetEmailScreen);
                      },
                      text: "Forgot Password?",
                      fontWeight: FontWeight.w500,
                      color: Color(0xff898989),
                    ),
                  ),
                  VerticalSpace(height: getHeight(24)),

                  CustomButton(
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

                  VerticalSpace(height: getHeight(24)),
                  Align(
                    alignment: Alignment.center,
                    child: CustomText(
                      text: "Or continue with",
                      fontSize: getWidth(14),
                      color: Color(0xff141414),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  VerticalSpace(height: getHeight(16)),

                  GestureDetector(
                    onTap: () {
                      Get.to(() => RoleSelectionScreen());
                    },
                    child: Image.asset(
                      "assets/images/google_sign_in.png",
                      height: getHeight(70),
                      width: double.infinity,
                    ),
                  ),

                  VerticalSpace(height: getHeight(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "Don't have an account?",
                        fontWeight: FontWeight.normal,
                        fontSize: getWidth(16),
                        color: Color(0xff677674),
                      ),
                      HorizontalSpace(width: getWidth(5)),
                      CustomTextButton(
                        isUnderline: true,
                        fontSize: getWidth(18),
                        onPressed: () {
                          Get.toNamed(AppRoute.signUpScreen);
                        },
                        text: "Sign Up",
                        fontWeight: FontWeight.w700,
                        color: Color(0xffDC143C),
                      ),
                    ],
                  ),
                  VerticalSpace(height: getHeight(36)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
