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

  // final LoginController loginController = Get.find<LoginController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerticalSpace(height: getHeight(30)),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      ImagePath.splashLogo,
                      height: getHeight(114),
                      width: getWidth(176),
                    ),
                  ),
                  VerticalSpace(height: getHeight(20)),
                  Align(
                    alignment: Alignment.center,
                    child: CustomText(
                      text: "Create Account",
                      fontSize: getWidth(24),
                      fontWeight: FontWeight.w700,
                      color: Color(0xff191A1A),
                    ),
                  ),
                  VerticalSpace(height: getHeight(50)),

                  // User Name
                  // CustomText(
                  //     text: "User Name",
                  //     color: Color(0xff141414),
                  //     fontSize: getWidth(15),
                  //     fontWeight: FontWeight.w600),
                  // SizedBox(height: getHeight(10)),
                  // CustomTexFormField(
                  //   controller: signUpController.userNameTEController,
                  //   hintText: "Enter your name",
                  //   validator: (value) =>
                  //   value == null || value.isEmpty ? 'Name is required' : null,
                  // ),
                  // VerticalSpace(height: getHeight(20)),
                  // Dropdown (Choose your role)
                  CustomText(
                    text: "Choose your role",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0), width: 1),
                    ),
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        //dropdownColor: Color(0xffFFFFFF),
                        value: signUpController.selectedValue.value,
                        onChanged: (newValue) {
                          signUpController.selectedValue.value = newValue!;
                        },
                        validator: (value) =>
                            value == null ? 'Please select an option' : null,
                        items: signUpController.items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: getWidth(14),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xffFFFFFF),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,

                          hintText: "Select a role",
                          hintStyle: TextStyle(
                            color: Color(0xff616161),
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w400,
                          ),

                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  VerticalSpace(height: getHeight(20)),

                  // Email
                  CustomText(
                    text: "Email",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  CustomTexFormField(
                    controller: signUpController.emailTEController,
                    hintText: "Enter your email",
                    validator: AppValidator.validateEmail,
                  ),
                  VerticalSpace(height: getHeight(20)),

                  // Password
                  CustomText(
                    text: "Password",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  CustomTexFormField(
                    controller: signUpController.passwordTEController,
                    hintText: "Enter your password",
                    isPassword: true,
                    validator: AppValidator.validatePassword,
                  ),
                  VerticalSpace(height: getHeight(24)),
                  Obx(
                    () => signUpController.isLoading.value
                        ? const SpinKitWave(
                            color: AppColors.primaryColor,
                            size: 30.0,
                          )
                        : CustomButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
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

                  // Sign Up Button
                  VerticalSpace(height: getHeight(30)),
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

                  // Already have an account? Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "Already have an account?",
                        fontWeight: FontWeight.normal,
                        fontSize: getWidth(16),
                        color: Color(0xff677674),
                      ),
                      HorizontalSpace(width: getWidth(5)),
                      CustomTextButton(
                        isUnderline: true,
                        fontSize: getWidth(18),
                        onPressed: () {
                          Get.to(
                            () => LoginScreen(),
                            transition: Transition.rightToLeftWithFade,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        },
                        text: "Sign In",
                        fontWeight: FontWeight.w700,
                        color: Color(0xffDC143C),
                      ),
                    ],
                  ),
                  VerticalSpace(height: getHeight(56)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
