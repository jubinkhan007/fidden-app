import 'dart:async';

import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';

// import '../../../../../core/common/styles/get_text_style.dart';
// import '../../../../../core/common/widgets/custom_app_bar.dart';
// import '../../../../../core/common/widgets/custom_button.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../controller/forget_email_and_otp_controler.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxInt _remainingTime = 60.obs;
  late Timer timer;
  final RxBool _enableResendCodeButton = false.obs;

  void _startResendCodeTimer() {
    _enableResendCodeButton.value = false;
    _remainingTime.value = 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingTime.value--;
      if (_remainingTime.value == 0) {
        t.cancel();
        _enableResendCodeButton.value = true;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _startResendCodeTimer();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordAndOtpController());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(24)),
              CustomAppBar(
                firstText: 'Verification code',
                secondText:
                    "Please check your phone. We have to sent the code verification to your email.",
              ),
              SizedBox(height: getHeight(70)),

              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) {},
                controller: _otpTEController,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderWidth: 1.5,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  activeColor: AppColors.primaryColor,
                  selectedColor: AppColors.primaryColor,
                  inactiveColor: Color(0xFFE0E0E0),
                ),
                cursorColor: Color(0xFF007AFF),
                keyboardType: TextInputType.number,
                enableActiveFill: true,
                textStyle: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: getWidth(20)),

              // TODO: enable button when 120s is done and invisible the text
              Align(
                alignment: Alignment.center,
                child: Obx(
                  () => _enableResendCodeButton.value == false
                      ? RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey),
                            text: "This code will be expired in ",
                            children: [
                              TextSpan(
                                text: "${_remainingTime.value}s",
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        )
                      : TextButton(
                          onPressed: controller.isResending.value
                              ? null
                              : () async {
                                  final ok = await controller.resendOtp(
                                    widget.email,
                                  );
                                  if (ok && mounted) _startResendCodeTimer();
                                },
                          child: const Text("Resend Code"),
                        ),
                ),
              ),
              SizedBox(height: getWidth(84)),
              Obx(
                () => controller.isLoading.value
                    ? const SpinKitWave(
                        color: AppColors.primaryColor,
                        size: 30.0,
                      )
                    : CustomButton(
                        onPressed: () {
                          controller.verifyOtp2(
                            widget.email,
                            _otpTEController.text,
                          );

                          // if (_formKey.currentState?.validate() ?? false) {
                          //   loginController.login();
                          //   //Get.toNamed(AppRoute.landingScreen);
                          // }
                        },
                        child: Text(
                          "Verify",
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
