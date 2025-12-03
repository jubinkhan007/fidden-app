class PortfolioItem {
  final int id;
  final int shopId;
  final String imageUrl;
  final List<String> tags;
  final String description;
  final DateTime createdAt;

  PortfolioItem({
    required this.id,
    required this.shopId,
    required this.imageUrl,
    required this.tags,
    required this.description,
    required this.createdAt,
  });

  String get title => description;

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      imageUrl: json['image'] as String,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : [],
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'image': imageUrl,
      'tags': tags,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
