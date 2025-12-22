/// Massage Therapist Data Models 💆

/// Pressure preference for massage sessions
enum PressurePreference {
  light('light', 'Light'),
  medium('medium', 'Medium'),
  firm('firm', 'Firm'),
  deep('deep', 'Deep');

  final String value;
  final String display;
  const PressurePreference(this.value, this.display);

  static PressurePreference fromString(String? val) {
    return PressurePreference.values.firstWhere(
      (e) => e.value == val?.toLowerCase(),
      orElse: () => PressurePreference.medium,
    );
  }
}

/// Treatment type for massage sessions
enum MassageTreatmentType {
  swedish('swedish', 'Swedish'),
  deepTissue('deep_tissue', 'Deep Tissue'),
  sports('sports', 'Sports'),
  hotStone('hot_stone', 'Hot Stone'),
  thai('thai', 'Thai'),
  shiatsu('shiatsu', 'Shiatsu'),
  prenatal('prenatal', 'Prenatal'),
  lymphatic('lymphatic', 'Lymphatic'),
  trigger('trigger_point', 'Trigger Point'),
  other('other', 'Other');

  final String value;
  final String display;
  const MassageTreatmentType(this.value, this.display);

  static MassageTreatmentType fromString(String? val) {
    return MassageTreatmentType.values.firstWhere(
      (e) => e.value == val?.toLowerCase(),
      orElse: () => MassageTreatmentType.swedish,
    );
  }
}

/// Summary of massage dashboard data
class MassageDashboard {
  final int todayBookingsCount;
  final int weekBookingsCount;
  final double todayRevenue;
  final int clientProfilesCount;
  final int activeDisclosuresCount;
  final List<DisclosureAlert> disclosureAlerts;
  final List<RecentTreatmentNote> recentTreatmentNotes;

  MassageDashboard({
    this.todayBookingsCount = 0,
    this.weekBookingsCount = 0,
    this.todayRevenue = 0.0,
    this.clientProfilesCount = 0,
    this.activeDisclosuresCount = 0,
    this.disclosureAlerts = const [],
    this.recentTreatmentNotes = const [],
  });

  factory MassageDashboard.fromJson(Map<String, dynamic> json) {
    return MassageDashboard(
      todayBookingsCount: json['today_bookings_count'] ?? 0,
      weekBookingsCount: json['week_bookings_count'] ?? 0,
      todayRevenue: (json['today_revenue'] as num?)?.toDouble() ?? 0.0,
      clientProfilesCount: json['client_profiles_count'] ?? 0,
      activeDisclosuresCount: json['active_disclosures_count'] ?? 0,
      disclosureAlerts: (json['disclosure_alerts'] as List? ?? [])
          .map((e) => DisclosureAlert.fromJson(e))
          .toList(),
      recentTreatmentNotes: (json['recent_treatment_notes'] as List? ?? [])
          .map((e) => RecentTreatmentNote.fromJson(e))
          .toList(),
    );
  }
}

/// Alert for health disclosures
class DisclosureAlert {
  final int clientId;
  final String clientName;
  final bool hasConditions;
  final bool pregnantOrNursing;
  final String? areasToAvoid;
  final int bookingId;

  DisclosureAlert({
    required this.clientId,
    required this.clientName,
    this.hasConditions = false,
    this.pregnantOrNursing = false,
    this.areasToAvoid,
    this.bookingId = 0,
  });

  factory DisclosureAlert.fromJson(Map<String, dynamic> json) {
    return DisclosureAlert(
      clientId: json['client_id'] ?? json['client'] ?? 0,
      clientName: json['client_name'] ?? 'Unknown',
      hasConditions: json['has_conditions'] ?? false,
      pregnantOrNursing: json['pregnant_or_nursing'] ?? false,
      areasToAvoid: json['areas_to_avoid'],
      bookingId: json['booking_id'] ?? json['booking'] ?? 0,
    );
  }
}

