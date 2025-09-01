import 'dart:convert';

TrendingServiceModel trendingServiceModelFromJson(String str) =>
    TrendingServiceModel.fromJson(json.decode(str));

String trendingServiceModelToJson(TrendingServiceModel data) =>
    json.encode(data.toJson());

class TrendingServiceModel {
  String? next;
  dynamic previous;
  List<TrendingService>? results;

  TrendingServiceModel({this.next, this.previous, this.results});

  factory TrendingServiceModel.fromJson(Map<String, dynamic> json) =>
      TrendingServiceModel(
        next: json["next"],
        previous: json["previous"],
        results: json["results"] == null
            ? []
            : List<TrendingService>.from(
                json["results"]!.map((x) => TrendingService.fromJson(x)),
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

class TrendingService {
  int? id;
  String? title;
  String? price;
  String? discountPrice;
  int? shopId;
  String? shopAddress;
  double? avgRating;
  int? reviewCount;
  String? serviceImg;

  TrendingService({
    this.id,
    this.title,
    this.price,
    this.discountPrice,
    this.shopId,
    this.shopAddress,
    this.avgRating,
    this.reviewCount,
    this.serviceImg,
  });

  factory TrendingService.fromJson(Map<String, dynamic> json) =>
      TrendingService(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        discountPrice: json["discount_price"],
        shopId: json["shop_id"],
        shopAddress: json["shop_address"],
        avgRating: json["avg_rating"]?.toDouble(),
        reviewCount: json["review_count"],
        serviceImg: json["service_img"],
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
  };
}
