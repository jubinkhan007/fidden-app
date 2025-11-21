// lib/features/user/shops/services/controller/all_services_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/services/data/all_services_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllServicesController extends GetxController {
  // ---------- UI state ----------
  final isLoading = false.obs;           // first page
  final isLoadingMore = false.obs;       // pagination spinner

  // Keep the server model (for next/prev) and a merged list for UI
  final allServices = AllServicesModel().obs;
  final results = <ServiceResult>[].obs;

  bool get hasLocalData => results.isNotEmpty;

  // Infinite scroll
  final ScrollController scrollController = ScrollController();

  // Search (debounced)
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Filters / sort state
  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
  final RxnString sortKey = RxnString(); // distance | rating | reviews | price_asc | price_desc | new
  final _currentCategoryId = RxnInt();

  // Location
  final LocationService _locationService = LocationService();
  final isLocationAvailable = false.obs;
  Position? _position;

  // Optional initial category
  final int? categoryId;
  AllServicesController({this.categoryId});

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    _bootstrap();

    searchController.addListener(_onSearchChanged);

    // Infinite scroll trigger
    scrollController.addListener(() {
      final pos = scrollController.position;
      // Fire when we’re close to the bottom
      if (pos.extentAfter < 500) {
        loadNext();
      }
    });
  }

  Future<void> _bootstrap() async {
    await _initLocation();

    if (categoryId != null) {
      filters['category'] = categoryId;
    }

    await _loadFromCache();    // may populate results/next

    if (hasLocalData) {
      isLoading.value = false; // show cache immediately
    }

    // Revalidate first page (replace list)
    unawaited(_fetch(reset: true));
  }

  // ---------- Cache helpers ----------
  Future<String> _cacheKey() async {
    final search = searchController.text.trim();
    final map = <String, dynamic>{
      'search': search,
      'filters': Map<String, dynamic>.from(filters),
      'sort': sortKey.value,
    };
    return 'all_services_cache:${jsonEncode(map)}';
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _cacheKey();
      final s = prefs.getString(key);
      if (s == null || s.isEmpty) return;

      final decoded = jsonDecode(s) as Map<String, dynamic>;
      final model = AllServicesModel.fromJson(decoded);
      allServices.value = model;
      results.assignAll(model.results ?? []);
    } catch (_) {/* ignore */}
  }

  Future<void> _saveToCache(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = await _cacheKey();
      await prefs.setString(key, jsonEncode(json));
    } catch (_) {/* ignore */}
  }

  // ---------- Public filters/sort/search API ----------
  void filterByCategory(int? newCategoryId) {
    if (_currentCategoryId.value == newCategoryId) return;
    _currentCategoryId.value = newCategoryId;

    filters.clear();
    searchController.clear();

    if (newCategoryId != null) {
      filters['category'] = newCategoryId;
    }
    _fetch(reset: true);
  }

  Future<void> applyFilters(Map<String, dynamic> f) async {
    filters.assignAll(f);
    await _fetch(reset: true);
  }

  Future<void> clearFilters() async {
    filters.clear();
    await _fetch(reset: true);
  }

  Future<void> setSort(String? key) async {
    sortKey.value = key;
    await _fetch(reset: true);
  }

  Future<void> fetchAllServices({String? search}) async {
    await _fetch(reset: true);
  }

  Future<void> fetchAllServicesWithFilters(Map<String, dynamic> f) async {
    filters.assignAll(f);
    await _fetch(reset: true);
  }

  Future<void> refreshFirstPage() => _fetch(reset: true);

  // ---------- Internals ----------
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetch(reset: true);
    });
  }

  Future<void> _initLocation() async {
    try {
      _position = await _locationService.getCurrentPosition();
      isLocationAvailable.value = _position != null;

      if (_position == null) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _position = last;
          isLocationAvailable.value = true;
        }
      }
    } catch (_) {
      isLocationAvailable.value = false;
    }
  }

  Map<String, String> _buildQuery() {
    final q = <String, String>{};

    final search = searchController.text.trim();
    if (search.isNotEmpty) q['search'] = search;

    final cat = filters['category'];
    if (cat != null && '$cat'.isNotEmpty) q['category'] = '$cat';

    final minPrice = filters['min_price'];
    final maxPrice = filters['max_price'];
    if (minPrice != null) q['min_price'] = '$minPrice';
    if (maxPrice != null) q['max_price'] = '$maxPrice';

    final duration = filters['duration'];
    if (duration != null) q['max_duration'] = '$duration';

    final distance = filters['distance'];
    if (distance != null) q['max_distance'] = '$distance';

    final rating = filters['rating'];
    if (rating != null) q['min_rating'] = '$rating';

    final s = sortKey.value;
    if (s != null && s.isNotEmpty) q['sort'] = s;

    final needsLocation = (s == 'distance') || distance != null;
    if (needsLocation && _position != null) {
      q['location'] = '${_position!.latitude},${_position!.longitude}';
    }

    return q;
  }

  Map<String, dynamic> _buildBody() {
    if (_position == null) return {};
    return {'location': '${_position!.latitude},${_position!.longitude}'};
  }

  String _withTrailingSlash(String url) => url.endsWith('/') ? url : '$url/';


  String _urlFromNextCursor(String next) {
    final nextUri = Uri.parse(next);
    final base = _withTrailingSlash(AppUrls.allServices); // your canonical base
    // Keep whatever query params backend returned (usually just `cursor`)
    final params = Map<String, String>.from(nextUri.queryParameters);
    return Uri.parse(base).replace(queryParameters: params).toString();
  }

  /// Core fetcher.
  /// reset=true  → first page, replace list, cache
  /// reset=false → follow `next`, append
  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      isLoading.value = true;
    } else {
      if (isLoadingMore.value) return; // guard
      final nxt = allServices.value.next;
      if (nxt == null || nxt.trim().isEmpty) return;
      isLoadingMore.value = true;
    }

    try {
      final networkCaller = NetworkCaller();
      final token = AuthService.accessToken;

      String url;

      if (reset) {
        final base = _withTrailingSlash(AppUrls.allServices);
        final q = _buildQuery();
        url = q.isEmpty
            ? base
            : Uri.parse(base).replace(queryParameters: q).toString();
      } else {
        url = _urlFromNextCursor(allServices.value.next!);
      }
      debugPrint('[services] ${reset ? 'FIRST' : 'NEXT'} url => $url');


      final response = await networkCaller.getRequestWithBody(
        url,
        token: token,
        body: _buildBody(),
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(response.responseData);
        final model = AllServicesModel.fromJson(map);
        debugPrint('[services] got ${model.results?.length ?? 0} items, next=${model.next}');

        allServices.value = model; // for next/prev

        if (reset) {
          results.assignAll(model.results ?? []);
          unawaited(_saveToCache(map));
          if (scrollController.hasClients &&
              scrollController.position.pixels > 50) {
            scrollController.jumpTo(0);
          }
        } else {
          final more = model.results ?? const <ServiceResult>[];
          if (more.isNotEmpty) results.addAll(more);
        }
      } else {
        if (reset && !hasLocalData) {
          AppSnackBar.showError(
              response.errorMessage ?? 'Failed to fetch services.');
        }
      }
    } catch (e) {
      if (reset && !hasLocalData) {
        AppSnackBar.showError('An error occurred while fetching services: $e');
      }
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadNext() => _fetch(reset: false);

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
