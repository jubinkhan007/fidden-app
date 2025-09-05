import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/image_path.dart';
import '../../../../../routes/app_routes.dart';

class PasswordChangeSuccessfulScreen extends StatelessWidget {
  const PasswordChangeSuccessfulScreen({super.key});

  static const _bg = Color(0xFFF6F8FB); // page background to match mock

  @override
  Widget build(BuildContext context) {
    const maxW = 520.0; // tidy layout on large phones/tablets

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
              child: Column(
                children: [
                  // Center block (icon + message)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImagePath.successFullPasswordChangeImage,
                          // slightly larger to match artwork scale in mock
                          height: getHeight(200),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: getHeight(24)),
                        CustomText(
                          text:
                              "Congratulation! your password has been changed successfully!",
                          fontSize: getWidth(20),
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // CTA pinned near bottom – red pill button
                  SizedBox(
                    height: getHeight(56),
                    width: double.infinity,
                    child: CustomButton(
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
                  ),
                  SizedBox(height: getHeight(16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
