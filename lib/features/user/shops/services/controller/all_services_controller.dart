import 'dart:async';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/services/data/all_services_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllServicesController extends GetxController {
  var isLoading = false.obs;
  var allServices = AllServicesModel().obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    fetchAllServices();
    searchController.addListener(_onSearchChanged);
    super.onInit();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchAllServices(search: searchController.text);
    });
  }

  Future<void> fetchAllServices({String? search}) async {
    isLoading.value = true;
    try {
      final networkCaller = NetworkCaller();
      final token = AuthService.accessToken;

      String url = AppUrls.allServices;
      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }

      final response = await networkCaller.getRequest(url, token: token);

      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          allServices.value = AllServicesModel.fromJson(response.responseData);
        } else {
          throw Exception('Unexpected response data format');
        }
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to fetch services.',
        );
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred while fetching services: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
