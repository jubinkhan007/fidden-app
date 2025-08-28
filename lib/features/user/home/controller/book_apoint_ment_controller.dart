import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/utils/logging/logger.dart';
import '../../booking/presentation/screens/waiver_form_screen.dart';
import '../data/book_time_model.dart';

class AppointmentController extends GetxController {
  var selectedDate = DateTime.now().obs;
  var selectedService = "".obs; // Only one selected service
  var selectedTime = "".obs;

  var isLoading = false.obs;
  var inProgress = false.obs;
  var nearestBarBarDetails = GetBookTimeModel().obs;

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  void selectService(String serviceName) {
    selectedService.value = serviceName;
  }

  bool isServiceSelected(String serviceName) {
    return selectedService.value == serviceName;
  }

  bool isTimeAvailable(String time) {
    final item = nearestBarBarDetails.value.data?.firstWhereOrNull(
      (d) => d.time == time,
    );
    return item != null && item.booked == false;
  }

  Future<void> fetchTime({
    required String businessId,
    required String date,
  }) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getServiceTime(businessId: businessId, date: date),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          nearestBarBarDetails.value = GetBookTimeModel.fromJson(
            response.responseData,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void createBooking({
    required String businessId,
    required String serviceId,
  }) async {
    final Map<String, dynamic> requestBody = {
      "businessId": businessId,
      "serviceId": serviceId,
      "bookingDate": DateFormat('yyyy-MM-dd').format(selectedDate.value),
      "bookingTime": selectedTime.value,
    };
    debugPrint(
      "-------------------------------------------------------------------",
    );
    debugPrint(requestBody.toString());

    try {
      inProgress.value = true;

      final response = await NetworkCaller().postRequest(
        AppUrls.createBooking,
        body: requestBody,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        String bookingId = response.responseData['data']['id'];
        Get.to(
          () => WaiverFormScreen(bookingId: bookingId, businessId: businessId),
        );

        // if (token != null) {
        //   await AuthService.saveToken(token, role!);
        // }
        // AppSnackBar.showSuccess("Successfully Booked the service");
      } else {
        AppSnackBar.showError(response.errorMessage);
      }
    } catch (e) {
      AppLoggerHelper.error('Error: $e');
    } finally {
      inProgress.value = false;
    }
  }
}
