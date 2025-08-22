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
  });

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
  };
}
