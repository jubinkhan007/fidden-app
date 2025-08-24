import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/utils/logging/logger.dart';

class ReminderController extends GetxController {
  TextEditingController titleTEController = TextEditingController();
  TextEditingController descriptionTEController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> makeReminder(String userId) async {
    final Map<String, dynamic> requestBody = {
      "title": titleTEController.text,
      "body": descriptionTEController.text,
    };

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.createReminder(userId),
        body: requestBody,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess(
          "We sent a reminder to user device successfully",
        );
        titleTEController.clear();
        descriptionTEController.clear();
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
