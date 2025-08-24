// To parse this JSON data, do
//
//     final getMyForm = getMyFormFromJson(jsonString);

import 'dart:convert';

GetMyForm getMyFormFromJson(String str) => GetMyForm.fromJson(json.decode(str));

String getMyFormToJson(GetMyForm data) => json.encode(data.toJson());

class GetMyForm {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  GetMyForm({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetMyForm.fromJson(Map<String, dynamic> json) => GetMyForm(
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
  String? userId;
  String? businessId;
  List<Agreement>? agreement;
  List<String>? medicalHistory;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.userId,
    this.businessId,
    this.agreement,
    this.medicalHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["userId"],
    businessId: json["businessId"],
    agreement: json["agreement"] == null ? [] : List<Agreement>.from(json["agreement"]!.map((x) => Agreement.fromJson(x))),
    medicalHistory: json["medicalHistory"] == null ? [] : List<String>.from(json["medicalHistory"]!.map((x) => x)),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "businessId": businessId,
    "agreement": agreement == null ? [] : List<dynamic>.from(agreement!.map((x) => x.toJson())),
    "medicalHistory": medicalHistory == null ? [] : List<dynamic>.from(medicalHistory!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Agreement {
  String? dropdown;
  String? textField1;

  Agreement({
    this.dropdown,
    this.textField1,
  });

  factory Agreement.fromJson(Map<String, dynamic> json) => Agreement(
    dropdown: json["dropdown"],
    textField1: json["textField1"],
  );

  Map<String, dynamic> toJson() => {
    "dropdown": dropdown,
    "textField1": textField1,
  };
}
