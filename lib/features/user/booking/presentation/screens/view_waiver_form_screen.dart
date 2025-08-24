import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/features/user/booking/controller/view_waiver_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../../../../core/utils/constants/app_sizes.dart';
import '../../../../../../../routes/app_routes.dart';

class ViewWaiverFormScreen extends StatelessWidget {
  final String? bookingId;
  const ViewWaiverFormScreen({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ViewWaiverController());

    if (controller.waiverDetails.value.data == null) {
      controller.fetchUserForm(bookingId!);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: CustomText(
          text: "View Waiver Form",
          color: const Color(0xff212121),
          fontWeight: FontWeight.w600,
          fontSize: getWidth(21),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: ShowProgressIndicator());
        }

        final dataList = controller.waiverDetails.value.data ?? [];

        if (dataList.isEmpty) {
          return Center(
            child: CustomText(text: "No Waiver Form Here", color: Colors.grey),
          );
        }

        final data = dataList.first;

        controller.firstNameTEController.text = data.firstName ?? '';
        controller.lastNameTEController.text = data.lastName ?? '';
        controller.emailTEController.text = data.email ?? '';
        controller.phoneTEController.text = data.phone ?? '';
        controller.addressTEController.text = data.address ?? '';
        controller.cityTEController.text = data.city ?? '';
        controller.stateTEController.text = data.state ?? '';
        controller.postalCodeTEController.text =
            data.postalCode?.toString() ?? '';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Name and Last Name
                Row(
                  children: [
                    Expanded(
                      child: CustomTextAndTextFormField(
                        text: "First Name",
                        controller: controller.firstNameTEController,
                        hintText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.lastNameTEController,
                        text: "Last Name",
                        hintText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(12)),

                CustomTextAndTextFormField(
                  controller: controller.emailTEController,
                  text: "Email",
                  hintText: "",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),

                CustomTextAndTextFormField(
                  controller: controller.phoneTEController,
                  text: "Phone",
                  hintText: "",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),

                CustomTextAndTextFormField(
                  controller: controller.addressTEController,
                  text: "Address",
                  hintText: "",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(12)),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.cityTEController,
                        text: "City",
                        hintText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: getWidth(12)),
                    Expanded(
                      child: CustomTextAndTextFormField(
                        controller: controller.stateTEController,
                        text: "State",
                        hintText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(12)),

                CustomTextAndTextFormField(
                  controller: controller.postalCodeTEController,
                  text: "Postal Code",
                  hintText: "",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                ),
                SizedBox(height: getHeight(20)),

                CustomText(
                  text: "Medical History & Disclosure",
                  fontSize: getWidth(14),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: getHeight(10)),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: controller.selectedItem.value.isEmpty
                          ? null
                          : controller.selectedItem.value,
                      onChanged: (newValue) {
                        controller.selectedItem.value = newValue!;
                      },
                      validator: (value) =>
                          value == null ? 'Please select an option' : null,
                      items: controller.dropdownItems.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              color: const Color(0xff616161),
                              fontSize: getWidth(16),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintText: "Select an option",
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: getHeight(20)),

                Row(
                  children: [
                    Obx(
                      () => Checkbox(
                        value: controller.isChecked.value,
                        onChanged: (value) {
                          controller.isChecked.value = value ?? false;
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CustomText(text: "I agree to"),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        // Get.to(() => AgreementScreen(businessId: "",));
                      },
                      child: Text(
                        "Acknowledgment & Consent",
                        style: TextStyle(
                          fontSize: getWidth(15),
                          color: const Color(0xff7A49A5),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xff7A49A5),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(25)),

                CustomText(
                  text: "Client Signature",
                  fontSize: getWidth(17),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff141414),
                ),
                SizedBox(height: getHeight(15)),
                Container(
                  height: getHeight(160),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffECECED)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: data.clientSignature != null
                      ? Image.network(
                          data.clientSignature!,
                          fit: BoxFit.contain,
                        )
                      : Image.asset("assets/images/signature_image.png"),
                ),
                SizedBox(height: getHeight(28)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Reusable field
class CustomTextAndTextFormField extends StatelessWidget {
  final String text;
  final String hintText;
  final EdgeInsetsGeometry contentPadding;
  final TextEditingController? controller;

  const CustomTextAndTextFormField({
    super.key,
    required this.text,
    required this.hintText,
    required this.contentPadding,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: text,
          fontSize: getWidth(14),
          fontWeight: FontWeight.w500,
          color: const Color(0xff141414),
        ),
        SizedBox(height: getHeight(8)),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffECECED)),
            ),
          ),
        ),
      ],
    );
  }
}
