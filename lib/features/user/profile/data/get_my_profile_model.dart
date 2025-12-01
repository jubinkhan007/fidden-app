// To parse this JSON data, do
//
//     final getMyProfileModel = getMyProfileModelFromJson(jsonString);

import 'dart:convert';

GetMyProfileModel getMyProfileModelFromJson(String str) =>
    GetMyProfileModel.fromJson(json.decode(str));

String getMyProfileModelToJson(GetMyProfileModel data) =>
    json.encode(data.toJson());

class GetMyProfileModel {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  GetMyProfileModel({this.success, this.statusCode, this.message, this.data});

  factory GetMyProfileModel.fromJson(Map<String, dynamic> json) =>
      GetMyProfileModel(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "statusCode": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? id;
  String? name;
  String? email;
  dynamic image;
  String? mobile_number;
  String? role;
  String? shopNiche; // DEPRECATED: Business owner's shop niche (single)
  List<String>? shopNiches; // NEW: Business owner's shop niches (array)
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.name,
    this.email,
    this.mobile_number,
    this.image,
    this.role,
    this.shopNiche,
    this.shopNiches,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    // Parse niches with backward compatibility
    // Backend may send 'niches' or 'shop_niches'
    List<String>? parsedNiches;
    if (json['niches'] != null && json['niches'] is List) {
      parsedNiches = List<String>.from(json['niches']);
    } else if (json['shop_niches'] != null && json['shop_niches'] is List) {
      parsedNiches = List<String>.from(json['shop_niches']);
    } else if (json['shop_niche'] != null) {
      parsedNiches = [json['shop_niche'] as String];
    }
    
    return Data(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      mobile_number: json["mobile_number"],
      image: json["profile_image"],
      role: json["role"],
      shopNiche: json["shop_niche"], // Deprecated
      shopNiches: parsedNiches, // NEW: Multi-niche support
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
      updatedAt: json["updatedAt"] == null
          ? null
          : DateTime.parse(json["updatedAt"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "mobile_number": mobile_number,
    "profile_image": image,
    "role": role,
    "shop_niche": shopNiche, // Deprecated
    "shop_niches": shopNiches, // NEW
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
