import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../booking/presentation/screens/shop_model.dart';
import '../data/get_offer_service_model.dart';
import '../data/most_recommended_business_profile_model.dart';
import '../data/nearest_bar_bar_single_details.dart';
import '../data/nearest_barbar_model.dart';

class HomeController extends GetxController {
  final PageController pageController = PageController();
  final PageController pageController1 = PageController();

  var searchText = ''.obs;
  RxList<ShopModel> searchResults =
      <ShopModel>[].obs; // Replace ShopModel with your actual model

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchText,
      (_) => fetchSearchResults(),
      time: Duration(milliseconds: 500),
    );
  }

  void updateSearch(String value) {
    searchText.value = value;
  }

  void clearSearchResults() {
    searchResults.clear();
    searchText.value = '';
    searchTEC.clear();
  }

  Future<void> fetchSearchResults() async {
    if (searchText.value.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        "${AppUrls.searchBusinessProfile}?search=${searchText.value}",
        token: AuthService.accessToken,
      );

      if (response.isSuccess &&
          response.responseData is Map<String, dynamic> &&
          response.responseData['data'] is List) {
        final parsedData = (response.responseData['data'] as List)
            .map((e) => ShopModel.fromJson(e))
            .toList();
        searchResults.assignAll(parsedData);
      } else {
        searchResults.clear();
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  TextEditingController minDistanceController = TextEditingController();
  TextEditingController maxDistanceController = TextEditingController();
  final TextEditingController searchTEC = TextEditingController();

  var isLoading = false.obs;
  var nearestBarBarDetails = GetNearestBarbar().obs;
  var singleNearestBarBarDetails = AllBaBarSearchModel().obs;
  var allRecommendedBusinessProfileDetails =
      GetAllRecommendedBusinessProfileModel().obs;
  var allOfferServiceDetails = GetOfferServiceModel().obs;

  // Function to fetch course details
  Future<void> fetchNearest({required String lat, required String lon}) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getNearByService(lat: lat, lon: lon),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          nearestBarBarDetails.value = GetNearestBarbar.fromJson(
            response.responseData,
          );
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

  Future<void> fetchNearestDetails({required String id}) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.editBusinessProfile(id),
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          final value = singleNearestBarBarDetails.value =
              AllBaBarSearchModel.fromJson(response.responseData);
          final model = AllBaBarSearchModel.fromJson(response.responseData);
          debugPrint(
            const JsonEncoder.withIndent('  ').convert(response.responseData),
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions

      debugPrint('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMostRecommendedBusinessProfile() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getAllMostRecommendedBusinessProfile,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          allRecommendedBusinessProfileDetails.value =
              GetAllRecommendedBusinessProfileModel.fromJson(
                response.responseData,
              );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOfferService() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.offerService,
        token: AuthService.accessToken,
      );

      if (response.isSuccess) {
        // Check if responseData is a String or Map
        if (response.responseData is Map<String, dynamic>) {
          allOfferServiceDetails.value = GetOfferServiceModel.fromJson(
            response.responseData,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
