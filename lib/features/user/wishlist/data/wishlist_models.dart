import 'dart:convert';

// --- Wishlist Shop ---
WishlistShopModel wishlistShopModelFromJson(String str) =>
    WishlistShopModel.fromJson(json.decode(str));

class WishlistShopModel {
  final List<FavoriteShop> shops;
  WishlistShopModel({this.shops = const []});

  factory WishlistShopModel.fromJson(Map<String, dynamic> json) =>
      WishlistShopModel(
        shops: (json["results"] as List<dynamic>? ?? [])
            .map((x) => FavoriteShop.fromJson(x))
            .toList(),
      );
}

//small helper to safely cast ints that might arrive as String/nu
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

class FavoriteShop {
  /// wishlist item id (used for DELETE body)
  final int? id;

  /// actual shop id (used to render hearts / quick toggles)
  final int? shopId;

  final String? name;
  final String? address;
  final String? shopImg;

  FavoriteShop({this.id, this.shopId, this.name, this.address, this.shopImg});

  factory FavoriteShop.fromJson(Map<String, dynamic> json) => FavoriteShop(
    id: _toInt(json["id"]), // wishlist id
    shopId: _toInt(
      json["shop_id"] ??
          json["shop_no"] ??
          (json["shop"] is Map ? json["shop"]["id"] : null),
    ),
    name: json["name"] ?? (json["shop"] is Map ? json["shop"]["name"] : null),
    address:
        json["address"] ??
        (json["shop"] is Map ? json["shop"]["address"] : null),
    shopImg:
        json["shop_img"] ??
        (json["shop"] is Map ? json["shop"]["shop_img"] : null),
  );
}

// --- Wishlist Service ---
WishlistServiceModel wishlistServiceModelFromJson(String str) =>
    WishlistServiceModel.fromJson(json.decode(str));

class WishlistServiceModel {
  final List<FavoriteService> services;
  WishlistServiceModel({this.services = const []});

  factory WishlistServiceModel.fromJson(Map<String, dynamic> json) =>
      WishlistServiceModel(
        services: (json["results"] as List<dynamic>? ?? [])
            .map((x) => FavoriteService.fromJson(x))
            .toList(),
      );
}

class FavoriteService {
  /// wishlist item id
  final int? id;

  /// actual service id (API may use service_no or service_id)
  final int? serviceNo;

  final String? title;
  final String? price;
  final String? serviceImg;
  final String? shopAddress;

  FavoriteService({
    this.id,
    this.serviceNo,
    this.title,
    this.price,
    this.serviceImg,
    this.shopAddress,
  });

  factory FavoriteService.fromJson(Map<String, dynamic> json) =>
      FavoriteService(
        id: json["id"] as int?,
        serviceNo: _toInt(json["service_no"] ?? json["service_id"]),
        title: json["title"] as String?,
        // ensure it's a string even if backend sends number
        price: json["price"]?.toString(),
        serviceImg: json["service_img"] as String?,
        shopAddress: json["shop_address"] as String?,
      );
}

/// m
// int? _toInt(dynamic v) {
//   if (v == null) return null;
//   if (v is int) return v;
//   if (v is num) return v.toInt();
//   if (v is String) return int.tryParse(v);
//   return null;
// }
