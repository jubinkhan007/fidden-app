/// MUA (Makeup Artist) Dashboard models

// ==========================================
// ENUMS
// ==========================================

enum LookType {
  natural('natural', 'Natural'),
  glam('glam', 'Glam'),
  bridal('bridal', 'Bridal'),
  editorial('editorial', 'Editorial'),
  sfx('sfx', 'Special Effects');

  final String value;
  final String display;
  const LookType(this.value, this.display);

  static LookType? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return LookType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LookType.natural,
    );
  }
}

enum SkinTone {
  fair('fair', 'Fair'),
  light('light', 'Light'),
  medium('medium', 'Medium'),
  olive('olive', 'Olive'),
  tan('tan', 'Tan'),
  deep('deep', 'Deep');

  final String value;
  final String display;
  const SkinTone(this.value, this.display);

  static SkinTone? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return SkinTone.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SkinTone.medium,
    );
  }
}

enum SkinType {
  normal('normal', 'Normal'),
  oily('oily', 'Oily'),
  dry('dry', 'Dry'),
  combination('combination', 'Combination'),
  sensitive('sensitive', 'Sensitive');

  final String value;
  final String display;
  const SkinType(this.value, this.display);

  static SkinType? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return SkinType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SkinType.normal,
    );
  }
}

enum Undertone {
  warm('warm', 'Warm'),
  cool('cool', 'Cool'),
  neutral('neutral', 'Neutral');

  final String value;
  final String display;
  const Undertone(this.value, this.display);

  static Undertone? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return Undertone.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Undertone.neutral,
    );
  }
}

enum ProductCategory {
  foundation('foundation', 'Foundation'),
  concealer('concealer', 'Concealer'),
  powder('powder', 'Powder'),
  blush('blush', 'Blush'),
  bronzer('bronzer', 'Bronzer'),
  highlighter('highlighter', 'Highlighter'),
  eyeshadow('eyeshadow', 'Eyeshadow'),
  eyeliner('eyeliner', 'Eyeliner'),
  mascara('mascara', 'Mascara'),
  brow('brow', 'Brow Products'),
  lipstick('lipstick', 'Lipstick'),
  lipGloss('lip_gloss', 'Lip Gloss'),
  primer('primer', 'Primer'),
  settingSpray('setting_spray', 'Setting Spray'),
  brush('brush', 'Brush'),
  sponge('sponge', 'Sponge/Applicator'),
  skincare('skincare', 'Skincare'),
  other('other', 'Other');

  final String value;
  final String display;
  const ProductCategory(this.value, this.display);

  static ProductCategory fromString(String? value) {
    if (value == null) return ProductCategory.other;
    return ProductCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductCategory.other,
    );
  }
}

// ==========================================
// MODELS
// ==========================================

class MUADashboard {
  final int todayAppointmentsCount;
  final double todayRevenue;
  final int clientProfilesCount;
  final int productKitCount;
  final int faceChartsCount;
  final int mobileServicesCount;

  MUADashboard({
    required this.todayAppointmentsCount,
    required this.todayRevenue,
    required this.clientProfilesCount,
    required this.productKitCount,
    required this.faceChartsCount,
    required this.mobileServicesCount,
  });

  factory MUADashboard.fromJson(Map<String, dynamic> json) {
    return MUADashboard(
      todayAppointmentsCount: json['today_appointments_count'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      clientProfilesCount: json['client_profiles_count'] ?? 0,
      productKitCount: json['product_kit_count'] ?? 0,
      faceChartsCount: json['face_charts_count'] ?? 0,
      mobileServicesCount: json['mobile_services_count'] ?? 0,
    );
  }
}

class FaceChart {
  final int id;
  final int shopId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? caption;
  final String? description;
  final int? clientId;
  final String? clientName;
  final String? lookType;
  final String? categoryTag;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;

  FaceChart({
    required this.id,
    required this.shopId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.caption,
    this.description,
    this.clientId,
    this.clientName,
    this.lookType,
    this.categoryTag,
    this.tags = const [],
    this.isPublic = true,
    required this.createdAt,
  });

  factory FaceChart.fromJson(Map<String, dynamic> json) {
    return FaceChart(
      id: json['id'] ?? 0,
      shopId: json['shop'] ?? 0,
      imageUrl: json['image'] ?? '',
      thumbnailUrl: json['thumbnail'],
      caption: json['caption'],
      description: json['description'],
      clientId: json['client'],
      clientName: json['client_name'],
      lookType: json['look_type'],
      categoryTag: json['category_tag'],
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['is_public'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  LookType? get lookTypeEnum => LookType.fromString(lookType);
}

class ClientBeautyProfile {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final String? clientEmail;
  final String? skinTone;
  final String? skinToneDisplay;
  final String? skinType;
  final String? skinTypeDisplay;
  final String? undertone;
  final String? undertoneDisplay;
  final String? allergies;
  final String? preferences;
  final String? foundationShade;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientBeautyProfile({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.clientEmail,
    this.skinTone,
    this.skinToneDisplay,
    this.skinType,
    this.skinTypeDisplay,
    this.undertone,
    this.undertoneDisplay,
    this.allergies,
    this.preferences,
    this.foundationShade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientBeautyProfile.fromJson(Map<String, dynamic> json) {
    return ClientBeautyProfile(
      id: json['id'] ?? 0,
      shopId: json['shop'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      skinTone: json['skin_tone'],
      skinToneDisplay: json['skin_tone_display'],
      skinType: json['skin_type'],
      skinTypeDisplay: json['skin_type_display'],
      undertone: json['undertone'],
      undertoneDisplay: json['undertone_display'],
      allergies: json['allergies'],
      preferences: json['preferences'],
      foundationShade: json['foundation_shade'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'skin_tone': skinTone,
    'skin_type': skinType,
    'undertone': undertone,
    'allergies': allergies,
    'preferences': preferences,
    'foundation_shade': foundationShade,
  };
}

class ProductKitItem {
  final int id;
  final int shopId;
  final String name;
  final String? brand;
  final String category;
  final String? categoryDisplay;
  final int quantity;
  final bool isPacked;
  final String? notes;
  final DateTime createdAt;

  ProductKitItem({
    required this.id,
    required this.shopId,
    required this.name,
    this.brand,
    required this.category,
    this.categoryDisplay,
    this.quantity = 1,
    this.isPacked = false,
    this.notes,
    required this.createdAt,
  });

  factory ProductKitItem.fromJson(Map<String, dynamic> json) {
    return ProductKitItem(
      id: json['id'] ?? 0,
      shopId: json['shop'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      category: json['category'] ?? 'other',
      categoryDisplay: json['category_display'],
      quantity: json['quantity'] ?? 1,
      isPacked: json['is_packed'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': brand,
    'category': category,
    'quantity': quantity,
    'is_packed': isPacked,
    'notes': notes,
  };

  ProductKitItem copyWith({bool? isPacked, int? quantity}) {
    return ProductKitItem(
      id: id,
      shopId: shopId,
      name: name,
      brand: brand,
      category: category,
      categoryDisplay: categoryDisplay,
      quantity: quantity ?? this.quantity,
      isPacked: isPacked ?? this.isPacked,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

/// Response wrapper for face charts
class FaceChartsResponse {
  final int count;
  final List<FaceChart> items;

  FaceChartsResponse({required this.count, required this.items});

  factory FaceChartsResponse.fromJson(Map<String, dynamic> json) {
    return FaceChartsResponse(
      count: json['count'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => FaceChart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
