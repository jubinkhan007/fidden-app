import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../core/utils/constants/app_spacers.dart';
import '../../../../../core/utils/constants/icon_path.dart';
import '../../controller/profile_controller.dart';

// 1. Converted to a StatefulWidget
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 2. Declared controllers here
  final nameTEController = TextEditingController();
  final emailTEController = TextEditingController();
  final phoneTEController = TextEditingController();
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    // 3. Initialized controller text in initState
    final profileData = controller.profileDetails.value.data;
    if (profileData != null) {
      nameTEController.text = profileData.name ?? '';
      emailTEController.text = profileData.email ?? '';
      phoneTEController.text = profileData.mobile_number ?? '';
    }
  }

  @override
  void dispose() {
    // 4. Dispose controllers to prevent memory leaks
    nameTEController.dispose();
    emailTEController.dispose();
    phoneTEController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: CustomText(
          text: "Edit Profile",
          color: const Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(
        () => SingleChildScrollView(
          // 5. Added SingleChildScrollView to prevent overflow
          padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getHeight(34)),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    SizedBox(
                      width: getWidth(150),
                      height: getHeight(150),
                      child: CircleAvatar(
                        backgroundImage: controller.profileImage.value != null
                            ? FileImage(controller.profileImage.value!)
                            : controller.profileDetails.value.data?.image !=
                                  null
                            ? NetworkImage(
                                // Also apply cache busting here
                                "${controller.profileDetails.value.data?.image}?v=${DateTime.now().millisecondsSinceEpoch}",
                              )
                            : const AssetImage(ImagePath.profileImage)
                                  as ImageProvider,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: () {
                          controller.pickImage();
                        },
                        child: SizedBox(
                          height: getHeight(35),
                          width: getWidth(35),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              IconPath.uploadImageIcon,
                              height: getHeight(17),
                              width: getWidth(17),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: getHeight(60)),
              CustomText(
                text: "Personal information",
                color: const Color(0xff232323),
                fontSize: getWidth(24),
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: getHeight(20)),
              CustomTextAndTextFormField(
                controller: nameTEController,
                text: 'Your Name',
                hintText: "Enter your name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              VerticalSpace(height: getHeight(20)),
              CustomTextAndTextFormField(
                controller: emailTEController,
                text: 'Email Address',
                hintText: "Enter your email",
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              VerticalSpace(height: getHeight(20)),
              CustomTextAndTextFormField(
                controller: phoneTEController,
                text: 'Phone Number',
                hintText: "Enter your phone number",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              VerticalSpace(height: getHeight(42)),
              Obx(
                () => controller.isLoading.value
                    ? const SpinKitWave(
                        color: AppColors.primaryColor,
                        size: 30.0,
                      )
                    : CustomButton(
                        onPressed: () {
                          controller.updateProfile(
                            name: nameTEController.text,
                            email: emailTEController.text,
                            mobileNumber: phoneTEController.text,
                          );
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: getWidth(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              SizedBox(height: getHeight(40)), // Added bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextAndTextFormField extends StatelessWidget {
  const CustomTextAndTextFormField({
    super.key,
    required this.text,
    required this.hintText,
    this.validator,
    this.controller,
    this.readOnly,
    this.contentPadding,
  });

  final String text, hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool? readOnly;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: text,
          color: const Color(0xff141414),
          fontSize: getWidth(17),
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: getHeight(10)),
        CustomTexFormField(
          readOnly: readOnly ?? false,
          controller: controller,
          hintText: hintText,
          validator: validator,
          contentPadding: contentPadding,
        ),
      ],
    );
  }
}
