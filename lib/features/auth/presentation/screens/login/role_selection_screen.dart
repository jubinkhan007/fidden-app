// import 'package:fidden/core/common/widgets/custom_button.dart';
// import 'package:fidden/core/common/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/services/Auth_service.dart';
import '../../../../../core/utils/constants/icon_path.dart';
import 'google_sign_in.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GoogleSignInController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 420, // Adjust as needed
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        ImagePath.fiddenLoginImage,
                      ), // Replace with your image path
                      fit: BoxFit.cover, // Ensure the image covers the area
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 420, // Adjust as needed
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(
                          0xffF4F4F4,
                        ).withOpacity(0), // Transparent at the top
                        Color(0xffF4F4F4), // Solid at the bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),

            //Image.asset(ImagePath.fiddenLoginImage,width: getWidth(430),),
            SizedBox(height: getHeight(31)),
            Padding(
              padding: EdgeInsets.only(left: getWidth(24), right: getWidth(24)),
              child: Column(
                children: [
                  CustomText(
                    text: "Choose Your Role",
                    color: AppColors.black,
                    fontSize: getWidth(25),
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: getHeight(12)),
                  CustomText(
                    text:
                        "Select a role to tailor your experience and get the most out of the app.",
                    color: AppColors.black,
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getHeight(40)),
                  CustomButton(
                    onPressed: () async {
                      controller.signInWithGoogle("user");
                      // await AuthService.setOnboardingSeen(true);
                      // Get.to(
                      //
                      //       () => LoginScreen(),
                      //   transition: Transition.rightToLeftWithFade,
                      //   duration: Duration(milliseconds: 400),
                      //   curve: Curves.easeOut,
                      // );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "USER",
                          style: TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        //CustomText(text: "Get Started",color: Color(0xffFFFFFF),fontSize: getWidth(16),),
                        SizedBox(width: getWidth(10)),
                        Image.asset(
                          IconPath.rightArrowIconSimple,
                          height: getHeight(20),
                          width: getWidth(20),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: getHeight(20)),
                  CustomButton(
                    onPressed: () async {
                      controller.signInWithGoogle("owner");
                      //await AuthService.setOnboardingSeen(true);
                      // Get.toNamed(AppRoute.signUpScreen);
                    },
                    color: Color(0xffF4F4F4),
                    borderColor: Color(0xff7A49A5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "OWNER",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: getWidth(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        //CustomText(text: "Get Started",color: Color(0xffFFFFFF),fontSize: getWidth(16),),
                        SizedBox(width: getWidth(10)),
                        Image.asset(
                          IconPath.rightArrowIconSimple,
                          height: getHeight(20),
                          width: getWidth(20),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: getHeight(30)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
