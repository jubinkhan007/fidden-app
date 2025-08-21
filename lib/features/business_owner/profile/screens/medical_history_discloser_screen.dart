import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/business_owner/profile/screens/waiver_form_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/app_sizes.dart';
import '../controller/waiver_controller.dart'; // Import the controller

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WaiverController());
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: "Medical History & Disclosure",
          color: const Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // List of Medical Conditions with Checkboxes
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: controller.medicalConditions.keys.map((condition) {
                  return Obx(
                    () => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: condition,
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(
                              height: getHeight(30),
                              width: getWidth(30),
                              child: Checkbox(
                                value: controller.medicalConditions[condition],
                                onChanged: (value) {
                                  controller.toggleCondition(
                                    condition,
                                  ); // Toggle the condition
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: getHeight(5)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Display Selected Conditions (for debugging or feedback)
            Obx(
              () => Text(
                'Selected Conditions: ${controller.selectedConditions.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            CustomButton(
              onPressed: () {
                Get.to(
                  () => WaiverFormCreateScreen(),
                  transition: Transition.rightToLeftWithFade,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: Text(
                "Save",
                style: TextStyle(
                  fontSize: getWidth(18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: getHeight(20)),
          ],
        ),
      ),
    );
  }
}
