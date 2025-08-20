// import 'package:fidden/core/common/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
// import '../../../../../core/common/styles/get_text_style.dart';
// import '../../../../../core/common/widgets/custom_app_bar.dart';
// import '../../../../../core/common/widgets/custom_button.dart';
// import '../../../../../core/common/widgets/custom_text_form_field.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_spacers.dart';
import '../../../controller/new_password_controller.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewPasswordController());
    final newPasswordTEController = TextEditingController();
    final confirmPasswordTEController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(24)),
              CustomAppBar(
                firstText: 'Set New Password',
                secondText:
                    "Create your new password so you can share your memories again.",
              ),
              SizedBox(height: getHeight(27)),
              CustomText(
                text: "New Password",
                fontSize: getWidth(14),
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              VerticalSpace(height: getHeight(10)),
              CustomTexFormField(
                controller: newPasswordTEController,
                isPassword: true,
                hintText: "Enter your new password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password is required";
                  }
                  if (value.length < 8) {
                    return "Password must be at least 8 characters long";
                  }
                  return null;
                },
              ),
              VerticalSpace(height: getHeight(20)),
              CustomText(
                text: "Confirm Password",
                fontSize: getWidth(14),
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              VerticalSpace(height: getHeight(10)),
              CustomTexFormField(
                controller: confirmPasswordTEController,
                isPassword: true,
                hintText: "Confirm your new password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm Password is required";
                  }
                  if (value != newPasswordTEController.text) {
                    return "Passwords do not match";
                  }
                  return null;
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
                          controller.newPassword(
                            email,
                            newPasswordTEController.text,
                            confirmPasswordTEController.text,
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
              SizedBox(height: getHeight(40)),
            ],
          ),
        ),
      ),
    );
  }
}
