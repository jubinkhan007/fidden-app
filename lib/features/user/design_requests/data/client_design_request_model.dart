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
}

/// Design request model for client-side usage
class ClientDesignRequest {
  final int id;
  final int shopId;
  final String? shopName;
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

  ClientDesignRequest({
    required this.id,
    required this.shopId,
    this.shopName,
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

  factory ClientDesignRequest.fromJson(Map<String, dynamic> json) {
    // Parse images array
    final imagesList = <DesignRequestImage>[];
    if (json['images'] is List) {
      for (final imgJson in json['images'] as List) {
        if (imgJson is Map<String, dynamic>) {
          imagesList.add(DesignRequestImage.fromJson(imgJson));
        }
      }
    }

    return ClientDesignRequest(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      shopName: json['shop_name'] as String?,
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

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';

  // Can edit only if pending
  bool get canEdit => isPending;
  bool get canDelete => isPending;

  /// Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}

/// Placement options for tattoo
class TattooPlacement {
  static const List<String> options = [
    'Forearm',
    'Upper Arm',
    'Full Sleeve',
    'Shoulder',
    'Chest',
    'Back',
    'Full Back',
    'Ribs',
    'Leg',
    'Thigh',
    'Calf',
    'Ankle',
    'Wrist',
    'Hand',
    'Neck',
    'Behind Ear',
    'Other',
  ];
}

/// Size options for tattoo
class TattooSize {
  static const List<String> options = [
    'Tiny (1-2 inches)',
    'Small (2-4 inches)',
    'Medium (4-6 inches)',
    'Large (6-12 inches)',
    'Extra Large (12+ inches)',
    'Full Sleeve',
    'Half Sleeve',
    'Full Back',
    'Custom Size',
  ];
}

/// Placement options for nail designs
class NailPlacement {
  static const List<String> options = [
    'All Nails',
    'Accent Nail Only',
    'Thumb Only',
    'Index Finger Only',
    'Ring Finger Only',
    'French Tips',
    'Full Set',
    'Pedicure - Toes',
    'Custom Selection',
  ];
}

/// Size/Style options for nail designs
class NailSize {
  static const List<String> options = [
    'Short Length',
    'Medium Length',
    'Long Length',
    'Extra Long',
    'Coffin Shape',
    'Stiletto Shape',
    'Square Shape',
    'Almond Shape',
    'Oval Shape',
    'Round Shape',
    'Custom Style',
  ];
}
