class ShopModel {
  final String name;
  final String location;
  final double rating;
  final String imageUrl;

  ShopModel({
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] != null)
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      imageUrl: json['imageUrl'] ?? '', // Change key as per API response
    );
  }
}
