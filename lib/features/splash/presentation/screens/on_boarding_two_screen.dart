import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants/icon_path.dart';
import 'on_boarding_screen.dart';

class OnBoardingScreenTwo extends StatelessWidget {
  const OnBoardingScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F4F4,
      ), // A light grey background from your design
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.65, // Image takes up top 65% of the screen
            child: Image.asset(
              ImagePath.oneBoardingTwoImage, // Correct image from your assets
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay for the fade-to-background effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height:
                screenHeight * 0.66, // Slightly larger to ensure a smooth fade
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFF4F4F4).withOpacity(0.8),
                    const Color(0xFFF4F4F4),
                  ],
                  stops: const [
                    0.6,
                    0.9,
                    1.0,
                  ], // Controls where the fade starts and ends
                ),
              ),
            ),
          ),
          // Content Area (Text and Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, // 8% horizontal padding
                vertical: screenHeight * 0.05, // 5% vertical padding
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Book, Relax, and Enjoy!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        0xFF111827,
                      ), // A dark, near-black color for high contrast
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    "Your personal beauty and wellness guide. Let’s get you started!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF4B5563), // A muted grey for the subtitle
                      height: 1.5, // Line height for better readability
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () =>
                              const OnBoardingThreeScreen(), // Navigates to the next screen
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .primaryColor, // Using your app's primary red color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0, // Flat button design as seen in the image
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            IconPath
                                .rightArrowIconSimple, // Correct arrow icon from your assets
                            height: getHeight(20),
                            width: getWidth(20),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
