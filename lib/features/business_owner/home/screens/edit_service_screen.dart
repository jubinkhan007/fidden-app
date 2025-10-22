// lib/features/business_owner/home/screens/edit_service_screen.dart
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

// ✅ Import only the top-level myShopId
import '../controller/business_owner_controller.dart' show myShopId;
import '../controller/owner_service_slot_controller.dart';
import 'widgets/manage_slots_card.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, required this.id});

  final String id;

  @override
  _EditServiceScreenState createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final controller = Get.put(AddServiceController());
  final addServiceForm = GlobalKey<FormState>();

  String? _slotsTag; // tag we use to register the slots controller

  @override
  void initState() {
    super.initState();

    controller.fetchService(widget.id).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final s = controller.singleServiceDetails.value;

        controller.titleTEController.text = s.title ?? '';
        controller.priceTEController.text = s.price ?? '';
        controller.discountPriceTEController.text = s.discountPrice ?? '';
        controller.descriptionTEController.text = s.description ?? '';
        controller.durationTEController.text = s.duration?.toString() ?? '';
        controller.capacityTEController.text = s.capacity?.toString() ?? '';

        // Create/init the slots controller once we know service id & shop id
        final sid = s.id;
        final shopId = myShopId.value; // read global RxnInt

        // inside initState -> after you compute sid/shopId
        if (sid != null && shopId != null) {
          final tag = 'svc_$sid';

          if (!Get.isRegistered<OwnerServiceSlotsController>(tag: tag)) {
            Get.put(
              OwnerServiceSlotsController(shopId: shopId, serviceId: sid),
              tag: tag,
            );
          } else {
            Get.find<OwnerServiceSlotsController>(tag: tag).refresh();
          }

          // 👇 make the UI rebuild so the slots section becomes visible
          setState(() {
            _slotsTag = tag;
          });
        }

      });
    });
  }

  @override
  void dispose() {
    if (_slotsTag != null &&
        Get.isRegistered<OwnerServiceSlotsController>(tag: _slotsTag)) {
      Get.delete<OwnerServiceSlotsController>(tag: _slotsTag!, force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Get.back(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: addServiceForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Title"),
                    _buildTextField(
                      controller.titleTEController,
                      hint: "Type title",
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Price"),
                    _buildTextField(
                      controller.priceTEController,
                      hint: "Type Price",
                      isPhone: true,
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Price is required' : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Discounted Price"),
                    _buildTextField(
                      controller.discountPriceTEController,
                      hint: "0",
                      isPhone: true,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Service Duration (minutes)"),
                    _buildTextField(
                      controller.durationTEController,
                      hint: "e.g., 30",
                      isPhone: true,
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Duration is required' : null,
                    ),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Capacity"),
                    _buildTextField(
                      controller.capacityTEController,
                      hint: "e.g., 1",
                      isPhone: true,
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Capacity is required' : null,
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
                    SizedBox(height: getHeight(10)),
                    // 18+ Toggle
                    Obx(() => SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Requires age 18+'),
                      value: controller.requiresAge18Plus.value,
                      onChanged: (v) => controller.requiresAge18Plus.value = v,
                    )),
                    VerticalSpace(height: getHeight(20)),
                    _buildLabel("Upload image"),
                    SizedBox(height: getHeight(10)),
                    Obx(() {
                      final selectedPath = controller.selectedImagePath.value;
                      final networkImage =
                          controller.singleServiceDetails.value.serviceImg;

                      if (selectedPath.isNotEmpty) {
                        return _buildFileImage(selectedPath, controller);
                      } else if (networkImage != null &&
                          networkImage.isNotEmpty) {
                        return _buildNetworkImage(networkImage, controller);
                      } else {
                        return _buildImageUploadBox(controller);
                      }
                    }),
                    const SizedBox(height: 8),
                    if (_slotsTag == null)
                      const SizedBox.shrink()
                    else if (!Get.isRegistered<OwnerServiceSlotsController>(tag: _slotsTag))
                      const SizedBox.shrink()
                    else
                      Builder(
                        builder: (_) =>
                            ManageSlotsCard(ctrl: Get.find<OwnerServiceSlotsController>(tag: _slotsTag!)),
                      ),
                    SizedBox(height: getHeight(12)),
                    Obx(() => controller.inProgress.value
                        ? SpinKitWave(
                        color: AppColors.primaryColor, size: 30.0)
                        : Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomButton(
                        onPressed: () {
                          if (addServiceForm.currentState?.validate() ?? false) {
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
                    )),
                  ],
                ),
              ),


            ],
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

  Widget _buildLabel(String text) => CustomText(
    text: text,
    color: const Color(0xff141414),
    fontSize: getWidth(15),
    fontWeight: FontWeight.w600,
  );

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
          image:
          DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
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
