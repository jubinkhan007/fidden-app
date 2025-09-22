import 'dart:convert';

TrendingServiceModel trendingServiceModelFromJson(String str) =>
    TrendingServiceModel.fromJson(json.decode(str));

String trendingServiceModelToJson(TrendingServiceModel data) =>
    json.encode(data.toJson());

class TrendingServiceModel {
  final String? next;
  final String? previous;
  final List<TrendingServiceItem> results;

  TrendingServiceModel({
    this.next,
    this.previous,
    required this.results,
  });

  factory TrendingServiceModel.fromJson(Map<String, dynamic> j) {
    final list = (j['results'] as List<dynamic>? ?? [])
        .map((e) => TrendingServiceItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
    return TrendingServiceModel(
      next: j['next'] as String?,
      previous: j['previous'] as String?,
      results: list,
    );
  }

  factory TrendingServiceModel.fromList(List<dynamic> arr) {
    final list = arr
        .map((e) => TrendingServiceItem.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
    return TrendingServiceModel(next: null, previous: null, results: list);
  }

  Map<String, dynamic> toJson() => {
        'next': next,
        'previous': previous,
        'results': results.map((e) => e.toJson()).toList(),
      };
}

class TrendingServiceItem {
  final int id;
  final String title;
  final String? price;
  final String? discountPrice;
  final String? shopAddress;
  final double? avgRating;
  final int? reviewCount;
  final String? serviceImg;
  final String? badge;
  final double? distance;
  final bool? isActive;

  TrendingServiceItem({
    required this.id,
    required this.title,
    this.price,
    this.discountPrice,
    this.shopAddress,
    this.avgRating,
    this.reviewCount,
    this.serviceImg,
    this.badge,
    this.distance,
    this.isActive,
  });

  factory TrendingServiceItem.fromJson(Map<String, dynamic> j) =>
      TrendingServiceItem(
        id: j['id'] as int,
        title: (j['title'] ?? '').toString(),
        price: j['price']?.toString(),
        discountPrice: j['discount_price']?.toString(),
        shopAddress: j['shop_address']?.toString(),
        avgRating:
            j['avg_rating'] == null ? null : (j['avg_rating'] as num).toDouble(),
        reviewCount: j['review_count'] as int?,
        serviceImg: j['service_img']?.toString(),
        badge: j['badge']?.toString(),
        distance:
            j['distance'] == null ? null : (j['distance'] as num).toDouble(),
        isActive: j['is_active'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'discount_price': discountPrice,
        'shop_address': shopAddress,
        'avg_rating': avgRating,
        'review_count': reviewCount,
        'service_img': serviceImg,
        'badge': badge,
        'distance': distance,
        'is_active': isActive,
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
