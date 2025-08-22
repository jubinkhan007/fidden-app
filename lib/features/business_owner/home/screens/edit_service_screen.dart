import 'dart:io';
import 'package:fidden/core/commom/styles/get_text_style.dart';
import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/features/business_owner/home/controller/add_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/utils/constants/app_colors.dart';
import '../../../../core/utils/constants/app_sizes.dart';
import '../../../../core/utils/constants/app_spacers.dart';
import '../../../../core/utils/constants/icon_path.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, required this.id});

  final String id;

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final controller = Get.put(AddServiceController());
  final addServiceForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Fetch service details and then populate the controllers
    controller.fetchService(widget.id).then((_) {
      // Use addPostFrameCallback to ensure the widget is built before setting controller text
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final serviceDetails = controller.singleServiceDetails.value;
          controller.titleTEController.text = serviceDetails.title ?? '';
          controller.priceTEController.text = serviceDetails.price ?? '';
          controller.discountPriceTEController.text =
              serviceDetails.discountPrice ?? '';
          controller.descriptionTEController.text =
              serviceDetails.description ?? '';
          controller.durationTEController.text =
              serviceDetails.duration?.toString() ?? '';
          controller.capacityTEController.text =
              serviceDetails.capacity?.toString() ?? '';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Edit Service'),
        centerTitle: true,
        actions: [
          Obx(() {
            final isActive =
                controller.singleServiceDetails.value.isActive ?? false;
            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmationDialog();
                } else if (value == 'toggle_status') {
                  controller.toggleServiceStatus(widget.id);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'toggle_status',
                  child: Text(isActive ? 'Deactivate' : 'Activate'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: addServiceForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // I've removed the Obx wrapper from here as it was causing the error.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Title"),
                    _buildTextField(
                      controller.titleTEController,
                      hint: "Type title",
                      validator: (val) => val == null || val.isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Price"),
                    _buildTextField(
                      controller.priceTEController,
                      hint: "Type Price",
                      isPhone: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Price is required'
                          : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Discount Price"),
                    _buildTextField(
                      controller.discountPriceTEController,
                      hint: "0",
                      isPhone: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Price is required'
                          : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Service Duration (minutes)"),
                    _buildTextField(
                      controller.durationTEController,
                      hint: "e.g., 30",
                      isPhone: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Duration is required'
                          : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Capacity"),
                    _buildTextField(
                      controller.capacityTEController,
                      hint: "e.g., 1",
                      isPhone: true,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Capacity is required'
                          : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Description"),
                    _buildTextField(
                      controller.descriptionTEController,
                      hint: "Type Description",
                      maxLines: 5,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                  ],
                ),
                VerticalSpace(height: getHeight(20)),
                _buildLabel("Upload image"),
                SizedBox(height: getHeight(10)),
                Obx(() {
                  final selectedPath = controller.selectedImagePath.value;
                  final networkImage =
                      controller.singleServiceDetails.value.serviceImg;

                  if (selectedPath.isNotEmpty) {
                    return _buildFileImage(selectedPath, controller);
                  } else if (networkImage != null && networkImage.isNotEmpty) {
                    return _buildNetworkImage(networkImage, controller);
                  } else {
                    return _buildImageUploadBox(controller);
                  }
                }),
                SizedBox(height: getHeight(32)),
                Obx(
                  () => controller.inProgress.value
                      ? SpinKitWave(color: AppColors.primaryColor, size: 30.0)
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CustomButton(
                            onPressed: () {
                              if (addServiceForm.currentState?.validate() ??
                                  false) {
                                controller.updateService(id: widget.id);
                              }
                            },
                            child: Text(
                              "Update service",
                              style: getTextStyleMsrt(
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

  void _showDeleteConfirmationDialog() {
    Get.defaultDialog(
      title: "Delete Service",
      middleText: "Are you sure you want to delete this service?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteService(widget.id);
      },
    );
  }

  Widget _buildLabel(String text) {
    return CustomText(
      text: text,
      color: const Color(0xff141414),
      fontSize: getWidth(15),
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    String? Function(String?)? validator,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        SizedBox(height: getHeight(10)),
        CustomTexFormField(
          controller: controller,
          hintText: hint,
          validator: validator,
          isPhoneField: isPhone,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildImageUploadBox(AddServiceController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: SizedBox(
        height: getHeight(180),
        child: Card(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: "Upload",
                  color: const Color(0xff767676),
                  fontSize: getWidth(18),
                ),
                SizedBox(width: getWidth(10)),
                Image.asset(
                  IconPath.uploadImageIcon,
                  height: getHeight(19),
                  width: getWidth(19),
                  color: const Color(0xff767676),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url, AddServiceController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: getHeight(180),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildFileImage(String path, AddServiceController controller) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Container(
        height: getHeight(180),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: FileImage(File(path)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
