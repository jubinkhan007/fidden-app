// import 'package:fidden/core/common/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../../../core/common/styles/get_text_style.dart';
// import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../../../../../routes/app_routes.dart';

class PasswordChangeSuccessfulScreen extends StatelessWidget {
  const PasswordChangeSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: getHeight(290)),
                Image.asset(
                  ImagePath.successFullPasswordChangeImage,
                  height: getHeight(146),
                  width: getWidth(211),
                ),
                SizedBox(height: getHeight(20)),
                CustomText(
                  text:
                      "Congratulation! your password has been changed successfully!",
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getHeight(280)),
                CustomButton(
                  onPressed: () {
                    Get.toNamed(AppRoute.loginScreen);
                  },
                  child: Text(
                    "Go to Sign in",
                    style: TextStyle(
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
