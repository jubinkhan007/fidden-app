// lib/features/user/shops/data/shop_details_model.dart

import 'dart:convert';

ShopDetailsModel shopDetailsModelFromJson(String str) =>
    ShopDetailsModel.fromJson(json.decode(str));

class ShopDetailsModel {
  int? id;
  String? name;
  String? address;
  String? location;
  int? capacity;
  String? startAt;
  String? closeAt;
  String? aboutUs;
  String? shopImg;
  List<String>? closeDays;
  int? ownerId;
  double? avgRating;
  int? reviewCount;
  List<Service>? services;
  List<Review>? reviews;

  ShopDetailsModel({
    this.id,
    this.name,
    this.address,
    this.location,
    this.capacity,
    this.startAt,
    this.closeAt,
    this.aboutUs,
    this.shopImg,
    this.closeDays,
    this.ownerId,
    this.avgRating,
    this.reviewCount,
    this.services,
    this.reviews,
  });

  factory ShopDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) => ShopDetailsModel(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    location: json["location"],
    capacity: json["capacity"],
    startAt: json["start_at"],
    closeAt: json["close_at"],
    aboutUs: json["about_us"],
    shopImg: json["shop_img"],
    closeDays: json["close_days"] == null
        ? []
        : List<String>.from(json["close_days"]!.map((x) => x)),
    ownerId: json["owner_id"],
    avgRating: (json["avg_rating"] as num?)?.toDouble(),
    reviewCount: json["review_count"],
    services: json["services"] == null
        ? []
        : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    reviews: json["reviews"] == null
        ? []
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
  );
}

class Review {
  int? id;
  int? serviceId;
  String? serviceName;
  int? user;
  String? userName;
  dynamic profileImage;
  int? rating;
  String? review;
  List<ReviewReply>? reply;

  Review({
    this.id,
    this.serviceId,
    this.serviceName,
    this.user,
    this.userName,
    this.profileImage,
    this.rating,
    this.review,
    this.reply,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    serviceId: json["service_id"],
    serviceName: json["service_name"],
    user: json["user_id"],
    userName: json["user_name"],
    profileImage: json["user_img"],
    rating: json["rating"],
    review: json["review"],
    reply: (json['replies'] as List<dynamic>?)
        ?.map((e) => ReviewReply.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ReviewReply {
  final int id;
  final String? message;
  final DateTime? createdAt;

  ReviewReply({required this.id, this.message, this.createdAt});

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: json['id'] as int,
      message: json['message'] .toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }
}

class Service {
  int? id;
  String? title;
  String? description;
  double? price;
  double? discountPrice;
  int? categoryId;
  String? categoryName;
  String? categoryImg;
  String? serviceImg;

  Service({
    this.id,
    this.title,
    this.description,
    this.price,
    this.discountPrice,
    this.categoryId,
    this.categoryName,
    this.categoryImg,
    this.serviceImg,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    price: (json["price"] as num?)?.toDouble(),
    discountPrice: (json["discount_price"] as num?)?.toDouble(),
    categoryId: json["category_id"],
    categoryName: json["category_name"],
    categoryImg: json["category_img"],
    serviceImg: json["service_img"],
  );
}
