import 'dart:async';
import 'dart:math';
import 'package:fidden/core/services/location_service.dart';
import 'package:fidden/features/user/shops/controller/all_shops_controller.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class MapScreenController extends GetxController {
  final AllShopsController _shopsController = Get.find<AllShopsController>();
  final LocationService _locationService = LocationService();

  // State
  final isLoading = true.obs;
  final markers = <Marker>{}.obs;
  final shops = <Shop>[].obs;
  final selectedShop = Rxn<Shop>();
  final suggestions = <Shop>[].obs;
  final showSearchThisArea = false.obs;
  final hasLocationPermission = false.obs; // start false

  final searchController = TextEditingController();
  Timer? _searchDebounce;

  // Map
  final mapControllerCompleter = Completer<GoogleMapController>();
  CameraPosition camera = const CameraPosition(
    target: LatLng(23.7808875, 90.2792371),
    zoom: 14,
  );
  LatLng _lastFetchCenter = const LatLng(23.7808875, 90.2792371);
  bool _userDragged = false;

  // Filters
  final topRated = false.obs;
  final nearest = true.obs;

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

      final p = await Geolocator.checkPermission();
      hasLocationPermission.value =
          p == LocationPermission.always || p == LocationPermission.whileInUse;

      if (hasLocationPermission.value) {
        final pos = await _safePosition();
        if (pos != null) {
          camera = CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 14,
          );
          _lastFetchCenter = camera.target;
        }
      }

      await fetchNearby();
    } finally {
      isLoading.value = false;
    }
  }

  // Called by banner + FAB
  Future<void> requestPermissionAndCenter() async {
    // If permanently denied, push to app settings
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever) {
      // open platform settings once; return early
      await ph.openAppSettings();
      return;
    }

    final granted =
        p == LocationPermission.always || p == LocationPermission.whileInUse;
    hasLocationPermission.value = granted;

    if (!granted) return;

    final pos = await _safePosition();
    if (pos == null) {
      Get.snackbar('Location', 'Couldn’t get your current position.');
      return;
    }

    final c = await mapControllerCompleter.future;
    final t = LatLng(pos.latitude, pos.longitude);
    camera = CameraPosition(target: t, zoom: 14);
    await c.animateCamera(CameraUpdate.newCameraPosition(camera));
    await searchThisArea();
  }

  // Debounced text search
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      await fetchNearby(query: searchController.text.trim());
      _buildSuggestions();
    });
  }

  Future<void> fetchNearby({String? query}) async {
    isLoading.value = true;
    try {
      await _shopsController.fetchAllShops(
        query: (query != null && query.isNotEmpty) ? query : null,
      );

      final list = _shopsController.allShops.value.shops;
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
          set.add(Marker(
            markerId: MarkerId('shop_${s.id}'),
            position: LatLng(lat, lng),
            onTap: () => selectedShop.value = s,
          ));
        }
      }
    }
    markers.value = set;
  }

  void _buildSuggestions() {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      suggestions.clear();
      return;
    }
    suggestions.assignAll(
      shops.where((s) => (s.name ?? '').toLowerCase().contains(q)).take(5),
    );
  }

  void clearSelection() => selectedShop.value = null;

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
      final movedMeters = _haversineMeters(_lastFetchCenter, camera.target);
      showSearchThisArea.value = movedMeters > 120;
    }
  }

  Future<void> searchThisArea() async {
    _lastFetchCenter = camera.target;
    showSearchThisArea.value = false;
    await fetchNearby(query: searchController.text.trim());
  }

  Future<Position?> _safePosition() async {
    try {
      return await Geolocator
          .getCurrentPosition()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

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

  double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _deg(b.latitude - a.latitude);
    final dLon = _deg(b.longitude - a.longitude);
    final lat1 = _deg(a.latitude);
    final lat2 = _deg(b.latitude);
    final h = (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLon / 2) * sin(dLon / 2)) * cos(lat1) * cos(lat2);
    return 2 * R * asin(sqrt(h));
  }

  double _deg(double d) => d * 3.1415926535897932 / 180.0;
}
