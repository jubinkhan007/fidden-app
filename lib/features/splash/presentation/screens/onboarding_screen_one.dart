import 'package:fidden/features/splash/presentation/screens/on_boarding_two_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // A light grey background
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
              'assets/images/onBoarding_one_image.jpg', // Make sure this path is correct in your pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay for fade effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.66, // Slightly larger to ensure full fade
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFFF4F4F4)],
                  stops: [0.7, 1.0], // Gradient starts fading around 70% down
                ),
              ),
            ),
          ),
          // Content Area
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
                    "Tailor Your Experience",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter', // Using Inter font for a modern look
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827), // A dark, near-black color
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    "Select your services and preferences to get the best recommendations.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF4B5563), // A muted grey for subtitle
                      height: 1.5, // Line height for better readability
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => OnBoardingScreenTwo(),
                          transition: Transition.rightToLeftWithFade,
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFDC143C,
                        ), // The specified red color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0, // Flat button design
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
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
