import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/utils/constants/api_constants.dart';

class GlobalSearchItem {
  final String type; // "service" | "shop"
  final int id;
  final String? title;
  final String? extraInfo;
  final String? image;
  final double? rating;
  final int? reviews;
  final double? distance;

  GlobalSearchItem({
    required this.type,
    required this.id,
    this.title,
    this.extraInfo,
    this.image,
    this.rating,
    this.reviews,
    this.distance,
  });

  factory GlobalSearchItem.fromJson(Map<String, dynamic> j) => GlobalSearchItem(
    type: (j['type'] ?? '').toString(),
    id: (j['id'] ?? 0) as int,
    title: j['title']?.toString(),
    extraInfo: j['extra_info']?.toString(),
    image: j['image']?.toString(),
    rating: (j['rating'] == null) ? null : (j['rating'] as num).toDouble(),
    reviews: (j['reviews'] ?? 0) as int,
    distance: (j['distance'] == null)
        ? null
        : (j['distance'] as num).toDouble(),
  );
}

class GlobalSearchController extends GetxController {
  GlobalSearchController({String? initialQuery, String? initialLocation}) {
    query.value = initialQuery ?? '';
    _location = initialLocation;
  }

  // inputs/state
  final query = ''.obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorText = RxnString();

  final services = <GlobalSearchItem>[].obs;
  final shops = <GlobalSearchItem>[].obs;

  String? _nextUrl;
  String? _location; // "lat,long"

  // Public API
  Future<void> init() async {
    await _ensureLocation();
    await search(reset: true);
  }

  Future<void> search({bool reset = false}) async {
    if (reset) {
      services.clear();
      shops.clear();
      _nextUrl = null;
      errorText.value = null;
    }

    isLoading.value = true;
    final url = AppUrls.globalSearch(query.value); // add this helper (below)
    final body = {if (_location != null) 'location': _location!};

    final res = await NetworkCaller().postRequest(
      url,
      body: body,
      token: AuthService.accessToken,
    );

    isLoading.value = false;

    if (!res.isSuccess) {
      errorText.value = res.errorMessage;
      return;
    }

    _ingestResponse(res.responseData);
  }

  Future<void> loadMore() async {
    if (_nextUrl == null || isLoadingMore.value) return;

    isLoadingMore.value = true;
    final res = await NetworkCaller().postRequest(
      _nextUrl!, // server gives full URL
      body: {if (_location != null) 'location': _location!},
      token: AuthService.accessToken,
    );
    isLoadingMore.value = false;

    if (!res.isSuccess) return;

    _ingestResponse(res.responseData, append: true);
  }

  // Helpers
  void _ingestResponse(dynamic data, {bool append = false}) {
    if (data is! Map) return;

    _nextUrl = data['next']?.toString();

    final list = (data['results'] as List<dynamic>? ?? [])
        .map((e) => GlobalSearchItem.fromJson(e as Map<String, dynamic>))
        .toList();

    final newServices = list.where((e) => e.type == 'service');
    final newShops = list.where((e) => e.type == 'shop');

    if (!append) {
      services.assignAll(newServices);
      shops.assignAll(newShops);
    } else {
      services.addAll(newServices);
      shops.addAll(newShops);
    }
  }

  Future<void> _ensureLocation() async {
    if (_location != null && _location!.isNotEmpty) return;
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      _location = '${pos.latitude},${pos.longitude}';
    } catch (_) {
      // optional fallback; server can still work without distance
      _location ??= '';
    }
  }
}
