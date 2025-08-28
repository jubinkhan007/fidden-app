// To parse this JSON data, do
//
//     final getNearestBarbarSingleDetails = getNearestBarbarSingleDetailsFromJson(jsonString);

import 'dart:convert';

AllBaBarSearchModel getNearestBarbarSingleDetailsFromJson(String str) => AllBaBarSearchModel.fromJson(json.decode(str));

String getNearestBarbarSingleDetailsToJson(AllBaBarSearchModel data) => json.encode(data.toJson());

class AllBaBarSearchModel {
  bool? success;
  int? statusCode;
  String? message;
  AllBarBarSearchData? data;

  AllBaBarSearchModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory AllBaBarSearchModel.fromJson(Map<String, dynamic> json) => AllBaBarSearchModel(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? null : AllBarBarSearchData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class AllBarBarSearchData {
  String? id;
  String? userId;
  String? businessName;
  String? businessAddress;
  String? details;
  String? startDay;
  String? image;
  String? endDay;
  String? startTime;
  String? endTime;
  double? latitude;
  double? longitude;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Review>? review;
  List<Service>? service;
  double? averageReview;

  AllBarBarSearchData({
    this.id,
    this.userId,
    this.businessName,
    this.businessAddress,
    this.details,
    this.startDay,
    this.image,
    this.endDay,
    this.startTime,
    this.endTime,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.review,
    this.service,
    this.averageReview,
  });

  factory AllBarBarSearchData.fromJson(Map<String, dynamic> json) => AllBarBarSearchData(
    id: json["id"],
    userId: json["userId"],
    businessName: json["businessName"],
    businessAddress: json["businessAddress"],
    details: json["details"],
    startDay: json["startDay"],
    image: json["image"],
    endDay: json["endDay"],
    startTime: json["startTime"],
    endTime: json["endTime"],
    latitude: (json["latitude"] != null) ? json["latitude"].toDouble() : null,
    longitude: (json["longitude"] != null) ? json["longitude"].toDouble() : null,
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    review: json["Review"] == null ? [] : List<Review>.from(json["Review"].map((x) => Review.fromJson(x))),
    service: json["Service"] == null ? [] : List<Service>.from(json["Service"].map((x) => Service.fromJson(x))),
    averageReview: (json["averageReview"] != null) ? (json["averageReview"] is int ? (json["averageReview"] as int).toDouble() : json["averageReview"].toDouble()) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "businessName": businessName,
    "businessAddress": businessAddress,
    "details": details,
    "startDay": startDay,
    "image": image,
    "endDay": endDay,
    "startTime": startTime,
    "endTime": endTime,
    "latitude": latitude,
    "longitude": longitude,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "Review": review == null ? [] : List<dynamic>.from(review!.map((x) => x.toJson())),
    "Service": service == null ? [] : List<dynamic>.from(service!.map((x) => x.toJson())),
    "averageReview": averageReview,
  };
}

class Review {
  UserDetails? userDetails;
  double? rating;
  String? review;

  Review({
    this.userDetails,
    this.rating,
    this.review,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    userDetails: json["userDetails"] == null ? null : UserDetails.fromJson(json["userDetails"]),
    rating: (json["rating"] != null) ? (json["rating"] is int ? (json["rating"] as int).toDouble() : json["rating"].toDouble()) : null,
    review: json["review"],
  );

  Map<String, dynamic> toJson() => {
    "userDetails": userDetails?.toJson(),
    "rating": rating,
    "review": review,
  };
}

class UserDetails {
  String? name;
  String? image;

  UserDetails({
    this.name,
    this.image,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    name: json["name"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "image": image,
  };
}

class Service {
  String? id;
  String? businessId;
  String? name;
  String? description;
  double? price;
  String? image;
  double? discountPrice;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Service({
    this.id,
    this.businessId,
    this.name,
    this.description,
    this.price,
    this.image,
    this.discountPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json["id"],
    businessId: json["businessId"],
    name: json["name"],
    description: json["description"],
    price: (json["price"] != null) ? (json["price"] is int ? (json["price"] as int).toDouble() : json["price"].toDouble()) : null,
    image: json["image"],
    discountPrice: (json["discountPrice"] != null) ? (json["discountPrice"] is int ? (json["discountPrice"] as int).toDouble() : json["discountPrice"].toDouble()) : null,
    status: json["status"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "businessId": businessId,
    "name": name,
    "description": description,
    "price": price,
    "image": image,
    "discountPrice": discountPrice,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
