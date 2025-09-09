import 'dart:async';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/services/data/all_services_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class AllServicesController extends GetxController {
  // UI state
  final isLoading = false.obs;
  final allServices = AllServicesModel().obs;

  // Search (debounced)
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Filters / sort state
  final RxMap<String, dynamic> filters = <String, dynamic>{}
      .obs; // category, min_price, max_price, duration, distance, rating...
  final RxnString sortKey =
      RxnString(); // e.g. distance | rating | reviews | price_asc | price_desc | new
  final _currentCategoryId = RxnInt();

  // Location for distance sort/filter (optional)
  final LocationService _locationService = LocationService();
  final isLocationAvailable = false.obs;
  Position? _position;
  final int? categoryId;
  AllServicesController({this.categoryId});

  @override
  void onInit() {
    super.onInit();
    _bootstrap(); // ⬅️ do async bootstrap
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _bootstrap() async {
    await _initLocation(); // ⬅️ wait for GPS
    if (categoryId != null) {
      filters['category'] = categoryId;
    }
    await _fetch(); // ⬅️ first fetch now includes location in body
  }

  void filterByCategory(int? newCategoryId) {
    // Only refetch if the category has actually changed
    if (_currentCategoryId.value == newCategoryId) {
      return;
    }
    _currentCategoryId.value = newCategoryId;

    // Clear old filters and search for a clean state
    filters.clear();
    searchController.clear();

    if (newCategoryId != null) {
      filters['category'] = newCategoryId;
    }

    // Fetch data with the updated filters
    _fetch();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // ---------- Public API ----------

  /// Called by the Filter screen after user taps "Apply"
  Future<void> applyFilters(Map<String, dynamic> f) async {
    // Normalize expected keys (category, min_price, max_price, duration, distance, rating)
    filters.assignAll(f);
    await _fetch(); // merges current search + filters + sort
  }

  Future<void> clearFilters() async {
    filters.clear();
    await _fetch();
  }

  /// Set sort key from a bottom sheet: distance | rating | reviews | price_asc | price_desc | new
  Future<void> setSort(String? key) async {
    sortKey.value = key;
    await _fetch();
  }

  /// Legacy entry to keep your existing calls working
  Future<void> fetchAllServices({String? search}) async {
    // Update only the search term; then call unified fetch
    if (search != null) {
      // When this entrypoint is used (e.g. from your onChanged debounce)
      // we set the textfield (already set by listener) & fire _fetch
    }
    await _fetch();
  }

  /// If you want to call with raw map (e.g., from nav return)
  Future<void> fetchAllServicesWithFilters(Map<String, dynamic> f) async {
    filters.assignAll(f);
    await _fetch();
  }

  // ---------- Internals ----------

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetch();
    });
  }

  Future<void> _initLocation() async {
    try {
      _position = await _locationService.getCurrentPosition();
      isLocationAvailable.value = _position != null;

      // Optional: fallback to last known if current failed
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

    // Search
    final search = searchController.text.trim();
    if (search.isNotEmpty) q['search'] = search;

    // Filters (only add if present)
    // Category (expects id)
    final cat = filters['category'];
    if (cat != null && '$cat'.isNotEmpty) q['category'] = '$cat';

    // Price range
    final minPrice = filters['min_price'];
    final maxPrice = filters['max_price'];
    if (minPrice != null) q['min_price'] = '${minPrice}';
    if (maxPrice != null) q['max_price'] = '${maxPrice}';

    // Duration buckets: you can pass min/max or a single bucket param; here assume `duration` means max minutes bucket
    final duration = filters['duration']; // e.g., 30 | 60 | 90 | 999
    if (duration != null) q['max_duration'] = '$duration';

    // Distance buckets (in km)
    final distance = filters['distance']; // e.g., 30 | 60 | 90 | 999
    if (distance != null) q['max_distance'] = '$distance';

    // Rating threshold
    final rating = filters['rating']; // e.g., 4.5 | 4.0 | 3.5
    if (rating != null) q['min_rating'] = '$rating';

    // Sort
    final s = sortKey.value;
    if (s != null && s.isNotEmpty) q['sort'] = s;

    // If sorting/filtering by distance, include location if we have it
    final needsLocation = (s == 'distance') || distance != null;
    if (needsLocation && _position != null) {
      q['location'] = '${_position!.latitude},${_position!.longitude}';
    }

    return q;
  }

  Map<String, dynamic> _buildBody() {
    // ✅ always send if we have it
    if (_position == null) return {};
    return {'location': '${_position!.latitude},${_position!.longitude}'};
  }

  String _withTrailingSlash(String url) => url.endsWith('/') ? url : '$url/';

  Future<void> _fetch() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final networkCaller = NetworkCaller();
      final token = AuthService.accessToken;

      final base = _withTrailingSlash(AppUrls.allServices);
      final q = _buildQuery();
      final url = q.isEmpty
          ? base
          : Uri.parse(base).replace(queryParameters: q).toString();

      final response = await networkCaller.getRequestWithBody(
        url,
        token: token,
        body: _buildBody(), // ⬅️ now populated after _initLocation
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        allServices.value = AllServicesModel.fromJson(response.responseData);
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
