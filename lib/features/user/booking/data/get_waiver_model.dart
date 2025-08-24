// To parse this JSON data, do
//
//     final getWaiverModel = getWaiverModelFromJson(jsonString);

import 'dart:convert';

GetWaiverModel getWaiverModelFromJson(String str) => GetWaiverModel.fromJson(json.decode(str));

String getWaiverModelToJson(GetWaiverModel data) => json.encode(data.toJson());

class GetWaiverModel {
  bool? success;
  int? statusCode;
  String? message;
  List<Datum>? data;

  GetWaiverModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetWaiverModel.fromJson(Map<String, dynamic> json) => GetWaiverModel(
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
  String? bookingId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? state;
  int? postalCode;
  String? medicalHistory;
  String? clientSignature;
  DateTime? createdAt;
  DateTime? updatedAt;

  Datum({
    this.id,
    this.userId,
    this.bookingId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.medicalHistory,
    this.clientSignature,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["userId"],
    bookingId: json["bookingId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postalCode"],
    medicalHistory: json["medicalHistory"],
    clientSignature: json["clientSignature"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "bookingId": bookingId,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "address": address,
    "city": city,
    "state": state,
    "postalCode": postalCode,
    "medicalHistory": medicalHistory,
    "clientSignature": clientSignature,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
