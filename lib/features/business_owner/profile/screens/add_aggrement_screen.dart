import 'package:fidden/core/commom/widgets/custom_button.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/custom_text_form_field.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/constants/app_sizes.dart';
import '../controller/waiver_controller.dart';

class AddAgreementScreen extends StatelessWidget {
  const AddAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(WaiverController());
    return Scaffold(
      appBar: AppBar(title: Text('Add Agreements'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type of Agreement Dropdown
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Type Of Agreement",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0), width: 1),
                    ),
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        //dropdownColor: Color(0xffFFFFFF),
                        value: _controller.selectedItem.value.isEmpty
                            ? null
                            : _controller.selectedItem.value,
                        onChanged: (newValue) {
                          _controller.selectedItem.value = newValue!;
                        },
                        validator: (value) =>
                            value == null ? 'Please select an option' : null,
                        items: _controller.dropdownItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                //color: Color(0xff616161),
                                fontSize: getWidth(16),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          //fillColor: Color(0xffFFFFFF),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          hintText: "Select an option",
                          hintStyle: TextStyle(
                            color: Color(0xff616161),
                            fontSize: getWidth(10),
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ),
                  SizedBox(height: getHeight(20)),

                  // Description Text Field
                  CustomText(
                    text: "Description",
                    color: Color(0xff141414),
                    fontSize: getWidth(15),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  CustomTexFormField(
                    maxLines: 3,
                    hintText: "Write Description Here..",
                    onChange: (value) {
                      _controller.textField1.value = value;
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  SizedBox(height: getHeight(24)),

                  // Add Data Button
                  CustomButton(
                    onPressed: () {
                      _controller.addData(); // Add data to the list
                    },
                    child: Text(
                      "Add Data",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getWidth(18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getHeight(40)),

            // Display Stored Data
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Acknowledgment & Consent Details:",
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _controller.dataList.length,
                      itemBuilder: (context, index) {
                        final data = _controller.dataList[index];
                        return Column(
                          children: [
                            if (data['dropdown'] == "Acknowledgment & Consent")
                              Row(
                                children: [
                                  Image.asset(
                                    IconPath.dotIcon,
                                    height: 5,
                                    width: 5,
                                  ),
                                  SizedBox(width: getWidth(10)),
                                  SizedBox(
                                    width: getWidth(310),
                                    child: CustomText(
                                      text: data['textField1'] ?? '',
                                      fontWeight: FontWeight.w500,
                                      fontSize: getWidth(13),
                                    ),
                                  ),
                                  SizedBox(width: getWidth(15)),
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(
                                        context,
                                        _controller,
                                        index,
                                      );
                                    },
                                    child: Image.asset(
                                      IconPath.editIcon,
                                      height: getWidth(14),
                                      width: getWidth(14),
                                    ),
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18),
                                    onPressed: () {
                                      _controller.deleteData(index);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: getHeight(20)),

                  CustomText(
                    text: "Aftercare Instructions Provided:",
                    fontSize: getWidth(20),
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: getHeight(10)),
                  Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _controller.dataList.length,
                      itemBuilder: (context, index) {
                        final data = _controller.dataList[index];
                        return Column(
                          children: [
                            if (data['dropdown'] ==
                                "Aftercare Instructions Provided")
                              Row(
                                children: [
                                  Image.asset(
                                    IconPath.dotIcon,
                                    height: 5,
                                    width: 5,
                                  ),
                                  SizedBox(width: getWidth(10)),
                                  SizedBox(
                                    width: getWidth(310),
                                    child: CustomText(
                                      text: data['textField1'] ?? '',
                                      fontWeight: FontWeight.w500,
                                      fontSize: getWidth(13),
                                    ),
                                  ),
                                  SizedBox(width: getWidth(15)),
                                  GestureDetector(
                                    onTap: () {
                                      _showEditDialog(
                                        context,
                                        _controller,
                                        index,
                                      );
                                    },
                                    child: Image.asset(
                                      IconPath.editIcon,
                                      height: getWidth(14),
                                      width: getWidth(14),
                                    ),
                                  ),

                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18),
                                    onPressed: () {
                                      _controller.deleteData(index);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show edit dialog
  void _showEditDialog(
    BuildContext context,
    WaiverController controller,
    int index,
  ) {
    final TextEditingController editController = TextEditingController(
      text: controller.dataList[index]['textField1'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter new description'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.editData(index, editController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
