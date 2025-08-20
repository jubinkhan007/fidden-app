import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../../../../../routes/app_routes.dart';

class VerificationSuccessFullScreen extends StatelessWidget {
  const VerificationSuccessFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(height: getHeight(270)),
                  Image.asset(
                    ImagePath.verificationSuccessFullImage,
                    height: getHeight(160),
                    width: getWidth(230),
                  ),
                  SizedBox(height: getHeight(40)),
                  CustomText(
                    text: "Verification Successful!",
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getHeight(280)),
                  CustomButton(
                    onPressed: () {
                      Get.toNamed(AppRoute.loginScreen);
                      // if (_formKey.currentState?.validate() ?? false) {
                      //   loginController.login();
                      //   //Get.toNamed(AppRoute.landingScreen);
                      // }
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
      ),
    );
  }
}
