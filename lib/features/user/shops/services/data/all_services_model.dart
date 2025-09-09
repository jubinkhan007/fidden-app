import 'dart:convert';
import 'dart:math';

AllServicesModel allServicesModelFromJson(String str) =>
    AllServicesModel.fromJson(json.decode(str));

String allServicesModelToJson(AllServicesModel data) =>
    json.encode(data.toJson());

class AllServicesModel {
  String? next;
  String? previous;
  List<ServiceResult>? results;

  AllServicesModel({this.next, this.previous, this.results});

  factory AllServicesModel.fromJson(Map<String, dynamic> json) =>
      AllServicesModel(
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null
            ? []
            : List<ServiceResult>.from(
                json["results"]!.map((x) => ServiceResult.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "next": next,
    "previous": previous,
    "results": results == null
        ? []
        : List<dynamic>.from(results!.map((x) => x.toJson())),
  };
}

class ServiceResult {
  int? id;
  String? title;
  String? price;
  String? discountPrice;
  int? shopId;
  String? shopAddress;
  double? avgRating;
  int? reviewCount;
  String? serviceImg;
  String? badge;
  bool? isFavorite;
  double? distance;

  ServiceResult({
    this.id,
    this.title,
    this.price,
    this.discountPrice,
    this.shopId,
    this.shopAddress,
    this.avgRating,
    this.reviewCount,
    this.serviceImg,
    this.badge,
    this.isFavorite,
    this.distance,
  });

  factory ServiceResult.fromJson(Map<String, dynamic> json) => ServiceResult(
    id: json["id"],
    title: json["title"],
    price: json["price"],
    discountPrice: json["discount_price"],
    shopId: json["shop_id"],
    shopAddress: json["shop_address"],
    avgRating: json["avg_rating"]?.toDouble(),
    reviewCount: json["review_count"],
    serviceImg: json["service_img"],
    badge: json["badge"],
    isFavorite: json["is_favorite"],
    distance: (json["distance"] is String)
        ? double.tryParse(json["distance"])
        : (json["distance"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "discount_price": discountPrice,
    "shop_id": shopId,
    "shop_address": shopAddress,
    "avg_rating": avgRating,
    "review_count": reviewCount,
    "service_img": serviceImg,
    "badge": badge,
    "is_favorite": isFavorite,
    "distance": distance,
  };

  String get randomPlaceholderImage {
    final placeholders = [
      'https://images.unsplash.com/photo-1582095133179-bfd08e2fc6b3?q=80&w=1200&auto=format&fit=crop',
      'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    ];
    return placeholders[Random().nextInt(placeholders.length)];
  }
}
