import 'dart:io';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/business_owner/home/controller/add_service_controller.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/app_colors.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/app_spacers.dart';
import '../../../../core/utils/constants/icon_path.dart';

class AddServiceScreen extends StatelessWidget {
  const AddServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddServiceController());
    final addServiceForm = GlobalKey<FormState>();
    final controller1 = Get.find<BusinessOwnerController>();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            Get.back();
            await controller1.fetchAllMyService();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text('Add Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: addServiceForm,
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
                  text: "Price",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.priceTEController,
                  hintText: "Type Price",
                  isPhoneField: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Price is required'
                      : null,
                ),
                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Discount Price",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.discountPriceTEController,
                  hintText: "0",
                  isPhoneField: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Price is required'
                      : null,
                ),
                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Category",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                Obx(
                  () => DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: controller.selectedCategoryId.value,
                    hint: Text("Select a category"),
                    onChanged: (newValue) {
                      controller.selectedCategoryId.value = newValue;
                    },
                    items: controller.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name ?? ''),
                      );
                    }).toList(),
                    validator: (value) =>
                        value == null ? 'Category is required' : null,
                  ),
                ),
                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Service Duration (minutes)",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.durationTEController,
                  hintText: "e.g., 30",
                  isPhoneField: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Duration is required'
                      : null,
                ),
                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Capacity",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                CustomTexFormField(
                  controller: controller.capacityTEController,
                  hintText: "e.g., 1",
                  isPhoneField: true,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Capacity is required'
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
                VerticalSpace(height: getHeight(20)),
                CustomText(
                  text: "Upload image",
                  color: Color(0xff141414),
                  fontSize: getWidth(15),
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: getHeight(10)),
                Obx(() {
                  return controller.selectedImagePath.value.isEmpty
                      ? SizedBox(
                          height: getHeight(180),
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                controller.pickImage();
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "Upload",
                                      color: Color(0xff767676),
                                      fontSize: getWidth(18),
                                    ),
                                    SizedBox(width: getWidth(10)),
                                    Image.asset(
                                      IconPath.uploadImageIcon,
                                      height: getHeight(19),
                                      width: getWidth(19),
                                      color: Color(0xff767676),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            controller.pickImage();
                          },
                          child: Container(
                            height: getHeight(180),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(
                                  File(controller.selectedImagePath.value),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                }),
                SizedBox(height: getHeight(32)),
                Obx(
                  () => controller.inProgress.value
                      ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                      : Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: CustomButton(
                            onPressed: () {
                              if (addServiceForm.currentState?.validate() ??
                                  false) {
                                controller.createService();
                              }
                            },
                            child: Text(
                              "Create service",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: getWidth(18),
                                fontWeight: FontWeight.w700,
                              ),
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
