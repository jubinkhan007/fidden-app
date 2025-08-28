// To parse this JSON data, do
//
//     final getAllRecommendedBusinessProfileModel = getAllRecommendedBusinessProfileModelFromJson(jsonString);

import 'dart:convert';

GetAllRecommendedBusinessProfileModel getAllRecommendedBusinessProfileModelFromJson(String str) => GetAllRecommendedBusinessProfileModel.fromJson(json.decode(str));

String getAllRecommendedBusinessProfileModelToJson(GetAllRecommendedBusinessProfileModel data) => json.encode(data.toJson());

class GetAllRecommendedBusinessProfileModel {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  GetAllRecommendedBusinessProfileModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetAllRecommendedBusinessProfileModel.fromJson(Map<String, dynamic> json) => GetAllRecommendedBusinessProfileModel(
    success: json["success"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
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
  double? averageReview;

  Datum({
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
    this.averageReview,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    averageReview: json["averageReview"]?.toDouble(),
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
    "averageReview": averageReview,
  };
}
