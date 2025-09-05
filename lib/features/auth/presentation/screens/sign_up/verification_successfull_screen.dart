import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/image_path.dart';
import '../../../../../routes/app_routes.dart';

class VerificationSuccessFullScreen extends StatelessWidget {
  const VerificationSuccessFullScreen({super.key});

  static const _bg = Color(0xFFF6F8FB); // matches mock

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const maxW = 520.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 16),
              child: Column(
                children: [
                  // Centered illustration + title block
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ImagePath.verificationSuccessFullImage,
                          height: getHeight(200),
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: getHeight(28)),
                        CustomText(
                          text: "Verification Successful",
                          fontSize: getWidth(22),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // CTA — full width pill button
                  SizedBox(
                    height: getHeight(56),
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () => Get.toNamed(AppRoute.loginScreen),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
