/// Gallery Item Model for Service Provider Client Gallery
/// Used for both business owner management and client-facing gallery display
/// Unified model supports all niches: tattoo, nail, makeup, barber, hair

class GalleryItemModel {
  final int id;
  final int shop;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? caption;
  final String? description;
  final int? serviceId;
  final String? serviceName;
  final String? categoryTag;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  
  // MUA-specific fields (also used by other niches if needed)
  final int? clientId;
  final String? clientName;
  final String? lookType;  // MUA: natural, glam, bridal, editorial, sfx

  GalleryItemModel({
    required this.id,
    required this.shop,
    this.imageUrl,
    this.thumbnailUrl,
    this.caption,
    this.description,
    this.serviceId,
    this.serviceName,
    this.categoryTag,
    this.tags = const [],
    this.isPublic = true,
    required this.createdAt,
    this.clientId,
    this.clientName,
    this.lookType,
  });

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) {
    return GalleryItemModel(
      id: json['id'] as int,
      shop: (json['shop'] as int?) ?? 0,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnail'] as String?,
      caption: json['caption'] as String?,
      description: json['description'] as String?,
      serviceId: json['service'] as int?,
      serviceName: json['service_name'] as String?,
      categoryTag: json['category_tag'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: (json['is_public'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      clientId: json['client'] as int?,
      clientName: json['client_name'] as String?,
      lookType: json['look_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shop,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'caption': caption,
      'description': description,
      'service': serviceId,
      'service_name': serviceName,
      'category_tag': categoryTag,
      'tags': tags,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      if (clientId != null) 'client': clientId,
      if (clientName != null) 'client_name': clientName,
      if (lookType != null) 'look_type': lookType,
    };
  }
  
  /// Get display text for look type
  String? get lookTypeDisplay {
    if (lookType == null) return null;
    switch (lookType) {
      case 'natural': return 'Natural';
      case 'glam': return 'Glam';
      case 'bridal': return 'Bridal';
      case 'editorial': return 'Editorial';
      case 'sfx': return 'SFX';
      default: return lookType;
    }
  }
}


/// Gallery preview item for shop details (lighter model)
class GalleryPreviewItem {
  final int id;
  final String? thumbnailUrl;
  final String? imageUrl;
  final String? caption;

  GalleryPreviewItem({
    required this.id,
    this.thumbnailUrl,
    this.imageUrl,
    this.caption,
  });

  factory GalleryPreviewItem.fromJson(Map<String, dynamic> json) {
    return GalleryPreviewItem(
      id: json['id'] as int,
      thumbnailUrl: json['thumbnail_url'] as String?,
      imageUrl: json['image_url'] as String?,
      caption: json['caption'] as String?,
    );
  }
}

/// Paginated gallery response for public shop gallery
class PaginatedGallery {
  final int count;
  final int numPages;
  final int currentPage;
  final List<GalleryItemModel> results;

  PaginatedGallery({
    required this.count,
    required this.numPages,
    required this.currentPage,
    required this.results,
  });

  factory PaginatedGallery.fromJson(Map<String, dynamic> json) {
    return PaginatedGallery(
      count: (json['count'] as int?) ?? 0,
      numPages: (json['num_pages'] as int?) ?? 1,
      currentPage: (json['current_page'] as int?) ?? 1,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => GalleryItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
