// features/user/shops/controller/all_shops_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class AllShopsController extends GetxController {
  var isLoading = false.obs;
  var allShops = AllShopsModel().obs;
  var isLocationAvailable = false.obs;

  final LocationService _locationService = LocationService();

  @override
  void onInit() {
    fetchAllShops(); // initial load
    super.onInit();
  }

  Future<void> fetchAllShops({String? query}) async {
    isLoading.value = true;

    try {
      final token = AuthService.accessToken;
      final networkCaller = NetworkCaller();

      // Build query string with search
      final uri = Uri.parse(AppUrls.allShops).replace(
        queryParameters: (query != null && query.isNotEmpty)
            ? {'search': query.trim()}
            : null,
      );

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

  // Convenience search method
  Future<void> searchShops(String q) => fetchAllShops(query: q);
}
