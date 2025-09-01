// features/user/shops/data/all_shops_model.dart
import 'dart:convert';

AllShopsModel allShopsModelFromJson(String str) =>
    AllShopsModel.fromJson(json.decode(str));

String allShopsModelToJson(AllShopsModel data) => json.encode(data.toJson());

class AllShopsModel {
  List<Shop> shops; // Changed from List<Shop>?
  String? next;
  String? previous;

  AllShopsModel({this.shops = const [], this.next, this.previous});

  factory AllShopsModel.fromJson(Map<String, dynamic> json) {
    // This is the key part: look for "results"
    final rawList = json['results'] as List<dynamic>?;

    return AllShopsModel(
      shops: rawList == null
          ? []
          : rawList
                .map((x) => Shop.fromJson(x as Map<String, dynamic>))
                .toList(),
      next: json['next'],
      previous: json['previous'],
    );
  }

  Map<String, dynamic> toJson() => {
    // Use "results" for consistency with the API
    "results": shops.map((x) => x.toJson()).toList(),
    "next": next,
    "previous": previous,
  };
}

class Shop {
  int? id;
  String? name;
  String? address;
  String? location;
  double? avgRating;
  int? reviewCount;
  double? distance;
  String? shop_img;
  String? badge;
  bool? isFavorite; // Add this line

  Shop({
    this.id,
    this.name,
    this.address,
    this.location,
    this.avgRating,
    this.reviewCount,
    this.distance,
    this.shop_img,
    this.badge,
    this.isFavorite, // Add this line
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    location: json["location"],
    avgRating: (json["avg_rating"] as num?)?.toDouble(),
    reviewCount: json["review_count"] as int?,
    distance: (json["distance"] as num?)?.toDouble(),
    shop_img: json["shop_img"],
    badge: json["badge"],
    isFavorite: json["is_favorite"], // Add this line
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "location": location,
    "avg_rating": avgRating,
    "review_count": reviewCount,
    "distance": distance,
    "shop_img": shop_img,
    "badge": badge,
    "is_favorite": isFavorite, // Add this line
  };
}
