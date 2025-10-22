import 'dart:convert';

GetSingleServiceModel getSingleServiceModelFromJson(String str) =>
    GetSingleServiceModel.fromJson(json.decode(str));

String getSingleServiceModelToJson(GetSingleServiceModel data) =>
    json.encode(data.toJson());

class GetSingleServiceModel {
  int? id;
  String? title;
  String? price;
  String? discountPrice;
  String? description;
  dynamic serviceImg;
  int? category;
  int? duration;
  int? capacity;
  bool? isActive;

  /// NEW
  final bool requiresAge18Plus;

  GetSingleServiceModel({
    this.id,
    this.title,
    this.price,
    this.discountPrice,
    this.description,
    this.serviceImg,
    this.category,
    this.duration,
    this.capacity,
    this.isActive,
    this.requiresAge18Plus = false,
  });

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  factory GetSingleServiceModel.fromJson(Map<String, dynamic> json) =>
      GetSingleServiceModel(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        discountPrice: json["discount_price"],
        description: json["description"],
        serviceImg: json["service_img"],
        category: json["category"],
        duration: json["duration"],
        capacity: json["capacity"],
        isActive: json["is_active"],
        requiresAge18Plus: _asBool(json['requires_age_18_plus']),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "price": price,
    "discount_price": discountPrice,
    "description": description,
    "service_img": serviceImg,
    "category": category,
    "duration": duration,
    "capacity": capacity,
    "is_active": isActive,
    // NEW
    "requires_age_18_plus": requiresAge18Plus,
  };
}
