import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsAndConditionScreen extends StatelessWidget {
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Terms & Conditions",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Last Updated: 19 September 2025"),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: "1. Introduction",
                    content:
                        "Welcome to Fidden! These Terms and Conditions govern your use of our application and services. By accessing or using our app, you agree to be bound by these terms.",
                  ),
                  _buildSection(
                    title: "2. User Accounts",
                    content:
                        "To use certain features of the app, you must register for an account. You agree to provide accurate, current, and complete information during the registration process and to update such information to keep it accurate, current, and complete.",
                  ),
                  _buildSection(
                    title: "3. Services",
                    content:
                        "Our app provides a platform for booking appointments with barbers and stylists. We are not responsible for the services provided by the business owners, and any disputes must be resolved directly with them.",
                  ),
                  _buildSection(
                    title: "4. Payments",
                    content:
                        "All payments for bookings are processed through our secure third-party payment gateway. We do not store your credit card details. All sales are final and non-refundable except as required by law.",
                  ),
                  _buildSection(
                    title: "5. Privacy Policy",
                    content:
                        "Our Privacy Policy, which is available on our website, describes how we collect, use, and protect your personal data. By using our app, you agree to the collection and use of information in accordance with our Privacy Policy.",
                  ),
                  _buildSection(
                    title: "6. Limitation of Liability",
                    content:
                        "To the fullest extent permitted by applicable law, Fidden shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          height: 50,
          width: double.infinity,
          color: AppColors.primaryColor, // Use the 'color' property
          child: const Text( // Provide the button's content as a 'child'
            "Accept & Continue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5, // Line height for better readability
            ),
          ),
        ],
      ),
    );
  }
}