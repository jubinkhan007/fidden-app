// features/user/shops/controller/all_shops_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllShopsController extends GetxController {
  final isLoading = false.obs;
  final allShops = AllShopsModel().obs;
  bool get hasLocalData =>
      (allShops.value.shops != null && allShops.value.shops!.isNotEmpty);

  final isLocationAvailable = false.obs;

  // ✅ persistent category filter
  final selectedCategoryId = Rxn<int>();
  final selectedCategoryName = RxnString();

  final LocationService _locationService = LocationService();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;        // start in loading state to avoid empty flicker
    _bootstrap();                  // load cache first, then refresh
  }

  // --- Category helpers ---
  void setCategory({int? id, String? name}) {
    selectedCategoryId.value = id;
    selectedCategoryName.value = name;
  }
  void clearCategory() {
    selectedCategoryId.value = null;
    selectedCategoryName.value = null;
  }

  // --- Bootstrap: show cache instantly, then refresh in background ---
  Future<void> _bootstrap() async {
    await _loadFromCache();        // renders immediately if we have cache
    if (hasLocalData) isLoading.value = false;
    unawaited(fetchAllShops());    // always revalidate
  }

  // --- Cache helpers (key depends on search + category) ---
  Future<String> _cacheKey({String search = ''}) async {
    final map = <String, dynamic>{
      'search': search.trim(),
      'category_id': selectedCategoryId.value,
    };
    return 'all_shops_cache:${jsonEncode(map)}';
  }

  Future<void> _loadFromCache({String search = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _cacheKey(search: search);
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return;
      allShops.value = AllShopsModel.fromJson(jsonDecode(raw));
    } catch (_) {/* ignore */}
  }

  Future<void> _saveToCache(Map<String, dynamic> json, {String search = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _cacheKey(search: search);
      await prefs.setString(key, jsonEncode(json));
    } catch (_) {/* ignore */}
  }

  // --- Public API ---
  Future<void> fetchAllShops({String? query}) async {
    // keep UI responsive: if we already have cache, don't flash empty state
    isLoading.value = true;

    try {
      final token = AuthService.accessToken;
      final networkCaller = NetworkCaller();

      // Build query string with search + category
      final qp = <String, String>{};
      final search = (query ?? '').trim();
      if (search.isNotEmpty) qp['search'] = search;
      if (selectedCategoryId.value != null) {
        qp['category_id'] = selectedCategoryId.value!.toString();
      }

      final uri = Uri.parse(AppUrls.allShops)
          .replace(queryParameters: qp.isEmpty ? null : qp);

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
        final map = Map<String, dynamic>.from(response.responseData);
        allShops.value = AllShopsModel.fromJson(map);
        unawaited(_saveToCache(map, search: search));  // ✅ cache fresh data
      } else {
        // If we already show cached data, stay quiet; else show error
        if (!hasLocalData) {
          AppSnackBar.showError(
            response.errorMessage ?? 'Failed to fetch shops.',
          );
        }
      }
    } catch (e) {
      if (!hasLocalData) {
        AppSnackBar.showError('An error occurred: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Search should keep the category filter intact
  Future<void> searchShops(String q) async {
    // load potential search cache instantly, then fetch
    await _loadFromCache(search: q);
    if (!hasLocalData) isLoading.value = true;
    await fetchAllShops(query: q);
  }
}
