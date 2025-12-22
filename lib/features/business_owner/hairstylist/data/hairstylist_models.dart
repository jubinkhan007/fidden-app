// ==========================================
// HAIRSTYLIST/LOCTICIAN DATA MODELS 💇‍♀️
// ==========================================

// ==========================================
// ENUMS
// ==========================================

enum HairType {
  type1a('1a', '1A - Fine Straight'),
  type1b('1b', '1B - Medium Straight'),
  type1c('1c', '1C - Coarse Straight'),
  type2a('2a', '2A - Fine Wavy'),
  type2b('2b', '2B - Medium Wavy'),
  type2c('2c', '2C - Coarse Wavy'),
  type3a('3a', '3A - Loose Curls'),
  type3b('3b', '3B - Springy Curls'),
  type3c('3c', '3C - Tight Curls'),
  type4a('4a', '4A - Soft Coils'),
  type4b('4b', '4B - Z-Pattern Coils'),
  type4c('4c', '4C - Tight Coils');

  final String value;
  final String display;
  const HairType(this.value, this.display);

  static HairType? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return HairType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HairType.type3a,
    );
  }
}

enum HairTexture {
  fine('fine', 'Fine'),
  medium('medium', 'Medium'),
  coarse('coarse', 'Coarse');

  final String value;
  final String display;
  const HairTexture(this.value, this.display);

  static HairTexture? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return HairTexture.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HairTexture.medium,
    );
  }
}

enum HairPorosity {
  low('low', 'Low'),
  normal('normal', 'Normal'),
  high('high', 'High');

  final String value;
  final String display;
  const HairPorosity(this.value, this.display);

  static HairPorosity? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    return HairPorosity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HairPorosity.normal,
    );
  }
}

enum HairProductCategory {
  shampoo('shampoo', 'Shampoo'),
  conditioner('conditioner', 'Conditioner'),
  treatment('treatment', 'Treatment'),
  oil('oil', 'Oil'),
  styling('styling', 'Styling Product'),
  protectant('protectant', 'Heat Protectant'),
  leaveIn('leave_in', 'Leave-In'),
  mask('mask', 'Hair Mask'),
  color('color', 'Color Product'),
  tool('tool', 'Tool/Accessory'),
  other('other', 'Other');

  final String value;
  final String display;
  const HairProductCategory(this.value, this.display);

  static HairProductCategory fromString(String? value) {
    return HairProductCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HairProductCategory.other,
    );
  }
}

// ==========================================
// MODELS
// ==========================================

class HairstylistDashboard {
  final int todayAppointmentsCount;
  final int weekAppointmentsCount;
  final double todayRevenue;
  final int clientProfilesCount;
  final int productRecommendationsCount;
  final int consultationServicesCount;

  HairstylistDashboard({
    required this.todayAppointmentsCount,
    required this.weekAppointmentsCount,
    required this.todayRevenue,
    required this.clientProfilesCount,
    required this.productRecommendationsCount,
    required this.consultationServicesCount,
  });

