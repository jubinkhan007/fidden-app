import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';

import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../controller/forget_email_and_otp_controler.dart';

class ForgetEmailScreen extends StatelessWidget {
  const ForgetEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordAndOtpController());
    final emailTEController = TextEditingController();
    final GlobalKey<FormState> formKey =
        GlobalKey<FormState>(); // Form key added
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getHeight(24)),
                CustomAppBar(
                  firstText: 'Reset password',
                  secondText: "Please enter your email to reset the password",
                ),
                SizedBox(height: getHeight(52)),
                CustomText(
                  text: "Email",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: emailTEController,
                  hintText: "example@gmail.com",
                  validator: (value) {
                    // Add basic email validation
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null; // Validation passed
                  },
                ),
                Spacer(),
                Obx(
                  () => controller.isLoading.value
                      ? const SpinKitWave(
                          color: AppColors.primaryColor,
                          size: 30.0,
                        )
                      : CustomButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              controller.forgetEmail2(
                                emailTEController.text.toString(),
                              );
                              // Perform the action
                            }

                            // if (_formKey.currentState?.validate() ?? false) {
                            //   loginController.login();
                            //   //Get.toNamed(AppRoute.landingScreen);
                            // }
                          },
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                SizedBox(height: getHeight(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
