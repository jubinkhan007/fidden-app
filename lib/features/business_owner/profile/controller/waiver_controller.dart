import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/utils/logging/logger.dart';

class WaiverController extends GetxController {
  var isChecked = false.obs;
  var medicalConditions = <String, bool>{
    'Skin Conditions': false,
    'Allergies': false,
    'Heart Conditions': false,
    'High/Low Blood Pressure': false,
    'Diabetes': false,
    'Epilepsy/Seizures': false,
    'Pregnancy': false,
    'Recent Surgery': false,
    'Immune Disorders': false,
    'Other (Please specify)': false,
  }.obs;

  var selectedConditions = <String>[].obs;
  var selectedItem = 'Acknowledgment & Consent'.obs;
  var textField1 = ''.obs;
  var dataList = <Map<String, String>>[].obs;

  final List<String> dropdownItems = [
    'Acknowledgment & Consent',
    'Aftercare Instructions Provided',
  ];

  @override
  void onInit() {
    super.onInit();
    loadDataFromStorage();
  }

  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
    saveToStorage();
  }

  void toggleCondition(String condition) {
    medicalConditions[condition] = !(medicalConditions[condition] ?? false);

    if (medicalConditions[condition] == true) {
      if (!selectedConditions.contains(condition)) {
        selectedConditions.add(condition);
      }
    } else {
      selectedConditions.remove(condition);
    }
    saveToStorage();
  }

  void addData() {
    if (selectedItem.isNotEmpty && textField1.isNotEmpty) {
      dataList.add({
        'dropdown': selectedItem.value,
        'textField1': textField1.value,
      });
      selectedItem.value = '';
      textField1.value = '';
      saveToStorage();
    } else {
      Get.snackbar('Error', 'Please fill all fields');
    }
  }

  void deleteData(int index) {
    dataList.removeAt(index);
    saveToStorage();
    Get.snackbar('Success', 'Item deleted successfully');
  }

  void editData(int index, String newDescription) {
    dataList[index]['textField1'] = newDescription;
    dataList.refresh();
    saveToStorage();
    Get.snackbar('Success', 'Item updated successfully');
  }

  /// =====================
  /// STORAGE METHODS BELOW
  /// =====================

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Save isChecked
    await prefs.setBool('isChecked', isChecked.value);

    // Save medicalConditions
    await prefs.setString('medicalConditions', jsonEncode(medicalConditions));

    // Save selectedConditions
    await prefs.setStringList('selectedConditions', selectedConditions);

    // Save dataList
    await prefs.setString('dataList', jsonEncode(dataList));
  }

  Future<void> loadDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Load isChecked
    isChecked.value = prefs.getBool('isChecked') ?? false;

    // Load medicalConditions
    String? medicalJson = prefs.getString('medicalConditions');
    if (medicalJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(medicalJson);
      medicalConditions.value = decoded.map(
        (key, value) => MapEntry(key, value as bool),
      );
    }

    // Load selectedConditions
    selectedConditions.value = prefs.getStringList('selectedConditions') ?? [];

    // Load dataList
    String? dataListJson = prefs.getString('dataList');
    if (dataListJson != null) {
      List<dynamic> decodedList = jsonDecode(dataListJson);
      dataList.value = decodedList
          .map((e) => Map<String, String>.from(e))
          .toList();
    }
  }

  RxBool isLoading = false.obs;

  Future<void> makeWaiverForm() async {
    final Map<String, dynamic> requestBody = {
      "agreement": dataList,
      "medicalHistory": selectedConditions,
    };

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.formCreate,
        body: requestBody,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess("Successfully form created");
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppSnackBar.showError(e.toString());
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