/// Recent treatment note summary
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
      clientName: json['client_name'] ?? 'Unknown',
      treatmentType: json['treatment_type'] ?? 'swedish',
      treatmentTypeDisplay: json['treatment_type_display'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Client profile for massage therapy
class MassageClientProfile {
  final int id;
  final int clientId;
  final String? clientName;
  final String pressurePreference;
  final String? pressureDisplay;
  final String? areasOfConcern;
  final String? areasToAvoid;
  final String? medicalConditions;
  final String? currentMedications;
  final String? injuriesHistory;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MassageClientProfile({
    required this.id,
    required this.clientId,
    this.clientName,
    this.pressurePreference = 'medium',
    this.pressureDisplay,
    this.areasOfConcern,
    this.areasToAvoid,
    this.medicalConditions,
    this.currentMedications,
    this.injuriesHistory,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MassageClientProfile.fromJson(Map<String, dynamic> json) {
    return MassageClientProfile(
      id: json['id'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      pressurePreference: json['pressure_preference'] ?? 'medium',
      pressureDisplay: json['pressure_preference_display'],
      areasOfConcern: json['areas_of_concern'],
      areasToAvoid: json['areas_to_avoid'],
      medicalConditions: json['medical_conditions'],
      currentMedications: json['current_medications'],
      injuriesHistory: json['injuries_history'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'pressure_preference': pressurePreference,
    'areas_of_concern': areasOfConcern,
    'areas_to_avoid': areasToAvoid,
    'medical_conditions': medicalConditions,
    'current_medications': currentMedications,
    'injuries_history': injuriesHistory,
    'notes': notes,
  };
}

/// Health disclosure for massage clients
class MassageHealthDisclosure {
  final int id;
  final int clientId;
  final String? clientName;
  final int bookingId;
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
  final DateTime createdAt;

  MassageHealthDisclosure({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.bookingId,
    this.hasMedicalConditions = false,
    this.conditionsDetail,
    this.currentMedications,
    this.allergies,
    this.pregnantOrNursing = false,
    this.recentSurgeries,
    this.pressurePreference = 'medium',
    this.pressureDisplay,
    this.areasToAvoid,
    this.areasToFocus,
    this.acknowledged = false,
    required this.createdAt,
  });

  factory MassageHealthDisclosure.fromJson(Map<String, dynamic> json) {
    return MassageHealthDisclosure(
      id: json['id'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      bookingId: json['booking'] ?? 0,
      hasMedicalConditions: json['has_medical_conditions'] ?? false,
      conditionsDetail: json['conditions_detail'],
      currentMedications: json['current_medications'],
      allergies: json['allergies'],
      pregnantOrNursing: json['pregnant_or_nursing'] ?? false,
      recentSurgeries: json['recent_surgeries'],
      pressurePreference: json['pressure_preference'] ?? 'medium',
      pressureDisplay: json['pressure_preference_display'],
      areasToAvoid: json['areas_to_avoid'],
      areasToFocus: json['areas_to_focus'],
      acknowledged: json['acknowledged'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Treatment note for massage sessions
class MassageTreatmentNote {
  final int id;
  final int clientId;
  final String? clientName;
  final int bookingId;
  final String? serviceTitle;
  final DateTime? bookingDate;
  final String treatmentType;
  final String? treatmentTypeDisplay;
  final String pressureUsed;
  final String? areasWorked;
  final String? observations;
  final String? recommendations;
  final String? nextAppointmentNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  MassageTreatmentNote({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.bookingId,
    this.serviceTitle,
    this.bookingDate,
    this.treatmentType = 'swedish',
    this.treatmentTypeDisplay,
    this.pressureUsed = 'medium',
    this.areasWorked,
    this.observations,
    this.recommendations,
    this.nextAppointmentNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MassageTreatmentNote.fromJson(Map<String, dynamic> json) {
    return MassageTreatmentNote(
      id: json['id'] ?? 0,
      clientId: json['client'] ?? 0,
      clientName: json['client_name'],
      bookingId: json['booking'] ?? 0,
      serviceTitle: json['service_title'],
      bookingDate: json['booking_date'] != null
          ? DateTime.tryParse(json['booking_date'])
          : null,
      treatmentType: json['treatment_type'] ?? 'swedish',
      treatmentTypeDisplay: json['treatment_type_display'],
      pressureUsed: json['pressure_used'] ?? 'medium',
      areasWorked: json['areas_worked'],
      observations: json['observations'],
      recommendations: json['recommendations'],
      nextAppointmentNotes: json['next_appointment_notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'client': clientId,
    'booking': bookingId,
    'treatment_type': treatmentType,
    'pressure_used': pressureUsed,
    'areas_worked': areasWorked,
    'observations': observations,
    'recommendations': recommendations,
    'next_appointment_notes': nextAppointmentNotes,
  };
}
