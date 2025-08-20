import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/icon_path.dart';
import 'on_boarding_screen.dart';

class OnBoardingScreenTwo extends StatelessWidget {
  const OnBoardingScreenTwo({super.key});

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
                  height: 520, // Adjust as needed
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        ImagePath.oneBoardingTwoImage,
                      ), // Replace with your image path
                      fit: BoxFit.cover, // Ensure the image covers the area
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 520, // Adjust as needed
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
                    text: "Book, Relax, and Enjoy!",
                    color: AppColors.black,
                    fontSize: getWidth(25),
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: getHeight(12)),
                  CustomText(
                    text:
                        "Your personal beauty and wellness guide. Let’s get you started!",
                    color: AppColors.black,
                    fontSize: getWidth(16),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: getHeight(40)),
                  CustomButton(
                    onPressed: () {
                      Get.to(
                        () => OnBoardingScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Get Started",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
