// Portfolio Item Model for Tattoo Artist
class PortfolioItem {
  final int id;
  final int shop;
  final String? imageUrl;
  final List<String> tags;
  final String description;
  final DateTime createdAt;

  PortfolioItem({
    required this.id,
    required this.shop,
    this.imageUrl,
    required this.tags,
    required this.description,
    required this.createdAt,
  });

  String get title => description.isNotEmpty ? description : 'Portfolio Item';

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as int,
      shop: json['shop'] as int,
      imageUrl: json['image'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shop,
      'image': imageUrl,
      'tags': tags,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
