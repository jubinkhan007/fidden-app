import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:get/get.dart';

import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../../../core/utils/logging/logger.dart';
import '../../../routes/app_routes.dart';

class NewPasswordController extends GetxController {
  var isLoading = false.obs;

  Future<void> newPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    try {
      isLoading.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.resetPassword,
        body: requestBody,
      );

      if (response.isSuccess) {
        Get.toNamed(AppRoute.passwordChangeSuccessfulScreen);
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
