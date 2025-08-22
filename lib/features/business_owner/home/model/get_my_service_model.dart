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
  });

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
