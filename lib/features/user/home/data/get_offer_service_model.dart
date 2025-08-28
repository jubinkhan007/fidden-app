// To parse this JSON data, do
//
//     final getOfferServiceModel = getOfferServiceModelFromJson(jsonString);

import 'dart:convert';

GetOfferServiceModel getOfferServiceModelFromJson(String str) => GetOfferServiceModel.fromJson(json.decode(str));

String getOfferServiceModelToJson(GetOfferServiceModel data) => json.encode(data.toJson());

class GetOfferServiceModel {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  GetOfferServiceModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetOfferServiceModel.fromJson(Map<String, dynamic> json) => GetOfferServiceModel(
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
  String? businessId;
  String? name;
  String? description;
  double? price;
  String? image;
  double? discountPrice;
  bool? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
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

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    businessId: json["businessId"],
    name: json["name"],
    description: json["description"],
    price: json["price"]?.toDouble(),
    image: json["image"],
    discountPrice: json["discountPrice"]?.toDouble(),
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
