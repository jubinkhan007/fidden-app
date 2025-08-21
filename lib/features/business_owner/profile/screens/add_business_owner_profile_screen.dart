import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../core/utils/constants/app_sizes.dart';

import '../../../../core/utils/constants/app_spacers.dart';
import '../../../../core/utils/constants/icon_path.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../../../user/profile/controller/profile_controller.dart';
import '../controller/busines_owner_profile_controller.dart';
import 'map_screen.dart';

class AddBusinessOwnerProfileScreen extends StatelessWidget {
  const AddBusinessOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller1 = Get.put(BusinessOwnerProfileController());

    final nameTEController = TextEditingController();
    final emailTEController = TextEditingController();
    final locationTEController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xffffffff),
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller1.fetchProfileDetails();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),

        title: CustomText(
          text: "Business Profile",
          color: Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getHeight(24)),

            Padding(
              padding: EdgeInsets.only(
                left: getWidth(24),
                right: getHeight(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomText(text: "Add Business Profile",color: Color(0xff232323),fontSize: getWidth(24),fontWeight: FontWeight.w600,),
                  // SizedBox(height: getHeight(20),),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              SizedBox(
                                width: getWidth(150),
                                height: getHeight(150),
                                child: CircleAvatar(
                                  backgroundImage:
                                      controller1.profileImage.value != null
                                      ? FileImage(
                                          controller1.profileImage.value!,
                                        )
                                      : controller1
                                                .profileDetails
                                                .value
                                                .data
                                                ?.image !=
                                            null
                                      ? NetworkImage(
                                          controller1
                                                  .profileDetails
                                                  .value
                                                  .data
                                                  ?.image ??
                                              '',
                                        )
                                      : AssetImage(ImagePath.profileImage),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 10,
                                child: GestureDetector(
                                  onTap: () {
                                    controller1.pickImage();
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
                        CustomTextAndTextFormField(
                          controller: nameTEController
                            ..text =
                                controller1
                                    .profileDetails
                                    .value
                                    .data
                                    ?.businessName ??
                                '',

                          text: 'Shop Name',
                          hintText: "Enter your shop name",
                        ),
                        VerticalSpace(height: getHeight(20)),
                        CustomText(
                          text: "Address",
                          color: Color(0xff141414),
                          fontSize: getWidth(17),
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: getHeight(10)),
                        CustomTexFormField(
                          hintText: 'Select your address',
                          controller: locationTEController
                            ..text =
                                controller1
                                    .profileDetails
                                    .value
                                    .data
                                    ?.businessAddress ??
                                '',
                          readOnly: true, // Prevent manual typing
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              LatLng? selectedLocation = await Get.to(
                                () => MapScreenProfile(),
                              );
                              if (selectedLocation != null) {
                                String address = await _getAddressFromLatLng(
                                  selectedLocation,
                                );
                                locationTEController.text = address;
                                controller1.lat.value = selectedLocation
                                    .latitude
                                    .toString();
                                controller1.long.value = selectedLocation
                                    .longitude
                                    .toString();
                              }
                            },
                            child: Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        VerticalSpace(height: getHeight(20)),
                        CustomTextAndTextFormField(
                          controller: emailTEController
                            ..text =
                                controller1
                                    .profileDetails
                                    .value
                                    .data
                                    ?.details ??
                                '',
                          text: 'About Us',
                          hintText: "Write here",
                          maxLines: 3,
                        ),
                        VerticalSpace(height: getHeight(20)),
                      ],
                    ),
                  ),
                  CustomText(
                    text: "Add Schedule",
                    color: Color(0xff141414),
                    fontSize: getWidth(17),
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dayField(
                          isStart: true,
                          controller: controller1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dayField(
                          isStart: false,
                          controller: controller1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _timeField(
                          isStart: true,
                          controller: controller1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeField(
                          isStart: false,
                          controller: controller1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: getHeight(16)),
                  Obx(
                    () => controller1.isLoading.value
                        ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                        : CustomButton(
                            onPressed: () {
                              controller1.createBusinessProfile(
                                businessName: nameTEController.text,
                                businessAddress: locationTEController.text,
                                aboutUs: emailTEController.text,
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
                  VerticalSpace(height: getHeight(42)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
      return "Unknown location";
    } catch (e) {
      return "Failed to get address";
    }
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
    this.maxLines,
  });

  final String text, hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool? readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: text,
          color: Color(0xff141414),
          fontSize: getWidth(17),
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: getHeight(10)),
        CustomTexFormField(
          maxLines: maxLines ?? 1,
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

Widget _dayField({
  required bool isStart,
  required BusinessOwnerProfileController controller,
}) {
  return Obx(() {
    // Get the current value for startDay or endDay
    final value = isStart ? controller.startDay.value : controller.endDay.value;

    // Get the profile data for startDay or endDay, if available
    final profileDay = isStart
        ? controller.profileDetails.value.data?.startDay
        : controller.profileDetails.value.data?.endDay;

    // Display the day from the profile if available, otherwise use the current value or fallback to default
    final displayDay = value.isEmpty
        ? (profileDay?.isNotEmpty ?? false
              ? profileDay
              : (isStart ? "Monday" : "Friday"))
        : value;

    return _inputTile(
      label: displayDay!,
      icon: Icons.calendar_today,
      onTap: () => controller.pickDay(isStart: isStart),
    );
  });
}

Widget _timeField({
  required bool isStart,
  required BusinessOwnerProfileController controller,
}) {
  return Obx(() {
    final value = isStart
        ? controller.startTime.value
        : controller.endTime.value;
    final profileDay = isStart
        ? controller.profileDetails.value.data?.startTime
        : controller.profileDetails.value.data?.endTime;

    // Display the day from the profile if available, otherwise use the current value or fallback to default
    final displayDay = value.isEmpty
        ? (profileDay?.isNotEmpty ?? false
              ? profileDay
              : (isStart ? "09:00 AM" : "08:00 PM"))
        : value;

    return _inputTile(
      label: displayDay!,
      icon: Icons.access_time,
      onTap: () => controller.pickTime(isStart: isStart),
    );
  });
}

Widget _inputTile({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: SizedBox(
      height: 60,

      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Icon(icon, color: Colors.grey),
            ],
          ),
        ),
      ),
    ),
  );
}
