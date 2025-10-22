import 'dart:convert';

List<GetMyServiceModel> getMyServiceModelFromJson(String str) =>
    List<GetMyServiceModel>.from(
      json.decode(str).map((x) => GetMyServiceModel.fromJson(x)),
    );

String getMyServiceModelToJson(List<GetMyServiceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMyServiceModel {
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

  /// NEW: Age restriction toggle (defaults to false if missing)
  final bool requiresAge18Plus;

  GetMyServiceModel({
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

  /// Make it static so it can be used from the factory
  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  factory GetMyServiceModel.fromJson(Map<String, dynamic> json) =>
      GetMyServiceModel(
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
    // NEW: include in payload
    "requires_age_18_plus": requiresAge18Plus,
  };
}
