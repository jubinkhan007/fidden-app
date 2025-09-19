import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/constants/icon_path.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      appBar: AppBar(
        title: CustomText(
          text: "My Profile",
          color: Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(22),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        // Added for scrollability
        child: Column(
          children: [
            SizedBox(height: getHeight(34)),
            Obx(() {
              if (controller.isLoading.value) {
                return buildProfileShimmer(); // Shows loading shimmer
              }
              // This Column only builds AFTER data is loaded
              return Column(
                children: [
                  // --- Profile Info ---
                  SizedBox(
                    width: getWidth(150),
                    height: getHeight(150),
                    child: CircleAvatar(
                      backgroundImage:
                          controller.profileDetails.value.data?.image != null
                          ? NetworkImage(
                              // Append a unique timestamp to force a reload
                              "${controller.profileDetails.value.data?.image}",
                            )
                          : const AssetImage(ImagePath.profileImage)
                                as ImageProvider,
                    ),
                  ),
                  SizedBox(height: getHeight(18)),
                  CustomText(
                    text:
                        controller.profileDetails.value.data?.name ??
                        "Anonymous User",
                    color: Color(0xff232323),
                    fontSize: getWidth(26),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(8)),
                  CustomText(
                    text: controller.profileDetails.value.data?.email ?? '',
                    color: Color(0xffA3A3A3),
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: getHeight(40)),

                  // --- Action Buttons (Now inside Obx) ---
                  CustomProfileButton(
                    title: 'Edit Profile',
                    firstImageString: IconPath.editIcon,
                    onTap: () {
                      Get.toNamed(AppRoute.editProfileScreen);
                    },
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomProfileButton(
                    title: 'Notification',
                    firstImageString: IconPath.notificationIcon,
                    onTap: () {
                      Get.toNamed(AppRoute.notificationScreen);
                    },
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomProfileButton(
                    title: 'Account Settings',
                    firstImageString: IconPath.settingsGear,
                    onTap: () {
                      Get.toNamed(AppRoute.accountSettingsScreen);
                    },
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomProfileButton(
                    title: 'Wishlist',
                    firstImageString: 'assets/icons/wishlist.png',
                    onTap: () {
                      Get.toNamed(AppRoute.wishListScreen);
                    },
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomProfileButton(
                    title: 'Term & Policy',
                    firstImageString: IconPath.termsAndConditionIcon,
                    onTap: () {
                      Get.toNamed(AppRoute.termsAndConditionScreen);
                    },
                  ),
                  SizedBox(height: getHeight(16)),
                  CustomProfileButton(
                    title: 'Logout',
                    firstImageString: IconPath.logOutIcon,
                    onTap: () {
                      showDeleteDialog(
                        onConfirm: () {
                          AuthService.logoutUser();
                          print("Message Deleted!");
                        },
                        title: "Log Out?",
                        middleText:
                            "Are you sure you want to logout form your account?",
                        confirm: "Logout",
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog({
    required VoidCallback onConfirm,
    required String title, // e.g. "Logout"
    required String middleText, // e.g. "Are you sure you want to log out?"
    required String confirm, // e.g. "Yes, Logout"
  }) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 70,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // title
              Text(
                title, // "Logout"
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),

              // message
              Text(
                middleText, // "Are you sure you want to log out?"
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // actions
              Row(
                children: [
                  // Cancel (red filled)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0113A), // app red
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Yes, Logout (text button)
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: TextButton(
                        onPressed: () {
                          onConfirm();
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          confirm, // "Yes, Logout"
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      isDismissible: true,
      enableDrag: true,
    );
  }
}

Widget buildProfileShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Column(
      children: [
        Container(
          width: getWidth(150),
          height: getHeight(150),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: getHeight(18)),
        Container(
          height: getHeight(26),
          width: getWidth(120),
          color: Colors.white,
        ),
        SizedBox(height: getHeight(8)),
        Container(
          height: getHeight(14),
          width: getWidth(180),
          color: Colors.white,
        ),
      ],
    ),
  );
}

class CustomProfileButton extends StatelessWidget {
  const CustomProfileButton({
    super.key,
    required this.title,
    this.firstImageString,
    this.secondImageString,
    this.onTap,
    this.containerColor,
    this.firstContainerColor,
    this.secondContainerColor,
    this.textColor,
  });

  final String title;
  final String? firstImageString, secondImageString;
  final void Function()? onTap;
  final Color? containerColor,
      firstContainerColor,
      secondContainerColor,
      textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: getWidth(24), right: getWidth(24)),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  firstImageString!,
                  height: getHeight(20),
                  width: getWidth(20),
                  color: Color(0xff141414),
                ),
                SizedBox(width: getWidth(18)),
                CustomText(
                  text: title,
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Color(0xff141414),
                ),
              ],
            ),
            GestureDetector(
              onTap: onTap,
              child: Image.asset(
                secondImageString ?? IconPath.rightArrowIcon,
                height: getHeight(26),
                width: getWidth(26),
                color: Color(0xff141414),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
