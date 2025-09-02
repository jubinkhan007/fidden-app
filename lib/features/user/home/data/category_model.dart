// lib/features/user/home/data/category_model.dart
import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) =>
    List<CategoryModel>.from(
      json.decode(str).map((x) => CategoryModel.fromJson(x)),
    );

String categoryModelToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  int? id;
  String? name;
  String? scImg; // <-- NEW

  CategoryModel({this.id, this.name, this.scImg});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    name: json["name"],
    scImg: json["sc_img"], // <-- NEW
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "sc_img": scImg, // <-- NEW
  };
}
