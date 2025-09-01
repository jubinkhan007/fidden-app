import 'dart:convert';

List<PromotionModel> promotionModelFromJson(String str) =>
    List<PromotionModel>.from(
      json.decode(str).map((x) => PromotionModel.fromJson(x)),
    );

String promotionModelToJson(List<PromotionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PromotionModel {
  int? id;
  String? title;
  String? subtitle;
  String? amount;
  bool? isActive;
  DateTime? createdAt;

  PromotionModel({
    this.id,
    this.title,
    this.subtitle,
    this.amount,
    this.isActive,
    this.createdAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    amount: json["amount"],
    isActive: json["is_active"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subtitle": subtitle,
    "amount": amount,
    "is_active": isActive,
    "created_at": createdAt?.toIso8601String(),
  };
}
