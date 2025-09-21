// lib/features/user/home/data/category_model.dart
import 'dart:convert';

class CategoryModel {
  int? id;
  String? name;
  String? scImg;

  CategoryModel({this.id, this.name, this.scImg});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"] is int ? json["id"] : int.tryParse("${json["id"]}"),
        name: json["name"]?.toString(),
        scImg: json["sc_img"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "sc_img": scImg,
      };
}

/// ✅ Parse categories from any of these payloads:
/// - JSON string of a list
/// - JSON string of a map { results | data | categories | items: [...] }
/// - Already-decoded List or Map
List<CategoryModel> categoryListFromAny(dynamic raw) {
  dynamic data = raw;

  if (data is String) {
    try { data = json.decode(data); } catch (_) { return const []; }
  }

  if (data is Map<String, dynamic>) {
    data = data['results'] ??
           data['data'] ??
           data['categories'] ??
           data['items'] ??
           const [];
  }

  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  return const [];
}
