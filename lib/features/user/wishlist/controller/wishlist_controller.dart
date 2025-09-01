import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

import '../data/wishlist_models.dart';

class WishlistController extends GetxController {
  // Loading flags
  final isLoadingShops = true.obs;
  final isLoadingServices = true.obs;

  // Lists for UI
  final favoriteShops = <FavoriteShop>[].obs;
  final favoriteServices = <FavoriteService>[].obs;

  // Fast heart-check sets (contain REAL entity ids)
  final _favoriteShopIds = <int>{}.obs;
  final _favoriteServiceIds = <int>{}.obs;

  // Maps: entityId -> wishlistId (needed for DELETE)
  final _wishlistIdByShopId = <int, int>{}.obs;
  final _wishlistIdByServiceId = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteShops();
    fetchFavoriteServices();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  int? _extractShopId(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _toInt(
        json['shop_id'] ??
            json['shop_no'] ??
            (json['shop'] is Map ? (json['shop'] as Map)['id'] : null),
      );
    }
    return null;
  }

  int? _extractServiceId(dynamic json) {
    if (json is Map<String, dynamic>) {
      return _toInt(
        json['service_no'] ??
            json['service_id'] ??
            (json['service'] is Map ? (json['service'] as Map)['id'] : null),
      );
    }
    return null;
  }

  bool isShopFavorite(int shopId) => _favoriteShopIds.contains(shopId);
  bool isServiceFavorite(int serviceId) =>
      _favoriteServiceIds.contains(serviceId);

  // ---------------------------------------------------------------------------
  // Fetch
  // ---------------------------------------------------------------------------
  Future<void> fetchFavoriteShops() async {
    try {
      isLoadingShops.value = true;
      final res = await NetworkCaller().getRequest(
        AppUrls.shopWishlist,
        token: AuthService.accessToken,
      );

      if (res.isSuccess && res.responseData is List) {
        final raw = res.responseData as List;

        // Build UI list
        final list = raw.map((j) => FavoriteShop.fromJson(j)).toList();
        favoriteShops.assignAll(list);

        // Build maps/sets from raw so we can find both real shopId and wishlistId
        _favoriteShopIds
          ..clear()
          ..addAll(raw.map(_extractShopId).whereType<int>());

        _wishlistIdByShopId
          ..clear()
          ..addEntries(
            raw.map((j) {
              final shopId = _extractShopId(j);
              final wishlistId = _toInt((j as Map<String, dynamic>)['id']);
              if (shopId != null && wishlistId != null) {
                return MapEntry(shopId, wishlistId);
              }
              return null;
            }).whereType<MapEntry<int, int>>(),
          );
      }
    } finally {
      isLoadingShops.value = false;
    }
  }

  Future<void> fetchFavoriteServices() async {
    try {
      isLoadingServices.value = true;
      final res = await NetworkCaller().getRequest(
        AppUrls.serviceWishlist,
        token: AuthService.accessToken,
      );

      if (res.isSuccess && res.responseData is List) {
        final raw = res.responseData as List;

        // Build UI list
        final list = raw.map((j) => FavoriteService.fromJson(j)).toList();
        favoriteServices.assignAll(list);

        // Build maps/sets from raw so we can find both real serviceId and wishlistId
        _favoriteServiceIds
          ..clear()
          ..addAll(raw.map(_extractServiceId).whereType<int>());

        _wishlistIdByServiceId
          ..clear()
          ..addEntries(
            raw.map((j) {
              final serviceId = _extractServiceId(j);
              final wishlistId = _toInt((j as Map<String, dynamic>)['id']);
              if (serviceId != null && wishlistId != null) {
                return MapEntry(serviceId, wishlistId);
              }
              return null;
            }).whereType<MapEntry<int, int>>(),
          );
      }
    } finally {
      isLoadingServices.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Shops: toggle/add/remove
  // ---------------------------------------------------------------------------
  /// Use this from product/shop cards where you only know the real **shopId**
  Future<void> toggleShopFavoriteByShopId(int shopId) async {
    if (isShopFavorite(shopId)) {
      await removeShopFromWishlistByShopId(shopId);
    } else {
      await addShopToWishlist(shopId);
    }
  }

  Future<void> addShopToWishlist(int shopId) async {
    final res = await NetworkCaller().postRequest(
      AppUrls.shopWishlist,
      body: {'shop_id': shopId},
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Shop added to wishlist!');
      _favoriteShopIds.add(shopId);

      // If API returns the created wishlist item's id, capture it
      final data = res.responseData;
      final createdWishlistId = (data is Map && data['id'] is int)
          ? data['id'] as int
          : null;
      if (createdWishlistId != null) {
        _wishlistIdByShopId[shopId] = createdWishlistId;
      } else {
        await fetchFavoriteShops();
      }
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  /// Remove by real shopId (most common from cards)
  Future<void> removeShopFromWishlistByShopId(int shopId) async {
    int? wishlistId = _wishlistIdByShopId[shopId];
    if (wishlistId == null) {
      await fetchFavoriteShops();
      wishlistId = _wishlistIdByShopId[shopId];
      if (wishlistId == null) {
        AppSnackBar.showError('Wishlist item not found for this shop.');
        return;
      }
    }

    final res = await NetworkCaller().deleteRequest(
      AppUrls.shopWishlist,
      body: {'id': wishlistId}, // <-- wishlist id here
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Shop removed from wishlist!');
      _favoriteShopIds.remove(shopId);
      _wishlistIdByShopId.remove(shopId);
      favoriteShops.removeWhere((e) => e.id == wishlistId);
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  /// Convenience: remove when you only have the wishlist item id (e.g., from wishlist screen)
  Future<void> removeShopFromWishlistByWishlistId(int wishlistId) async {
    final res = await NetworkCaller().deleteRequest(
      AppUrls.shopWishlist,
      body: {'id': wishlistId},
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Shop removed from wishlist!');

      // find the mapped shopId to update sets
      final entry = _wishlistIdByShopId.entries.firstWhereOrNull(
        (e) => e.value == wishlistId,
      );
      if (entry != null) {
        _favoriteShopIds.remove(entry.key);
        _wishlistIdByShopId.remove(entry.key);
      }
      favoriteShops.removeWhere((e) => e.id == wishlistId);
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // Services: toggle/add/remove
  // ---------------------------------------------------------------------------
  /// Use this from service cards where you only know the real **serviceId**
  Future<void> toggleServiceFavoriteByServiceId(int serviceId) async {
    if (isServiceFavorite(serviceId)) {
      await removeServiceFromWishlistByServiceId(serviceId);
    } else {
      await addServiceToWishlist(serviceId);
    }
  }

  Future<void> addServiceToWishlist(int serviceId) async {
    // API expects { "id": <serviceId> } for create
    final res = await NetworkCaller().postRequest(
      AppUrls.serviceWishlist,
      body: {'service_no': serviceId},
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Service added to wishlist!');
      _favoriteServiceIds.add(serviceId);

      // If API returns created wishlist item id, store it
      final data = res.responseData;
      final createdWishlistId = (data is Map && data['id'] is int)
          ? data['id'] as int
          : null;
      if (createdWishlistId != null) {
        _wishlistIdByServiceId[serviceId] = createdWishlistId;
      } else {
        await fetchFavoriteServices();
      }
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  /// Remove by real serviceId (common from cards)
  Future<void> removeServiceFromWishlistByServiceId(int serviceId) async {
    int? wishlistId = _wishlistIdByServiceId[serviceId];
    if (wishlistId == null) {
      await fetchFavoriteServices();
      wishlistId = _wishlistIdByServiceId[serviceId];
      if (wishlistId == null) {
        AppSnackBar.showError('Wishlist item not found for this service.');
        return;
      }
    }

    final res = await NetworkCaller().deleteRequest(
      AppUrls.serviceWishlist,
      body: {'id': wishlistId}, // <-- wishlist id here
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Service removed from wishlist!');
      _favoriteServiceIds.remove(serviceId);
      _wishlistIdByServiceId.remove(serviceId);
      favoriteServices.removeWhere((e) => e.id == wishlistId);
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  /// Convenience: remove when you only have the wishlist item id (e.g., from wishlist screen)
  Future<void> removeServiceFromWishlistByWishlistId(int wishlistId) async {
    final res = await NetworkCaller().deleteRequest(
      AppUrls.serviceWishlist,
      body: {'id': wishlistId},
      token: AuthService.accessToken,
    );

    if (res.isSuccess) {
      AppSnackBar.showSuccess('Service removed from wishlist!');

      // find mapped serviceId to update sets
      final entry = _wishlistIdByServiceId.entries.firstWhereOrNull(
        (e) => e.value == wishlistId,
      );
      if (entry != null) {
        _favoriteServiceIds.remove(entry.key);
        _wishlistIdByServiceId.remove(entry.key);
      }
      favoriteServices.removeWhere((e) => e.id == wishlistId);
    } else {
      AppSnackBar.showError(res.errorMessage);
    }
  }

  // ---------------------------------------------------------------------------
  // Back-compat helpers (optional)
  // ---------------------------------------------------------------------------
  /// If you call this from the wishlist screen with a FavoriteShop (whose `id` is wishlistId),
  /// it will remove it.
  void toggleShopFavorite(FavoriteShop shop) {
    if (shop.id != null) {
      removeShopFromWishlistByWishlistId(shop.id!);
    }
  }

  /// If you call this from the wishlist screen with a FavoriteService (whose `id` is wishlistId),
  /// it will remove it.
  void toggleServiceFavorite(FavoriteService service) {
    if (service.id != null) {
      removeServiceFromWishlistByWishlistId(service.id!);
    }
  }
}
