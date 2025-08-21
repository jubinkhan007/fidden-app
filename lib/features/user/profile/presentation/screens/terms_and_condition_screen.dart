import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/constants/app_sizes.dart';

class TermsAndConditionScreen extends StatelessWidget {
  TermsAndConditionScreen({super.key});
  final controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F4F4),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            controller.fetchProfileDetails();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: CustomText(
          text: "Term & Policy",
          color: Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(24),
        ),
        centerTitle: true,
        backgroundColor: Color(0xffF4F4F4),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Terms of Use",
                color: Color(0xff232323),
                fontSize: getWidth(24),
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: getHeight(20)),
              CustomTerms(
                firstText: 'User Responsibilities:',
                secondText:
                    "Users are responsible for providing accurate information when booking appointments. Rescheduling or canceling appointments must be done at least 24 hours in advance.",
              ),
              SizedBox(height: getWidth(12)),
              CustomTerms(
                firstText: 'Service Usage:',
                secondText:
                    "The app is designed to assist users in scheduling and managing interior design appointments. Unauthorized use or tampering with the app is strictly prohibited.",
              ),
              SizedBox(height: getWidth(12)),
              CustomTerms(
                firstText: 'Third-Party Services:',
                secondText:
                    "The app may connect users with third-party apps. The app does not assume responsibility for the services provided by these professionals.",
              ),
              SizedBox(height: getWidth(45)),
              CustomText(
                text: "Privacy Policy",
                color: Color(0xff232323),
                fontSize: getWidth(24),
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: getHeight(24)),
              CustomTerms(
                firstText: 'User Responsibilities:',
                secondText:
                    "Users are responsible for providing accurate information when booking appointments. Rescheduling or canceling appointments must be done at least 24 hours in advance.",
              ),
              SizedBox(height: getWidth(12)),
              CustomTerms(
                firstText: 'Service Usage:',
                secondText:
                    "The app is designed to assist users in scheduling and managing interior design appointments. Unauthorized use or tampering with the app is strictly prohibited.",
              ),
              SizedBox(height: getWidth(12)),
              CustomTerms(
                firstText: 'Third-Party Services:',
                secondText:
                    "The app may connect users with third-party apps. The app does not assume responsibility for the services provided by these professionals.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTerms extends StatelessWidget {
  const CustomTerms({
    super.key,
    required this.firstText,
    required this.secondText,
  });

  final String firstText, secondText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text properly
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: getWidth(15)),
            Column(
              children: [
                SizedBox(height: getHeight(8)),
                Image.asset(
                  IconPath.dotIcon,
                  height: getHeight(5),
                  width: getWidth(5),
                ),
              ],
            ),
            SizedBox(width: getWidth(15)),
            Expanded(
              // Ensures text doesn't exceed screen width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: firstText,
                    color: Color(0xff212121),
                    fontWeight: FontWeight.w500,
                    fontSize: getWidth(18),
                  ),
                  CustomText(
                    text: secondText,
                    color: Color(0xff656565),
                    fontWeight: FontWeight.w400,
                    fontSize: getWidth(14),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: EdgeInsets.only(left: getWidth(35)),
        //   child: CustomText(
        //     text: secondText,
        //     color: Color(0xff656565),
        //     fontWeight: FontWeight.w400,
        //     fontSize: getWidth(14),
        //     textAlign: TextAlign.start,
        //   ),
        // ),
      ],
    );
  }
}
