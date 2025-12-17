/// Style Request models for nail tech dashboard

/// Nail style types
enum NailStyleType {
  acrylic,
  gel,
  dip,
  natural,
  pedicure,
  nailArt;

  static NailStyleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'acrylic':
        return NailStyleType.acrylic;
      case 'gel':
        return NailStyleType.gel;
      case 'dip':
        return NailStyleType.dip;
      case 'natural':
        return NailStyleType.natural;
      case 'pedicure':
        return NailStyleType.pedicure;
      case 'nail_art':
        return NailStyleType.nailArt;
      default:
        return NailStyleType.gel;
    }
  }

  String toApiString() {
    switch (this) {
      case NailStyleType.acrylic:
        return 'acrylic';
      case NailStyleType.gel:
        return 'gel';
      case NailStyleType.dip:
        return 'dip';
      case NailStyleType.natural:
        return 'natural';
      case NailStyleType.pedicure:
        return 'pedicure';
      case NailStyleType.nailArt:
        return 'nail_art';
    }
  }

  String get displayName {
    switch (this) {
      case NailStyleType.acrylic:
        return 'Acrylic';
      case NailStyleType.gel:
        return 'Gel';
      case NailStyleType.dip:
        return 'Dip';
      case NailStyleType.natural:
        return 'Natural';
      case NailStyleType.pedicure:
        return 'Pedicure';
      case NailStyleType.nailArt:
        return 'Nail Art';
    }
  }
}

/// Nail shapes
enum NailShape {
  coffin,
  almond,
  stiletto,
  square,
  round,
  oval,
  squoval;

  static NailShape fromString(String value) {
    switch (value.toLowerCase()) {
      case 'coffin':
        return NailShape.coffin;
      case 'almond':
        return NailShape.almond;
      case 'stiletto':
        return NailShape.stiletto;
      case 'square':
        return NailShape.square;
      case 'round':
        return NailShape.round;
      case 'oval':
        return NailShape.oval;
      case 'squoval':
        return NailShape.squoval;
      default:
        return NailShape.round;
    }
  }

  String toApiString() => name;

  String get displayName {
    switch (this) {
      case NailShape.coffin:
        return 'Coffin';
      case NailShape.almond:
        return 'Almond';
      case NailShape.stiletto:
        return 'Stiletto';
      case NailShape.square:
        return 'Square';
      case NailShape.round:
        return 'Round';
      case NailShape.oval:
        return 'Oval';
      case NailShape.squoval:
        return 'Squoval';
    }
  }
}

/// Style request status
enum StyleRequestStatus {
  pending,
  approved,
  declined,
  completed;

  static StyleRequestStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return StyleRequestStatus.pending;
      case 'approved':
        return StyleRequestStatus.approved;
      case 'declined':
        return StyleRequestStatus.declined;
      case 'completed':
        return StyleRequestStatus.completed;
      default:
        return StyleRequestStatus.pending;
    }
  }

  String toApiString() => name;

  String get displayName {
    switch (this) {
      case StyleRequestStatus.pending:
        return 'Pending';
      case StyleRequestStatus.approved:
        return 'Approved';
      case StyleRequestStatus.declined:
        return 'Declined';
      case StyleRequestStatus.completed:
        return 'Completed';
    }
  }
}

/// Image attached to a style request
class StyleRequestImage {
  final int id;
  final String imageUrl;
  final DateTime uploadedAt;

  StyleRequestImage({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory StyleRequestImage.fromJson(Map<String, dynamic> json) {
    return StyleRequestImage(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image'] as String? ?? '',
      uploadedAt: DateTime.tryParse(json['uploaded_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Style request from a client
class StyleRequest {
  final int id;
  final int shopId;
  final int userId;
  final String? userName;
  final String? userEmail;
  final int? bookingId;
  final String title;
  final String description;
  final NailStyleType? nailStyleType;
  final String? nailStyleTypeDisplay;
  final NailShape? nailShape;
  final String? nailShapeDisplay;
  final String? colorPreference;
  final StyleRequestStatus status;
  final List<StyleRequestImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  StyleRequest({
    required this.id,
    required this.shopId,
    required this.userId,
    this.userName,
    this.userEmail,
    this.bookingId,
    required this.title,
    required this.description,
    this.nailStyleType,
    this.nailStyleTypeDisplay,
    this.nailShape,
    this.nailShapeDisplay,
    this.colorPreference,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StyleRequest.fromJson(Map<String, dynamic> json) {
    return StyleRequest(
      id: json['id'] as int? ?? 0,
      shopId: json['shop'] as int? ?? 0,
      userId: json['user'] as int? ?? 0,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      bookingId: json['booking'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      nailStyleType: json['nail_style_type'] != null 
          ? NailStyleType.fromString(json['nail_style_type'] as String) 
          : null,
      nailStyleTypeDisplay: json['nail_style_type_display'] as String?,
      nailShape: json['nail_shape'] != null 
          ? NailShape.fromString(json['nail_shape'] as String) 
          : null,
      nailShapeDisplay: json['nail_shape_display'] as String?,
      colorPreference: json['color_preference'] as String?,
      status: StyleRequestStatus.fromString(json['status'] as String? ?? 'pending'),
      images: (json['images'] as List? ?? [])
          .map((e) => StyleRequestImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Get first image URL for preview
  String? get previewImageUrl => images.isNotEmpty ? images.first.imageUrl : null;
}
