import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../model/get_my_service_model.dart';

class BusinessOwnerController extends GetxController {
  @override
  void onInit() {
    fetchAllMyService();
    super.onInit();
  }

  var isLoading = false.obs;
  var allServiceList = <GetMyServiceModel>[].obs;

  final RxList<GetMyServiceModel> discountedServices =
      <GetMyServiceModel>[].obs;

  Future<void> fetchAllMyService() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getMyService,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        if (response.responseData is List) {
          final serviceData = List<GetMyServiceModel>.from(
            response.responseData.map((x) => GetMyServiceModel.fromJson(x)),
          );
          allServiceList.value = serviceData;

          // Filter and store discounted services
          discountedServices.value = serviceData
              .where(
                (item) =>
                    item.discountPrice != null &&
                    double.tryParse(item.discountPrice!)! > 0,
              )
              .toList();
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
}
