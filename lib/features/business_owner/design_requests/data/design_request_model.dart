/// Image attached to a design request
class DesignRequestImage {
  final int id;
  final String imageUrl;
  final DateTime createdAt;

  DesignRequestImage({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory DesignRequestImage.fromJson(Map<String, dynamic> json) {
    return DesignRequestImage(
      id: json['id'] as int,
      imageUrl: json['image'] as String,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DesignRequest {
  final int id;
  final int shopId;
  final int userId;
  final String userName;
  final String userEmail;
  final int? bookingId;
  final String description;
  final String placement;
  final String sizeApprox;
  final String status;
  final String? serviceNiche; // 'tattoo_artist', 'nail_tech', etc.
  final List<DesignRequestImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  DesignRequest({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.bookingId,
    required this.description,
    required this.placement,
    required this.sizeApprox,
    required this.status,
    this.serviceNiche,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters for backward compatibility
  String get customerName => userName;
  String get customerEmail => userEmail;
  String get designDescription => description;

  /// Get list of image URLs for easy access
  List<String> get designImages => images.map((img) => img.imageUrl).toList();

  /// Get first image URL or null
  String? get firstImageUrl => images.isNotEmpty ? images.first.imageUrl : null;

  factory DesignRequest.fromJson(Map<String, dynamic> json) {
    // Parse images array
    final imagesList = <DesignRequestImage>[];
    if (json['images'] is List) {
      for (final imgJson in json['images'] as List) {
        if (imgJson is Map<String, dynamic>) {
          imagesList.add(DesignRequestImage.fromJson(imgJson));
        }
      }
    }

    return DesignRequest(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      userId: json['user'] as int,
      userName: json['user_name'] as String? ?? 'Unknown',
      userEmail: json['user_email'] as String? ?? '',
      bookingId: json['booking'] as int?,
      description: json['description'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      sizeApprox: json['size_approx'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      serviceNiche: json['service_niche'] as String?,
      images: imagesList,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'user': userId,
      'user_name': userName,
      'user_email': userEmail,
      'booking': bookingId,
      'description': description,
      'placement': placement,
      'size_approx': sizeApprox,
      'status': status,
      'images': images.map((img) => img.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isDiscussing => status == 'discussing';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
