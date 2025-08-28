// lib/features/user/shops/services/data/service_details_model.dart
import 'dart:convert';

ServiceDetailsModel serviceDetailsModelFromJson(String str) =>
    ServiceDetailsModel.fromJson(json.decode(str));

class ServiceDetailsModel {
  final int id;
  final String? serviceImg;
  final String title;
  final String? price; // "50.00"
  final String? discountPrice; // "40.00"
  final String? description;
  final int? duration; // minutes
  final int shopId;
  final String shopName;
  final double? avgRating;
  final int? reviewCount;
  final List<ServiceReview> reviews;

  ServiceDetailsModel({
    required this.id,
    required this.serviceImg,
    required this.title,
    this.price,
    this.discountPrice,
    this.description,
    this.duration,
    required this.shopId,
    required this.shopName,
    this.avgRating,
    this.reviewCount,
    required this.reviews,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      id: json["id"],
      serviceImg: json["service_img"],
      title: json["title"] ?? '',
      price: json["price"],
      discountPrice: json["discount_price"],
      description: json["description"],
      duration: json["duration"],
      shopId: json["shop_id"],
      shopName: json["shop_name"] ?? '',
      avgRating: (json["avg_rating"] as num?)?.toDouble(),
      reviewCount: json["review_count"],
      reviews: (json["reviews"] as List<dynamic>? ?? [])
          .map((e) => ServiceReview.fromJson(e))
          .toList(),
    );
  }
}

class ServiceReview {
  final int id;
  final int shop;
  final int service;
  final int user;
  final String userName;
  final int rating;
  final String? review;
  final String? reviewImg;
  final DateTime createdAt;

  ServiceReview({
    required this.id,
    required this.shop,
    required this.service,
    required this.user,
    required this.userName,
    required this.rating,
    this.review,
    this.reviewImg,
    required this.createdAt,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json["id"],
      shop: json["shop"],
      service: json["service"],
      user: json["user"],
      userName: json["user_name"] ?? 'User',
      rating: json["rating"] ?? 0,
      review: json["review"],
      reviewImg: json["review_img"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
