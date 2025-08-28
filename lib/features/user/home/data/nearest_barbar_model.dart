// To parse this JSON data, do
//
//     final getNearestBarbar = getNearestBarbarFromJson(jsonString);

import 'dart:convert';

GetNearestBarbar getNearestBarbarFromJson(String str) => GetNearestBarbar.fromJson(json.decode(str));

String getNearestBarbarToJson(GetNearestBarbar data) => json.encode(data.toJson());

class GetNearestBarbar {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  GetNearestBarbar({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetNearestBarbar.fromJson(Map<String, dynamic> json) => GetNearestBarbar(
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
  String? businessName;
  String? businessAddress;
  String? image;
  double? latitude;
  double? longitude;
  double? averageReview;

  Datum({
    this.id,
    this.businessName,
    this.businessAddress,
    this.image,
    this.latitude,
    this.longitude,
    this.averageReview,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    businessName: json["businessName"],
    businessAddress: json["businessAddress"],
    image: json["image"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    averageReview: json["averageReview"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "businessName": businessName,
    "businessAddress": businessAddress,
    "image": image,
    "latitude": latitude,
    "longitude": longitude,
    "averageReview": averageReview,
  };
}
