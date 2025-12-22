// ==========================================
// ESTHETICIAN DATA MODELS 🧖
// ==========================================

// ==========================================
// ENUMS
// ==========================================

enum SkinType {
  normal('normal', 'Normal'),
  dry('dry', 'Dry'),
  oily('oily', 'Oily'),
  combination('combination', 'Combination'),
  sensitive('sensitive', 'Sensitive');

  final String value;
  final String display;
  const SkinType(this.value, this.display);

  static SkinType fromString(String? value) {
    return SkinType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SkinType.normal,
    );
  }
}

enum PressurePreference {
  light('light', 'Light'),
  medium('medium', 'Medium'),
  firm('firm', 'Firm'),
  deep('deep', 'Deep');

  final String value;
  final String display;
  const PressurePreference(this.value, this.display);

  static PressurePreference fromString(String? value) {
    return PressurePreference.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PressurePreference.medium,
    );
  }
}

enum TreatmentType {
  facial('facial', 'Facial'),
  massage('massage', 'Massage'),
  body('body', 'Body Treatment'),
  wax('wax', 'Waxing'),
  lash('lash', 'Lash/Brow'),
  peel('peel', 'Chemical Peel'),
  microderm('microderm', 'Microdermabrasion'),
  wrap('wrap', 'Body Wrap'),
  scrub('scrub', 'Body Scrub'),
  other('other', 'Other');

  final String value;
  final String display;
  const TreatmentType(this.value, this.display);

  static TreatmentType fromString(String? value) {
    return TreatmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TreatmentType.other,
    );
  }
}

enum RetailCategory {
  cleanser('cleanser', 'Cleanser'),
  toner('toner', 'Toner'),
  serum('serum', 'Serum'),
  moisturizer('moisturizer', 'Moisturizer'),
  sunscreen('sunscreen', 'Sunscreen'),
  mask('mask', 'Mask'),
  oil('oil', 'Oil'),
  tool('tool', 'Tool'),
  other('other', 'Other');

  final String value;
  final String display;
  const RetailCategory(this.value, this.display);

  static RetailCategory fromString(String? value) {
    return RetailCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RetailCategory.other,
    );
  }
}

// ==========================================
// MODELS
// ==========================================

/// Aggregated dashboard summary
class EstheticianDashboard {
  final int todayAppointmentsCount;
  final int weekAppointmentsCount;
  final double todayRevenue;
  final int clientProfilesCount;
  final int retailProductsCount;
  final List<DisclosureAlert> disclosureAlerts;
  final List<RecentTreatmentNote> recentTreatmentNotes;

  EstheticianDashboard({
    required this.todayAppointmentsCount,
    required this.weekAppointmentsCount,
    required this.todayRevenue,
    required this.clientProfilesCount,
    required this.retailProductsCount,
    required this.disclosureAlerts,
    required this.recentTreatmentNotes,
  });

  factory EstheticianDashboard.fromJson(Map<String, dynamic> json) {
    return EstheticianDashboard(
      todayAppointmentsCount: json['today_appointments_count'] ?? 0,
      weekAppointmentsCount: json['week_appointments_count'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      clientProfilesCount: json['client_profiles_count'] ?? 0,
      retailProductsCount: json['retail_products_count'] ?? 0,
      disclosureAlerts: (json['disclosure_alerts'] as List? ?? [])
          .map((e) => DisclosureAlert.fromJson(e))
          .toList(),
      recentTreatmentNotes: (json['recent_treatment_notes'] as List? ?? [])
          .map((e) => RecentTreatmentNote.fromJson(e))
          .toList(),
    );
  }
}

/// Disclosure alert for dashboard
class DisclosureAlert {
  final String clientName;
  final int clientId;
  final int bookingId;
  final bool hasConditions;
  final bool pregnantOrNursing;
  final String? areasToAvoid;

  DisclosureAlert({
    required this.clientName,
    required this.clientId,
    required this.bookingId,
    required this.hasConditions,
    required this.pregnantOrNursing,
    this.areasToAvoid,
  });

