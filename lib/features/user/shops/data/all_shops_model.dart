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
  bool? isFavorite;
  final String? niche; // DEPRECATED: Use niches. Kept for backward compatibility
  final List<String> niches; // NEW: List of all niches offered by shop

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
    this.isFavorite,
    this.niche,
    List<String>? niches,
  }) : niches = niches ?? (niche != null ? [niche] : ['other']);

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Parse niches with backward compatibility
    List<String> parsedNiches;
    if (json['niches'] != null && json['niches'] is List) {
      parsedNiches = List<String>.from(json['niches']);
    } else if (json['niche'] != null) {
      parsedNiches = [json['niche'] as String];
    } else {
      parsedNiches = ['other'];
    }
    
    return Shop(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      location: json['location'],
      avgRating: (json["avg_rating"] as num?)?.toDouble(),
      reviewCount: json["review_count"] as int?,
      distance: (json["distance"] as num?)?.toDouble(),
      shop_img: json['shop_img'],
      badge: json["badge"],
      isFavorite: json["is_favorite"],
      niche: json['niche'], // Deprecated
      niches: parsedNiches, // NEW: Multi-niche support
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'avg_rating': avgRating,
      'review_count': reviewCount,
      'distance': distance,
      'shop_img': shop_img,
      'badge': badge,
      'is_favorite': isFavorite,
      'niche': niche, // Deprecated
      'niches': niches, // NEW: Multi-niche support
    };
  }
  
  /// Helper: Returns primary (first) niche
  String get primaryNiche => niches.isNotEmpty ? niches.first : 'other';
  
  /// Helper: Check if shop offers multiple niches
  bool get isMultiNiche => niches.length > 1;
}
