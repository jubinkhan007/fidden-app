import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/auth/presentation/screens/login/login_screen.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingThreeScreen extends StatelessWidget {
  const OnBoardingThreeScreen({super.key});

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
              ImagePath.fiddenLoginImage, // Correct image from your assets
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
                  stops: const [0.6, 0.9, 1.0], // Controls the fade points
                ),
              ),
            ),
          ),

          // Content Area (Text and Buttons)
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
                    "Customized to Your Needs",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827), // A dark, near-black color
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    "From haircuts and massages to skincare, find tailored services that match your style and beauty needs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF4B5563), // Muted grey for subtitle
                      height: 1.5, // Line height for readability
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Log in Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.setOnboardingSeen(
                          true,
                        ); // Mark onboarding as complete
                        Get.offAll(
                          () => LoginScreen(),
                        ); // Navigate to Login Screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .primaryColor, // Your app's primary red color
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await AuthService.setOnboardingSeen(
                          true,
                        ); // Mark onboarding as complete
                        Get.toNamed(
                          AppRoute.signUpScreen,
                        ); // Navigate to Sign Up screen
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFF7A49A5),
                          width: 1.5,
                        ), // Purple border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827), // Dark text color
                        ),
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