  factory DisclosureAlert.fromJson(Map<String, dynamic> json) {
    return DisclosureAlert(
      clientName: json['client_name'] ?? '',
      clientId: json['client_id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      hasConditions: json['has_conditions'] ?? false,
      pregnantOrNursing: json['pregnant_or_nursing'] ?? false,
      areasToAvoid: json['areas_to_avoid'],
    );
  }
}

/// Recent treatment note preview for dashboard
class RecentTreatmentNote {
  final int id;
  final String clientName;
  final String treatmentType;
  final String? treatmentTypeDisplay;
  final DateTime createdAt;

  RecentTreatmentNote({
    required this.id,
    required this.clientName,
    required this.treatmentType,
    this.treatmentTypeDisplay,
    required this.createdAt,
  });

  factory RecentTreatmentNote.fromJson(Map<String, dynamic> json) {
    return RecentTreatmentNote(
      id: json['id'] ?? 0,
      clientName: json['client_name'] ?? '',
      treatmentType: json['treatment_type'] ?? '',
      treatmentTypeDisplay: json['treatment_type_display'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Routine step for morning/evening routines
class RoutineStep {
  final int step;
  final String product;
  final String? notes;

  RoutineStep({required this.step, required this.product, this.notes});

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
      step: json['step'] ?? 0,
      product: json['product'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    'product': product,
    'notes': notes,
  };
}

/// Client skin profile
class ClientSkinProfile {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final String? clientEmail;
  final String skinType;
  final String? skinTypeDisplay;
  final List<String> primaryConcerns;
  final String? allergies;
  final String? sensitivities;
  final String? currentProducts;
  final List<RoutineStep> morningRoutine;
  final List<RoutineStep> eveningRoutine;
  final List<RoutineStep> weeklyTreatments;
  final String? regimenNotes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientSkinProfile({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.clientEmail,
    required this.skinType,
    this.skinTypeDisplay,
    required this.primaryConcerns,
    this.allergies,
    this.sensitivities,
    this.currentProducts,
    required this.morningRoutine,
    required this.eveningRoutine,
    required this.weeklyTreatments,
    this.regimenNotes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientSkinProfile.fromJson(Map<String, dynamic> json) {
    return ClientSkinProfile(
      id: json['id'],
      shopId: json['shop'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      skinType: json['skin_type'] ?? 'normal',
      skinTypeDisplay: json['skin_type_display'],
      primaryConcerns: List<String>.from(json['primary_concerns'] ?? []),
      allergies: json['allergies'],
      sensitivities: json['sensitivities'],
      currentProducts: json['current_products'],
      morningRoutine: (json['morning_routine'] as List? ?? [])
          .map((e) => RoutineStep.fromJson(e))
          .toList(),
      eveningRoutine: (json['evening_routine'] as List? ?? [])
          .map((e) => RoutineStep.fromJson(e))
          .toList(),
      weeklyTreatments: (json['weekly_treatments'] as List? ?? [])
          .map((e) => RoutineStep.fromJson(e))
          .toList(),
      regimenNotes: json['regimen_notes'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'skin_type': skinType,
    'primary_concerns': primaryConcerns,
    'allergies': allergies,
    'sensitivities': sensitivities,
    'current_products': currentProducts,
    'morning_routine': morningRoutine.map((e) => e.toJson()).toList(),
    'evening_routine': eveningRoutine.map((e) => e.toJson()).toList(),
    'weekly_treatments': weeklyTreatments.map((e) => e.toJson()).toList(),
    'regimen_notes': regimenNotes,
    'notes': notes,
  };
}

/// Health disclosure form
class HealthDisclosure {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final int? bookingId;
  final bool hasMedicalConditions;
  final String? conditionsDetail;
  final String? currentMedications;
  final String? allergies;
  final bool pregnantOrNursing;
  final String? recentSurgeries;
  final String pressurePreference;
  final String? pressureDisplay;
  final String? areasToAvoid;
  final String? areasToFocus;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final int? createdBy;
  final DateTime createdAt;

  HealthDisclosure({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.bookingId,
    required this.hasMedicalConditions,
    this.conditionsDetail,
    this.currentMedications,
    this.allergies,
    required this.pregnantOrNursing,
    this.recentSurgeries,
    required this.pressurePreference,
    this.pressureDisplay,
    this.areasToAvoid,
    this.areasToFocus,
    required this.acknowledged,
    this.acknowledgedAt,
    this.createdBy,
    required this.createdAt,
  });

  factory HealthDisclosure.fromJson(Map<String, dynamic> json) {
    return HealthDisclosure(
      id: json['id'],
      shopId: json['shop'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      bookingId: json['booking'],
      hasMedicalConditions: json['has_medical_conditions'] ?? false,
      conditionsDetail: json['conditions_detail'],
      currentMedications: json['current_medications'],
      allergies: json['allergies'],
      pregnantOrNursing: json['pregnant_or_nursing'] ?? false,
      recentSurgeries: json['recent_surgeries'],
      pressurePreference: json['pressure_preference'] ?? 'medium',
      pressureDisplay: json['pressure_display'],
      areasToAvoid: json['areas_to_avoid'],
      areasToFocus: json['areas_to_focus'],
      acknowledged: json['acknowledged'] ?? false,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'])
          : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Treatment note
class TreatmentNote {
  final int id;
  final int shopId;
  final int clientId;
  final String? clientName;
  final int? bookingId;
  final DateTime? bookingDate;
  final String? serviceTitle;
  final String treatmentType;
  final String? treatmentTypeDisplay;
  final String? productsUsed;
  final String? observations;
  final String? recommendations;
  final String? nextAppointmentNotes;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final DateTime createdAt;

  TreatmentNote({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.clientName,
    this.bookingId,
    this.bookingDate,
    this.serviceTitle,
    required this.treatmentType,
    this.treatmentTypeDisplay,
    this.productsUsed,
    this.observations,
    this.recommendations,
    this.nextAppointmentNotes,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    required this.createdAt,
  });

  factory TreatmentNote.fromJson(Map<String, dynamic> json) {
    return TreatmentNote(
      id: json['id'],
      shopId: json['shop'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      bookingId: json['booking'],
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : null,
      serviceTitle: json['service_title'],
      treatmentType: json['treatment_type'] ?? 'other',
      treatmentTypeDisplay: json['treatment_type_display'],
      productsUsed: json['products_used'],
      observations: json['observations'],
      recommendations: json['recommendations'],
      nextAppointmentNotes: json['next_appointment_notes'],
      beforePhotoUrl: json['before_photo_url'],
      afterPhotoUrl: json['after_photo_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Retail product
class RetailProduct {
  final int id;
  final int shopId;
  final String name;
  final String? brand;
  final String category;
  final String? categoryDisplay;
  final double? price;
  final String? description;
  final String? imageUrl;
  final bool inStock;
  final String? purchaseLink;
  final bool isActive;
  final DateTime createdAt;

  RetailProduct({
    required this.id,
    required this.shopId,
    required this.name,
    this.brand,
    required this.category,
    this.categoryDisplay,
    this.price,
    this.description,
    this.imageUrl,
    required this.inStock,
    this.purchaseLink,
    required this.isActive,
    required this.createdAt,
  });

  factory RetailProduct.fromJson(Map<String, dynamic> json) {
    return RetailProduct(
      id: json['id'],
      shopId: json['shop'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      category: json['category'] ?? 'other',
      categoryDisplay: json['category_display'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      description: json['description'],
      imageUrl: json['image_url'],
      inStock: json['in_stock'] ?? true,
      purchaseLink: json['purchase_link'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': brand,
    'category': category,
    'price': price?.toString(),
    'description': description,
    'image_url': imageUrl,
    'in_stock': inStock,
    'purchase_link': purchaseLink,
    'is_active': isActive,
  };
}
