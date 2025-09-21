import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/user/home/data/promotion_offers_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../booking/presentation/screens/shop_model.dart';
import '../data/category_model.dart';
import '../data/get_offer_service_model.dart';
import '../data/most_recommended_business_profile_model.dart';
import '../data/nearest_bar_bar_single_details.dart';
import '../data/nearest_barbar_model.dart';
import '../data/trending_service_model.dart';
import '../../shops/data/all_shops_model.dart';

class HomeController extends GetxController {
  // --- Existing Properties ---
  final PageController pageController = PageController();
  final PageController pageController1 = PageController();
  var searchText = ''.obs;
  RxList<ShopModel> searchResults = <ShopModel>[].obs;
  TextEditingController minDistanceController = TextEditingController();
  TextEditingController maxDistanceController = TextEditingController();
  final TextEditingController searchTEC = TextEditingController();
  var isLoading = false.obs;
  var nearestBarBarDetails = GetNearestBarbar().obs;
  var singleNearestBarBarDetails = AllBaBarSearchModel().obs;
  var allRecommendedBusinessProfileDetails =
      GetAllRecommendedBusinessProfileModel().obs;
  var allOfferServiceDetails = GetOfferServiceModel().obs;

  // --- New Properties for Home Screen ---
  var promotions = <PromotionModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var trendingServices = TrendingServiceModel().obs;
  var popularShops = AllShopsModel().obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch all data for the home screen
    fetchAllHomeData();

    // Add this listener to re-fetch data when the token is refreshed
    ever(AuthService.tokenRefreshCount, (_) {
      fetchAllHomeData();
    });

    // Keep existing search debounce logic
    debounce(
      searchText,
      (_) => fetchSearchResults(),
      time: const Duration(milliseconds: 500),
    );
  }

  // --- New Master Fetch Method ---
  Future<void> fetchAllHomeData() async {
    isLoading.value = true;
    await Future.wait([
      fetchPromotions(),
      fetchCategories(),
      fetchTrendingServices(),
      fetchPopularShops(),
    ]);
    isLoading.value = false;
  }

  // --- New Individual Fetch Methods ---
  Future<void> fetchPromotions() async {
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.promotions,
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        // API returns a list directly
        promotions.value = List<PromotionModel>.from(
          response.responseData.map((item) => PromotionModel.fromJson(item)),
        );
      }
    } catch (e) {
      AppSnackBar.showError('Could not fetch promotions: $e');
    }
  }

  Future<void> fetchCategories() async {
  try {
    final response = await NetworkCaller().getRequest(
      AppUrls.categories,
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) return;

    final raw = response.responseData;

    // Support either:
    // 1) [ {...}, {...} ]                 // root array
    // 2) { "data": [ {...}, {...} ] }     // wrapped in a map
    final List<dynamic> list;
    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['data'] is List) {
      list = raw['data'] as List;
    } else {
      throw Exception('Unexpected categories format: ${raw.runtimeType}');
    }

    categories.value = list
        .map((e) => CategoryModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  } catch (e) {
    AppSnackBar.showError('Could not fetch categories: $e');
  }
}


  Future<void> fetchTrendingServices() async {
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.trendingServices,
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        trendingServices.value = TrendingServiceModel.fromJson(
          response.responseData,
        );
      }
    } catch (e) {
      AppSnackBar.showError('Could not fetch trending services: $e');
    }
  }

  Future<void> fetchPopularShops() async {
  try {
    final resp = await NetworkCaller().getRequest(
      AppUrls.popularShops,
      token: AuthService.accessToken,
    );
    if (!resp.isSuccess) return;

    final raw = resp.responseData;

    // normalize to a list of shops
    late final List<dynamic> list;
    String? next;
    String? previous;

    if (raw is List) {
      list = raw;
    } else if (raw is Map && raw['results'] is List) {
      list = raw['results'] as List;
      next = raw['next'] as String?;
      previous = raw['previous'] as String?;
    } else {
      throw Exception('Unexpected popular shops format: ${raw.runtimeType}');
    }

    final shops = list
        .map((e) => Shop.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    // build the model your UI expects
    popularShops.value = AllShopsModel(
      next: next,
      previous: previous,
      shops: shops,
    );
  } catch (e) {
    AppSnackBar.showError('Could not fetch popular shops: $e');
  }
}


  // --- Existing Methods (Unchanged) ---
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

  Future<void> fetchNearest({required String lat, required String lon}) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.getNearByService(lat: lat, lon: lon),
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          nearestBarBarDetails.value = GetNearestBarbar.fromJson(
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

  Future<void> fetchNearestDetails({required String id}) async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.shopDetails(id),
        token: AuthService.accessToken,
      );
      if (response.isSuccess) {
        if (response.responseData is Map<String, dynamic>) {
          singleNearestBarBarDetails.value = AllBaBarSearchModel.fromJson(
            response.responseData,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
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
        if (response.responseData is Map<String, dynamic>) {
          allOfferServiceDetails.value = GetOfferServiceModel.fromJson(
            response.responseData,
          );
        } else {
          throw Exception('Unexpected response data format');
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
