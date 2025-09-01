// features/user/shops/controller/all_shops_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllShopsController extends GetxController {
  final isLoading = false.obs;
  final allShops = AllShopsModel().obs;
  final isLocationAvailable = false.obs;

  // ✅ persistent category filter
  final selectedCategoryId = Rxn<int>();
  final selectedCategoryName = RxnString();

  final LocationService _locationService = LocationService();

  // Don’t auto-fetch here; let the screen decide (so we can set category first)
  @override
  void onInit() {
    super.onInit();
  }

  void setCategory({int? id, String? name}) {
    selectedCategoryId.value = id;
    selectedCategoryName.value = name;
  }

  void clearCategory() {
    selectedCategoryId.value = null;
    selectedCategoryName.value = null;
  }

  Future<void> fetchAllShops({String? query}) async {
    isLoading.value = true;
    try {
      final token = AuthService.accessToken;
      final networkCaller = NetworkCaller();

      // Build query string with search + category
      final qp = <String, String>{};
      if (query != null && query.trim().isNotEmpty) {
        qp['search'] = query.trim();
      }
      if (selectedCategoryId.value != null) {
        // 👇 match your backend’s expected key (e.g. category_id / category / service_category)
        qp['category_id'] = selectedCategoryId.value!.toString();
      }

      final uri = Uri.parse(
        AppUrls.allShops,
      ).replace(queryParameters: qp.isEmpty ? null : qp);

      Map<String, dynamic>? body;

      // Add location in the body (like Postman)
      try {
        final pos = await _locationService.getCurrentPosition();
        isLocationAvailable.value = pos != null;
        if (pos != null) {
          body = {"location": "${pos.latitude},${pos.longitude}"};
        }
      } catch (_) {
        isLocationAvailable.value = false;
      }

      debugPrint('[AllShops] GET $uri with body $body');

      final response = await networkCaller.getRequestWithBody(
        uri.toString(),
        body: body,
        token: token,
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        allShops.value = AllShopsModel.fromJson(response.responseData);
        debugPrint('[AllShops] parsed ${allShops.value.shops?.length ?? 0}');
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to fetch shops.',
        );
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search should keep the category filter intact
  Future<void> searchShops(String q) => fetchAllShops(query: q);
}