  factory HairstylistDashboard.fromJson(Map<String, dynamic> json) {
    return HairstylistDashboard(
      todayAppointmentsCount: json['today_appointments_count'] ?? 0,
      weekAppointmentsCount: json['week_appointments_count'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      clientProfilesCount: json['client_profiles_count'] ?? 0,
      productRecommendationsCount: json['product_recommendations_count'] ?? 0,
      consultationServicesCount: json['consultation_services_count'] ?? 0,
    );
  }
}

class ClientHairProfile {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final String? clientEmail;
  final String? hairType;
  final String? hairTypeDisplay;
  final String? hairTexture;
  final String? hairTextureDisplay;
  final String? hairPorosity;
  final String? hairPorosityDisplay;
  final String? naturalColor;
  final String? currentColor;
  final String? colorHistory;
  final String? chemicalHistory;
  final String? scalpCondition;
  final String? allergies;
  final String? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientHairProfile({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.clientEmail,
    this.hairType,
    this.hairTypeDisplay,
    this.hairTexture,
    this.hairTextureDisplay,
    this.hairPorosity,
    this.hairPorosityDisplay,
    this.naturalColor,
    this.currentColor,
    this.colorHistory,
    this.chemicalHistory,
    this.scalpCondition,
    this.allergies,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientHairProfile.fromJson(Map<String, dynamic> json) {
    return ClientHairProfile(
      id: json['id'],
      shopId: json['shop'],
      clientId: json['client'],
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      hairType: json['hair_type'],
      hairTypeDisplay: json['hair_type_display'],
      hairTexture: json['hair_texture'],
      hairTextureDisplay: json['hair_texture_display'],
      hairPorosity: json['hair_porosity'],
      hairPorosityDisplay: json['hair_porosity_display'],
      naturalColor: json['natural_color'],
      currentColor: json['current_color'],
      colorHistory: json['color_history'],
      chemicalHistory: json['chemical_history'],
      scalpCondition: json['scalp_condition'],
      allergies: json['allergies'],
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'hair_type': hairType,
    'hair_texture': hairTexture,
    'hair_porosity': hairPorosity,
    'natural_color': naturalColor,
    'current_color': currentColor,
    'color_history': colorHistory,
    'chemical_history': chemicalHistory,
    'scalp_condition': scalpCondition,
    'allergies': allergies,
    'preferences': preferences,
  };
}

class ProductRecommendation {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final int? bookingId;
  final String productName;
  final String? brand;
  final String category;
  final String? categoryDisplay;
  final String? notes;
  final String? purchaseLink;
  final DateTime createdAt;

  ProductRecommendation({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.bookingId,
    required this.productName,
    this.brand,
    required this.category,
    this.categoryDisplay,
    this.notes,
    this.purchaseLink,
    required this.createdAt,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      id: json['id'],
      shopId: json['shop'],
      clientId: json['client'],
      clientName: json['client_name'],
      bookingId: json['booking'],
      productName: json['product_name'] ?? '',
      brand: json['brand'],
      category: json['category'] ?? 'other',
      categoryDisplay: json['category_display'],
      notes: json['notes'],
      purchaseLink: json['purchase_link'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'booking': bookingId,
    'product_name': productName,
    'brand': brand,
    'category': category,
    'notes': notes,
    'purchase_link': purchaseLink,
  };
}

class PrepNoteItem {
  final int id;
  final String userName;
  final String serviceTitle;
  final DateTime slotTime;
  final String prepNotes;
  final String status;

  PrepNoteItem({
    required this.id,
    required this.userName,
    required this.serviceTitle,
    required this.slotTime,
    required this.prepNotes,
    required this.status,
  });

  factory PrepNoteItem.fromJson(Map<String, dynamic> json) {
    return PrepNoteItem(
      id: json['id'],
      userName: json['user_name'] ?? '',
      serviceTitle: json['service_title'] ?? '',
      slotTime: DateTime.parse(json['slot_time']),
      prepNotes: json['prep_notes'] ?? '',
      status: json['status'] ?? 'active',
    );
  }
}

class WeeklyScheduleResponse {
  final String startDate;
  final String endDate;
  final int totalAppointments;
  final Map<String, List<PrepNoteItem>> schedule;

  WeeklyScheduleResponse({
    required this.startDate,
    required this.endDate,
    required this.totalAppointments,
    required this.schedule,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final scheduleMap = <String, List<PrepNoteItem>>{};
    if (json['schedule'] != null) {
      (json['schedule'] as Map<String, dynamic>).forEach((date, appointments) {
        scheduleMap[date] = (appointments as List)
            .map((e) => PrepNoteItem.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
    return WeeklyScheduleResponse(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalAppointments: json['total_appointments'] ?? 0,
      schedule: scheduleMap,
    );
  }
}
