// lib/features/user/map/map_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/features/user/shops/controller/all_shops_controller.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreenController extends GetxController {
  final AllShopsController _shopsController = Get.find<AllShopsController>();
  final LocationService _locationService = LocationService();

  // Map + UI state
  final isLoading = true.obs;
  final markers = <Marker>{}.obs;
  final shops = <Shop>[].obs;
  final selectedShop = Rxn<Shop>();
  final suggestions = <Shop>[].obs;
  final showSearchThisArea = false.obs;
  final hasLocationPermission = true.obs;

  final searchController = TextEditingController();
  Timer? _searchDebounce;

  // Map bits
  final mapControllerCompleter = Completer<GoogleMapController>();
  CameraPosition camera = const CameraPosition(
    target: LatLng(23.7808875, 90.2792371), // safe default (Dhaka)
    zoom: 14,
  );
  LatLng _lastFetchCenter = const LatLng(23.7808875, 90.2792371);
  bool _userDragged = false;

  // Filters (lightweight)
  final topRated = false.obs; // rating >= 4.5
  final nearest = true.obs; // sort by distance

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    try {
      isLoading.value = true;

      // location permission + center
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        camera = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 14,
        );
        _lastFetchCenter = camera.target;
      } else {
        hasLocationPermission.value = false; // banner will show on UI
      }

      await fetchNearby(); // initial load
    } finally {
      isLoading.value = false;
    }
  }

  // Debounced text search
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      await fetchNearby(query: searchController.text.trim());
      _buildSuggestions();
    });
  }

  // Fetch from your API via AllShopsController (it already handles location in body)
  Future<void> fetchNearby({String? query}) async {
    isLoading.value = true;
    try {
      // 🔧 If you want “search this area”: pass map center to your AllShopsController.
      // Add an optional `LatLng? at` param in fetchAllShops and use `at` instead of device GPS (snippet below).
      await _shopsController.fetchAllShops(
        query: (query != null && query.isNotEmpty) ? query : null,
        // at: camera.target, // <- enable if you add support (see patch at bottom)
      );

      final list = _shopsController.allShops.value.shops;

      // optional filters
      List<Shop> filtered = List.of(list);
      if (topRated.value) {
        filtered = filtered.where((s) => (s.avgRating ?? 0) >= 4.5).toList();
      }
      if (nearest.value) {
        filtered.sort(
          (a, b) => ((a.distance ?? 1e9).compareTo(b.distance ?? 1e9)),
        );
      }

      shops.assignAll(filtered);
      _renderMarkers();
    } finally {
      isLoading.value = false;
    }
  }

  void _renderMarkers() {
    final set = <Marker>{};
    for (final s in shops) {
      final loc = (s.location ?? '').split(',');
      if (loc.length == 2) {
        final lat = double.tryParse(loc[0]);
        final lng = double.tryParse(loc[1]);
        if (lat != null && lng != null) {
          set.add(
            Marker(
              markerId: MarkerId('shop_${s.id}'),
              position: LatLng(lat, lng),
              onTap: () => selectedShop.value = s,
            ),
          );
        }
      }
    }
    markers.value = set;
  }

  // Suggestions under the search bar (simple: show top 5 by name match)
  void _buildSuggestions() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      suggestions.clear();
      return;
    }
    final res = shops
        .where((s) => (s.name ?? '').toLowerCase().contains(q))
        .take(5)
        .toList();
    suggestions.assignAll(res);
  }

  void clearSelection() => selectedShop.value = null;

  // Map callbacks
  void onMapCreated(GoogleMapController c) {
    if (!mapControllerCompleter.isCompleted) {
      mapControllerCompleter.complete(c);
    }
  }

  void onCameraMove(CameraPosition pos) {
    camera = pos;
    _userDragged = true;
  }

  void onCameraIdle() {
    if (_userDragged) {
      _userDragged = false;
      // show “Search this area” pill if moved a meaningful distance
      final movedMeters = _haversineMeters(_lastFetchCenter, camera.target);
      showSearchThisArea.value = movedMeters > 120; // tweak threshold
    }
  }

  Future<void> searchThisArea() async {
    _lastFetchCenter = camera.target;
    showSearchThisArea.value = false;
    await fetchNearby(query: searchController.text.trim());
  }

  Future<void> recenter() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) return;
    final c = await mapControllerCompleter.future;
    final t = LatLng(pos.latitude, pos.longitude);
    camera = CameraPosition(target: t, zoom: 14);
    await c.animateCamera(CameraUpdate.newCameraPosition(camera));
    await searchThisArea();
  }

  // Tap a suggestion → center + select
  Future<void> goToShop(Shop s) async {
    final loc = (s.location ?? '').split(',');
    if (loc.length != 2) return;
    final lat = double.tryParse(loc[0]);
    final lng = double.tryParse(loc[1]);
    if (lat == null || lng == null) return;

    final c = await mapControllerCompleter.future;
    await c.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 16),
      ),
    );
    selectedShop.value = s;
  }

  // Helpers
  double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _deg(b.latitude - a.latitude);
    final dLon = _deg(b.longitude - a.longitude);
    final lat1 = _deg(a.latitude);
    final lat2 = _deg(b.latitude);
    final h =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLon / 2) * sin(dLon / 2)) * cos(lat1) * cos(lat2);
    return 2 * R * asin(sqrt(h));
  }

  double _deg(double d) => d * 3.1415926535897932 / 180.0;
}
