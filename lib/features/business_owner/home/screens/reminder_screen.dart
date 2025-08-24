import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants/app_colors.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/app_spacers.dart';

import '../controller/reminder_controller.dart';

class AddReminderScreen extends StatelessWidget {
  final String? userId;
  const AddReminderScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReminderController());
    final reminderFormKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(title: Text('Reminder'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: reminderFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Title",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.titleTEController,
                  hintText: "Type title",
                  validator: (value) => value == null || value.isEmpty
                      ? 'Title is required'
                      : null,
                ),

                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Description",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.descriptionTEController,
                  maxLines: 5,
                  hintText: "Type Description",
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
                ),

                SizedBox(height: getHeight(32)),
                Obx(
                  () => controller.isLoading.value
                      ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                      : CustomButton(
                          onPressed: () {
                            //Get.toNamed(AppRoute.verifyOTPScreen);
                            if (reminderFormKey.currentState?.validate() ??
                                false) {
                              controller.makeReminder(userId!);
                            }
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: getWidth(18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
