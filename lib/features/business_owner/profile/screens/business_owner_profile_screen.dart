import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/profile/screens/waiver_form_create_screen.dart';
import 'package:fidden/features/business_owner/profile/screens/widgets/business_owner_shimmer.dart';
import 'package:fidden/features/business_owner/reviews/ui/reviews_screen.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../core/utils/constants/icon_path.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/utils/constants/image_path.dart';
import '../../../user/profile/controller/profile_controller.dart';
import '../controller/busines_owner_profile_controller.dart';
import 'add_business_owner_profile_screen.dart';
import 'edit_business_profile_screen.dart';

class BusinessOwnerProfileScreen extends StatelessWidget {
  const BusinessOwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final controller1 = Get.find<BusinessOwnerProfileController>();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: CustomText(
          text: "My Profile",
          color: Color(0xff212121),
          fontWeight: FontWeight.bold,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final _ = controller1.profileDetails.value;
        if (controller.isLoading.value) {
          return BusinessOwnerProfileShimmer();
        }

        final hasBusiness = controller1.profileDetails.value.data != null;
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: getHeight(10)),
              Column(
                children: [
                  SizedBox(
                    width: getWidth(150),
                    height: getHeight(150),
                    child: CircleAvatar(
                      backgroundImage:
                          controller.profileDetails.value.data?.image != null
                          ? NetworkImage(
                              controller.profileDetails.value.data?.image,
                            )
                          : AssetImage(ImagePath.profileImage),
                    ),
                  ),
                  SizedBox(height: getHeight(18)),
                  CustomText(
                    text:
                        controller.profileDetails.value.data?.name ??
                        'Anonymous User',
                    color: Color(0xff232323),
                    fontSize: getWidth(26),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(0)),
                  CustomText(
                    text: controller.profileDetails.value.data?.email ?? '',
                    color: Color(0xffA3A3A3),
                    fontSize: getWidth(14),
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: getHeight(0)),
              Obx(() {
                final boc = Get.find<BusinessOwnerProfileController>();
                final isLoading =
                    boc.isCheckingStripeStatus.value; // <-- reactive read
                final status = boc.stripeStatus.value; // <-- reactive read
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16.0,0,16.0,16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final isOnboarded = status?.onboarded ?? false;
                final shopIdStr = boc.profileDetails.value.data?.id?.toString();

                if (isOnboarded) {
                  return _buildStripeStatusCard(
                    title: "Stripe Payments Active",
                    subtitle:
                        "You are ready to receive payments from customers.",
                    icon: Icons.check_circle,
                    color: Colors.green,
                  );
                }
                if (shopIdStr == null || shopIdStr.isEmpty)
                  return const SizedBox.shrink();

                final id = int.tryParse(shopIdStr);
                return _buildStripeOnboardingCard(
                  onPressed: id == null
                      ? () {}
                      : () => boc.startStripeOnboarding(id),
                );
              }),
              CustomProfileButton(
                title: 'Edit Profile',
                firstImageString: IconPath.editIcon,
                onTap: () {
                  Get.toNamed(AppRoute.editProfileScreen);
                },
              ),
              SizedBox(height: getHeight(16)),
              hasBusiness
                  ? CustomProfileButton(
  title: 'Edit Business Profile',
  firstImageString: IconPath.editIcon,
  onTap: () async {
    final boc = Get.find<BusinessOwnerProfileController>();

    final res = await Get.to(() => EditBusinessOwnerProfileScreen(
      id: boc.profileDetails.value.data?.id ?? '',
    ));

    // if user deleted or saved successfully, refresh this screen's data
    if (res == true) {
      await boc.fetchProfileDetails(); // this will set data=null after delete
      // optional: also refresh guards/banners if your home uses them
      if (Get.isRegistered<BusinessOwnerController>()) {
        await Get.find<BusinessOwnerController>().refreshGuardsAndServices();
      }
    }
  },
)
                  : CustomProfileButton(
                      title: 'Business Profile',
                      firstImageString: IconPath.addIcon,
                      onTap: () {
                        Get.to(() => AddBusinessOwnerProfileScreen());
                      },
                    ),
              SizedBox(height: getHeight(16)),
              CustomProfileButton(
                title: 'My Reviews',
                firstImageString: IconPath.waiverFormIcon,
                onTap: () {
                  final shopId = controller1.profileDetails.value.data?.id
                      ?.toString();
                  if (shopId == null || shopId.isEmpty) {
                    Get.snackbar(
                      'No business found',
                      'Create your business profile first.',
                    );
                    return;
                  }
                  Get.to(() => ReviewsScreen(shopId: shopId));
                },
              ),

              SizedBox(height: getHeight(16)),
              CustomProfileButton(
                title: 'Transactions',
                firstImageString: IconPath.transactionIcon,
                onTap: () {
                  Get.toNamed(AppRoute.transactionsScreen);
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
                title: 'Notification',
                firstImageString: IconPath.notificationIcon,
                onTap: () {
                  Get.toNamed(AppRoute.notificationScreen);
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
                      // Perform delete action here
                      print("Message Deleted!");
                    },
                    title: "Log Out?",
                    middleText:
                        "Are you sure you want to logout form your account?",
                    confirm: "Logout",
                  );
                },
              ),
              SizedBox(height: getHeight(16)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStripeStatusCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeOnboardingCard({required VoidCallback onPressed}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complete Setup to Get Paid",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Connect your shop with Stripe to securely accept payments and receive payouts directly to your bank account.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF635BFF,
                  ), // Stripe's brand color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Connect with Stripe"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDeleteDialog({
    required VoidCallback onConfirm,
    required String title,
    required String middleText,
    required String confirm,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.redAccent, // Highlighted title color
      ),
      middleText: middleText,
      middleTextStyle: TextStyle(fontSize: 16, color: Colors.black87),
      backgroundColor: Colors.white,
      radius: 15,
      contentPadding: EdgeInsets.all(20),
      barrierDismissible: false, // Prevent accidental dismiss
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(100, 48), // Ensures a minimum height of 48 pixels
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Cancel"),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm(); // Execute delete action
            Get.back(); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(100, 48), // Ensures a minimum height of 48 pixels
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(confirm),
          ),
        ),
      ],
    );
  }
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
                  color: Colors.blue,
                ),
                SizedBox(width: getWidth(18)),
                CustomText(
                  text: title,
                  fontSize: getWidth(17),
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Color(0xff2C2C2C),
                ),
              ],
            ),
            GestureDetector(
              onTap: onTap,
              child: Image.asset(
                secondImageString ?? IconPath.rightArrowIcon,
                height: getHeight(26),
                width: getWidth(26),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
