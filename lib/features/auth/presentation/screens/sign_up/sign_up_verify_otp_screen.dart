import 'dart:async';
import 'package:fidden/core/commom/widgets/custom_app_bar.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
// CORRECTED: Only import the SignUpController
import 'package:fidden/features/auth/controller/sign_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../core/utils/constants/app_colors.dart';

class SignUpVerifyOtpScreen extends StatefulWidget {
  const SignUpVerifyOtpScreen({super.key, required this.email});
  final String email;

  @override
  State<SignUpVerifyOtpScreen> createState() => _SignUpVerifyOtpScreenState();
}

class _SignUpVerifyOtpScreenState extends State<SignUpVerifyOtpScreen> {
  static const int _otpLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _remainingTime = 30.obs;
  final _enableResendCodeButton = false.obs;

  late Timer _timer;
  // CORRECTED: Use the SignUpController for all logic
  late SignUpController _signUpController;
  // CORRECTED: Use a local controller for the text field
  final TextEditingController _otpTEController = TextEditingController();

  static const _bg = Color(0xFFF6F8FB);
  static const _title = Color(0xFF111827);
  static const _subtle = Color(0xFF6B7280);
  static const _fieldStroke = Color(0xFFE5E7EB);
  static const _fieldFill = Colors.white;
  static const _primary = Color(0xFFDC143C);

  @override
  void initState() {
    super.initState();
    // CORRECTED: Find the existing SignUpController instance
    _signUpController = Get.find<SignUpController>();

    // BUG FIX: The line that was sending the second email has been removed.

    // This listener is helpful for formatting and can be kept
    _otpTEController.addListener(() {
      final digitsOnly = _otpTEController.text.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly != _otpTEController.text || digitsOnly.length > _otpLength) {
        final clamped = digitsOnly.substring(
          0,
          digitsOnly.length.clamp(0, _otpLength),
        );
        _otpTEController.value = _otpTEController.value.copyWith(
          text: clamped,
          selection: TextSelection.collapsed(offset: clamped.length),
          composing: TextRange.empty,
        );
      }
    });

    _startResendCodeTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpTEController.dispose();
    super.dispose();
  }

  void _startResendCodeTimer() {
    _enableResendCodeButton.value = false;
    _remainingTime.value = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingTime.value--;
      if (_remainingTime.value <= 0) {
        t.cancel();
        _enableResendCodeButton.value = true;
      }
    });
  }

  String _mmss(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxW = 520.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: getHeight(8)),
                    const CustomAppBar(
                      firstText: 'Verification code',
                      secondText:
                      'Please check your email. We have to sent the code verification to your mail.',
                    ),
                    SizedBox(height: getHeight(36)),
                    PinCodeTextField(
                      appContext: context,
                      length: _otpLength,
                      // CORRECTED: Use the local controller
                      controller: _otpTEController,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      animationType: AnimationType.fade,
                      enableActiveFill: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(_otpLength),
                      ],
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
                        activeColor: _primary,
                        selectedColor: _primary,
                        inactiveColor: _fieldStroke,
                        activeFillColor: _fieldFill,
                        selectedFillColor: _fieldFill,
                        inactiveFillColor: _fieldFill,
                        borderWidth: 1.5,
                      ),
                      onChanged: (_) {},
                      beforeTextPaste: (t) => true,
                    ),

                    SizedBox(height: getHeight(24)),

                    Align(
                      alignment: Alignment.center,
                      child: Obx(() {
                        if (!_enableResendCodeButton.value) {
                          return RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: _subtle,
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
                          // CORRECTED: Check the correct controller's loading state
                          onPressed: _signUpController.isLoading.value
                              ? null
                              : () async {
                            // CORRECTED: Call the method that resends a sign-up OTP
                            await _signUpController.forgetEmail(
                              widget.email,
                            );
                            _startResendCodeTimer();
                          },
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: getHeight(48)),

                    Obx(
                      // CORRECTED: Check the correct controller's loading state
                          () => _signUpController.isLoading.value
                          ? const Center(
                        child: SpinKitWave(color: _primary, size: 30.0),
                      )
                          : SizedBox(
                        height: getHeight(56),
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () {
                            // CORRECTED: Call the new verify method
                            _signUpController.verifySignUpOtp(
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
          ),
        ),
      ),
    );
  }
}