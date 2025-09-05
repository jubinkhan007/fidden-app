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

  // 🎨 Design tokens (tuned to screenshot)
  static const _bg = Color(0xFFF6F8FB); // page background
  static const _label = Color(0xFF141414);
  static const _hint = Color(0xFF9AA2A1);
  static const _fieldFill = Colors.white;
  static const _fieldStroke = Color(0xFFE8E8EC);
  static const _primary = Color(0xFFDC143C);

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 16, height: 1.25),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _fieldStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordAndOtpController());
    final emailTEController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final maxW = 520.0; // keeps nice layout on tablets

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: getWidth(16)),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getHeight(16)),
                    // Header: back + title + subtitle (uses your CustomAppBar)
                    const CustomAppBar(
                      firstText: 'Reset password',
                      secondText:
                          'Please enter your email to reset the password',
                    ),
                    SizedBox(height: getHeight(40)),

                    // Label
                    CustomText(
                      text: "Email",
                      color: _label,
                      fontSize: getWidth(15),
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: getHeight(12)),

                    // Field (rounded, white, subtle border)
                    CustomTexFormField(
                      controller: emailTEController,
                      hintText: "example@gmail.com",
                      inputDecoration: _decor("example@gmail.com"),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email is required';
                        return null;
                      },
                    ),

                    const Spacer(),

                    // Bottom primary button – pill-like radius, fixed height
                    Obx(
                      () => controller.isLoading.value
                          ? const Align(
                              alignment: Alignment.center,
                              child: SpinKitWave(
                                color: AppColors.primaryColor,
                                size: 30,
                              ),
                            )
                          : SizedBox(
                              height: getHeight(56),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    controller.forgetEmail2(
                                      emailTEController.text.trim(),
                                    );
                                  }
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
                    ),
                    SizedBox(height: getHeight(24)),
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
