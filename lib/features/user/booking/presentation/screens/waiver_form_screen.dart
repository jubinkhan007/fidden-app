import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:fidden/features/business_owner/profile/controller/waiver_controller.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';

import '../../controller/user_waiver_controller.dart';
import 'aggrement_screen.dart';

class WaiverFormScreen extends StatelessWidget {
  const WaiverFormScreen({
    super.key,
    required this.bookingId,
    required this.businessId,
  });

  final String bookingId, businessId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserWaiverBookingController());
    final profileController = Get.find<ProfileController>();
    controller.fetchWaiverDetails(businessId);

    final fullName = profileController.profileDetails.value.data?.name ?? '';
    final nameParts = fullName.split(" ");
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : '';

    controller.firstNameTEController.text = firstName;
    controller.lastNameTEController.text = lastName;
    controller.emailTEController.text =
        profileController.profileDetails.value.data?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
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
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [SizedBox(height: 300), ShowProgressIndicator()],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.firstNameTEController
                          ..text =
                              (profileController.profileDetails.value.data?.name
                                  ?.split(" ")
                                  .first ??
                              ''),
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
                        controller: controller.lastNameTEController
                          ..text =
                              (profileController.profileDetails.value.data?.name
                                  ?.split(" ")
                                  .last ??
                              ''),
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
                CustomTextAndTextFormField(
                  controller: controller.emailTEController
                    ..text =
                        (profileController.profileDetails.value.data?.email ??
                        ''),
                  text: "Email",
                  hintText: "",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),
                CustomTextAndTextFormField(
                  controller: controller.phoneTEController,
                  keyboardType: TextInputType.phone,
                  text: "Phone",
                  hintText: "Enter phone",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),
                CustomTextAndTextFormField(
                  controller: controller.addressTEController,
                  text: "Address",
                  hintText: "Enter address",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.cityTEController,
                        text: "City",
                        hintText: "Enter city",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.stateTEController,
                        text: "State",
                        hintText: "Enter state",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(12)),
                CustomTextAndTextFormField(
                  controller: controller.postalCodeTEController,
                  keyboardType: TextInputType.phone,
                  text: "Postal Code",
                  hintText: "Enter postal code",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(20)),
                CustomText(
                  text: "Medical History & Disclosure",
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: getHeight(10)),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xffFFFFFF),
                      value: controller.selectedItem.value.isEmpty
                          ? null
                          : controller.selectedItem.value,
                      onChanged: (newValue) {
                        controller.selectedItem.value = newValue!;
                      },
                      validator: (value) =>
                          value == null ? 'Please select an option' : null,
                      items: controller.waiverDetails.value.data?.medicalHistory
                          ?.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: const Color(0xff616161),
                                  fontSize: getWidth(16),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          })
                          .toList(),
                      decoration: InputDecoration(
                        filled: true,
                        //fillColor: const Color(0xffFFFFFF),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintText: "Select an option",
                        hintStyle: TextStyle(
                          color: const Color(0xff616161),
                          fontSize: getWidth(10),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: getHeight(20)),
                Row(
                  children: [
                    Obx(
                      () => SizedBox(
                        width: 18,
                        height: 18,
                        child: Checkbox(
                          value: controller.isChecked.value,
                          onChanged: (value) {
                            controller.toggleCheckbox(value);
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CustomText(text: "I agree to"),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => AgreementScreen(businessId: businessId));
                      },
                      child: Text(
                        "Acknowledgment & Consent",
                        style: TextStyle(
                          fontSize: getWidth(15),
                          color: const Color(0xff7A49A5),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xff7A49A5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: "Client Signature",
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff141414),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(10)),
                Container(
                  height: getHeight(160),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    border: Border.all(color: const Color(0xffECECED)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Signature(
                    controller: controller.signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: getHeight(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        controller.clearSignature();
                      },
                      child: const Text('Clear'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        controller.saveSignature();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(20)),
                Obx(() {
                  if (controller.signatureImage.value != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Saved Signature:",
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: getHeight(10)),
                        Container(
                          height: getHeight(160),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            border: Border.all(color: const Color(0xffECECED)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Image.memory(
                              controller.signatureImage.value!,
                              height: getHeight(100),
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
                SizedBox(height: getHeight(24)),
                Obx(
                  () => controller.isLoading.value
                      ? const SpinKitWave(
                          color: AppColors.primaryColor,
                          size: 30.0,
                        )
                      : CustomButton(
                          onPressed: () {
                            controller.createForm(
                              bookingId: bookingId,
                              firstName: controller.firstNameTEController.text,
                              lastName: controller.lastNameTEController.text,
                              email: controller.emailTEController.text,
                              phone: controller.phoneTEController.text,
                              address: controller.addressTEController.text,
                              city: controller.cityTEController.text,
                              state: controller.stateTEController.text,
                              postalCode:
                                  controller.postalCodeTEController.text,
                            );
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
            );
          }),
        ),
      ),
    );
  }
}

class CustomTextAndTextFormField extends StatelessWidget {
  final String text;
  final String hintText;
  final EdgeInsetsGeometry contentPadding;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const CustomTextAndTextFormField({
    super.key,
    required this.text,
    required this.hintText,
    required this.contentPadding,
    this.controller,
    this.keyboardType,
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
          keyboardType: keyboardType,
          controller: controller,
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
