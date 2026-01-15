// lib/features/user/shops/data/provider_model.dart

/// Represents a service provider (barber, stylist, etc.) at a shop
class Provider {
  final int id;
  final String name;
  final String? profileImage;

  Provider({required this.id, required this.name, this.profileImage});

  factory Provider.fromJson(Map<String, dynamic> json) => Provider(
    id: json['id'] as int,
    name: json['name'] as String? ?? 'Unknown',
    profileImage: json['profile_image'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'profile_image': profileImage,
  };

  /// Creates the "Any Available" placeholder provider
  static Provider anyAvailable() =>
      Provider(id: 0, name: 'Any Available', profileImage: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Provider && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
