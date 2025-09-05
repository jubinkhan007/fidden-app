import 'dart:convert';

ShopDetailsModel shopDetailsModelFromJson(String str) =>
    ShopDetailsModel.fromJson(json.decode(str));

String shopDetailsModelToJson(ShopDetailsModel data) =>
    json.encode(data.toJson());

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
    avgRating: json["avg_rating"]?.toDouble(),
    reviewCount: json["review_count"],
    services: json["services"] == null
        ? []
        : List<Service>.from(json["services"]!.map((x) => Service.fromJson(x))),
    reviews: json["reviews"] == null
        ? []
        : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "location": location,
    "capacity": capacity,
    "start_at": startAt,
    "close_at": closeAt,
    "about_us": aboutUs,
    "shop_img": shopImg,
    "close_days": closeDays == null
        ? []
        : List<dynamic>.from(closeDays!.map((x) => x)),
    "owner_id": ownerId,
    "avg_rating": avgRating,
    "review_count": reviewCount,
    "services": services == null
        ? []
        : List<dynamic>.from(services!.map((x) => x.toJson())),
    "reviews": reviews == null
        ? []
        : List<dynamic>.from(reviews!.map((x) => x.toJson())),
  };
}

class Review {
  int? id;
  int? service;
  int? user;
  String? userName;
  String? profileImage;
  int? rating;
  String? review;
  String? reviewImg;
  DateTime? createdAt;
  List<ReviewReply>? reply; // list of owner replies

  Review({
    this.id,
    this.service,
    this.user,
    this.userName,
    this.profileImage,
    this.rating,
    this.review,
    this.reviewImg,
    this.createdAt,
    this.reply,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // handle both: service / service_id, user / user_id, profile_image / user_img, reply / replies
    final repliesField = json['replies'] ?? json['reply'];

    return Review(
      id: json['id'],
      service: json['service'] ?? json['service_id'],
      user: json['user'] ?? json['user_id'],
      userName: json['user_name'],
      profileImage: json['profile_image'] ?? json['user_img'],
      rating: (json['rating'] as num?)?.toInt(),
      review: json['review'],
      reviewImg: json['review_img'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      reply: repliesField == null
          ? []
          : List<ReviewReply>.from(
              (repliesField as List).whereType<Map<String, dynamic>>().map(
                ReviewReply.fromJson,
              ),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service,
    'user': user,
    'user_name': userName,
    'profile_image': profileImage,
    'rating': rating,
    'review': review,
    'review_img': reviewImg,
    'created_at': createdAt?.toIso8601String(),
    'reply': reply == null
        ? []
        : List<dynamic>.from(reply!.map((x) => x.toJson())),
  };
}

class Service {
  int? id;
  String? title;
  String? description;
  double? price;
  double? discountPrice;
  String? serviceImg;

  Service({
    this.id,
    this.title,
    this.description,
    this.price,
    this.discountPrice,
    this.serviceImg,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    discountPrice: json["discount_price"],
    serviceImg: json["service_img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "price": price,
    "discount_price": discountPrice,
    "service_img": serviceImg,
  };
}

class ReviewReply {
  final int? id;
  final String? message;
  final DateTime? createdAt;

  ReviewReply({this.id, this.message, this.createdAt});

  factory ReviewReply.fromJson(Map<String, dynamic> json) => ReviewReply(
    id: json['id'],
    message: json['message'],
    createdAt: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'created_at': createdAt?.toIso8601String(),
  };
}
