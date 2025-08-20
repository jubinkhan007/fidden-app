import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../auth/presentation/screens/login/login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    text: "Customized to Your Needs",
                    color: AppColors.black,
                    fontSize: getWidth(25),
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: getHeight(12)),
                  CustomText(
                    text:
                        "From haircuts and massages to skincare, find tailored services that match your style and beauty needs.",
                    color: AppColors.black,
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getHeight(40)),
                  CustomButton(
                    onPressed: () async {
                      await AuthService.setOnboardingSeen(true);
                      Get.to(
                        () => LoginScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(20)),
                  CustomButton(
                    onPressed: () async {
                      await AuthService.setOnboardingSeen(true);
                      Get.toNamed(AppRoute.signUpScreen);
                    },
                    color: Color(0xffF4F4F4),
                    borderColor: Color(0xff7A49A5),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: getWidth(16),
                        fontWeight: FontWeight.w700,
                      ),
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
