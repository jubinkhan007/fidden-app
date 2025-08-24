import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/get_waiver_model.dart';

class ViewWaiverController extends GetxController {
  TextEditingController firstNameTEController = TextEditingController(
    text: "Wali",
  );
  TextEditingController lastNameTEController = TextEditingController(
    text: "Ullah",
  );
  TextEditingController emailTEController = TextEditingController(
    text: "waliullah8328@gmail.com",
  );
  TextEditingController addressTEController = TextEditingController(
    text: "Dhaka,Bangladesh",
  );
  TextEditingController phoneTEController = TextEditingController(
    text: "01893849385",
  );
  TextEditingController cityTEController = TextEditingController(text: "Dhaka");
  TextEditingController stateTEController = TextEditingController(
    text: "Dhaka",
  );
  TextEditingController postalCodeTEController = TextEditingController(
    text: "1216",
  );

  var selectedItem = "Skin Condition".obs;
  var dropdownItems = ["Skin Condition"];
  var isChecked = true.obs;

  var isLoading = false.obs;
  var waiverDetails = GetWaiverModel().obs;

  Future<void> fetchUserForm(String bookingId) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getCustomerForm(bookingId),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          waiverDetails.value = GetWaiverModel.fromJson(response.responseData);
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
