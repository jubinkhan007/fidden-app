import 'dart:async';

import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../controller/forget_email_and_otp_controler.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  //  Use 4 to match the design; switch to 6 if your backend requires.
  static const int _otpLength = 4;

  final TextEditingController _otpTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final RxInt _remainingTime = 12.obs; // shows 00:12 in the mock
  final RxBool _enableResendCodeButton = false.obs;
  late Timer _timer;

  void _startResendCodeTimer() {
    _enableResendCodeButton.value = false;
    _remainingTime.value = 12;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingTime.value--;
      if (_remainingTime.value <= 0) {
        t.cancel();
        _enableResendCodeButton.value = true;
      }
    });
  }

  @override
  void initState() {
    _startResendCodeTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _mmss(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordAndOtpController());
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const bg = Color(0xFFF6F8FB); // page background to match mock
    const fieldStroke = Color(0xFFE5E7EB);
    const fieldFill = Colors.white;
    const primary = Color(0xFFDC143C);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(8)),
              const CustomAppBar(
                firstText: 'Verification code',
                secondText:
                    'Please check your phone. We have to sent the code verification to your number.',
              ),
              SizedBox(height: getHeight(36)),

              // OTP boxes — rounded, white, subtle border
              PinCodeTextField(
                appContext: context,
                length: _otpLength,
                controller: _otpTEController,
                keyboardType: TextInputType.number,
                enableActiveFill: true,
                cursorColor: Colors.black,
                textStyle: TextStyle(
                  fontSize: getWidth(20),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(14),
                  fieldHeight: getWidth(56),
                  fieldWidth: getWidth(56),
                  borderWidth: 1.5,
                  inactiveColor: fieldStroke,
                  selectedColor: primary,
                  activeColor: primary,
                  inactiveFillColor: fieldFill,
                  selectedFillColor: fieldFill,
                  activeFillColor: fieldFill,
                ),
                onChanged: (_) {},
                beforeTextPaste: (t) => true,
              ),

              SizedBox(height: getHeight(24)),

              // Resend countdown (centered): "Resend code in 00:12"
              Align(
                alignment: Alignment.center,
                child: Obx(() {
                  if (!_enableResendCodeButton.value) {
                    return RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                        children: [
                          const TextSpan(text: 'Resend code in '),
                          TextSpan(
                            text: _mmss(_remainingTime.value),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return TextButton(
                    onPressed: controller.isResending.value
                        ? null
                        : () async {
                            final ok = await controller.resendOtp(widget.email);
                            if (ok) _startResendCodeTimer();
                          },
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: getHeight(48)),

              // Pill red "Verify" button
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: SpinKitWave(color: primary, size: 30))
                    : SizedBox(
                        height: getHeight(56),
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () {
                            controller.verifyOtp2(
                              widget.email,
                              _otpTEController.text.trim(),
                            );
                          },
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),

              SizedBox(height: getHeight(16)),
            ],
          ),
        ),
      ),
    );
  }
}
