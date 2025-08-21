import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:fidden/features/business_owner/profile/controller/waiver_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/app_colors.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import 'add_aggrement_screen.dart';
import 'medical_history_discloser_screen.dart';

class WaiverFormCreateScreen extends StatelessWidget {
  const WaiverFormCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WaiverController());
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Waiver Form",
          color: const Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name and Last Name
              Row(
                children: [
                  Expanded(
                    child: CustomTextAndTextFormField(
                      text: "First Name",
                      hintText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded(
                    child: CustomTextAndTextFormField(
                      text: "Last Name",
                      hintText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(12)),

              // Email
              CustomTextAndTextFormField(
                text: "Email",
                hintText: "",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
              ),
              SizedBox(height: getHeight(12)),

              // Phone
              CustomTextAndTextFormField(
                text: "Phone",
                hintText: "",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
              ),
              SizedBox(height: getHeight(12)),

              // Address
              CustomTextAndTextFormField(
                text: "Address",
                hintText: "",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
              ),
              SizedBox(height: getHeight(12)),

              // City and State
              Row(
                children: [
                  Expanded(
                    child: CustomTextAndTextFormField(
                      text: "City",
                      hintText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: getWidth(12)),
                  Expanded(
                    child: CustomTextAndTextFormField(
                      text: "State",
                      hintText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(12)),

              // Postal Code
              CustomTextAndTextFormField(
                text: "Postal Code",
                hintText: "",
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
              ),
              SizedBox(height: getHeight(20)),

              // Medical History & Disclosure
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Medical History & Disclosure",
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff141414),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => MedicalHistoryScreen());
                    },
                    child: Image.asset(
                      IconPath.editIcon,
                      height: getHeight(22),
                      width: getWidth(22),
                      color: const Color(0xff7A49A5),
                    ),
                  ),
                ],
              ),
              SizedBox(height: getHeight(20)),

              // Acknowledgment & Consent
              GestureDetector(
                onTap: () {
                  Get.to(() => AddAgreementScreen());
                },
                child: Text(
                  "Acknowledgment & Consent",
                  style: TextStyle(
                    fontSize: getWidth(14),
                    color: const Color(0xff7A49A5),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xff7A49A5),
                  ),
                ),
              ),
              SizedBox(height: getHeight(20)),

              // Client Signature and Checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Client Signature",
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff141414),
                  ),
                  // Obx(() => SizedBox(
                  //   width: 24, // Set the width of the checkbox
                  //   height: 24, // Set the height of the checkbox
                  //   child: Checkbox(
                  //
                  //     value: controller.isChecked.value,
                  //     onChanged: (value) {
                  //       controller.toggleCheckbox(value); // Update the checkbox state
                  //     },
                  //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Remove extra padding
                  //   ),
                  // )),
                ],
              ),
              SizedBox(height: getHeight(10)),

              // Signature Box
              GestureDetector(
                onTap: () {
                  // Add signature functionality here
                },
                child: SizedBox(
                  height: getHeight(150),
                  child: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Sign Here",
                              color: const Color(0xff767676),
                              fontSize: getWidth(18),
                            ),
                            SizedBox(width: getWidth(10)),
                            Image.asset(
                              IconPath.signInHereIcon,
                              height: getHeight(22),
                              width: getWidth(22),
                              color: const Color(0xff767676),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: getHeight(24)),
              Obx(
                () => controller.isLoading.value
                    ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                    : CustomButton(
                        onPressed: () {
                          controller.makeWaiverForm();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: getHeight(20)),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for CustomTextAndTextFormField
class CustomTextAndTextFormField extends StatelessWidget {
  final String text;
  final String hintText;
  final EdgeInsetsGeometry contentPadding;

  const CustomTextAndTextFormField({
    super.key,
    required this.text,
    required this.hintText,
    required this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: text,
          fontSize: getWidth(14),
          fontWeight: FontWeight.w500,
          color: const Color(0xff141414),
        ),
        SizedBox(height: getHeight(8)),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffECECED)),
            ),
          ),
        ),
      ],
    );
  }
}
