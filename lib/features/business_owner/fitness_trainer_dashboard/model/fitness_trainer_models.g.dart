// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_trainer_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FitnessDashboardModel _$FitnessDashboardModelFromJson(
  Map<String, dynamic> json,
) => _FitnessDashboardModel(
  schedule: WeeklySchedule.fromJson(
    json['weekly_schedule'] as Map<String, dynamic>,
  ),
  revenue: Revenue.fromJson(json['revenue'] as Map<String, dynamic>),
  packages: Packages.fromJson(json['packages'] as Map<String, dynamic>),
  shopSettings: ShopSettings.fromJson(
    json['shop_settings'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$FitnessDashboardModelToJson(
  _FitnessDashboardModel instance,
) => <String, dynamic>{
  'weekly_schedule': instance.schedule,
  'revenue': instance.revenue,
  'packages': instance.packages,
  'shop_settings': instance.shopSettings,
};

_WeeklySchedule _$WeeklyScheduleFromJson(Map<String, dynamic> json) =>
    _WeeklySchedule(
      classes: (json['classes'] as num).toInt(),
      oneToOne: (json['one_to_one'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$WeeklyScheduleToJson(_WeeklySchedule instance) =>
    <String, dynamic>{
      'classes': instance.classes,
      'one_to_one': instance.oneToOne,
      'total': instance.total,
    };

_Revenue _$RevenueFromJson(Map<String, dynamic> json) => _Revenue(
  paidTotal: (json['paid_total'] as num).toDouble(),
  pendingDepositCount: (json['pending_deposit_count'] as num).toInt(),
);

Map<String, dynamic> _$RevenueToJson(_Revenue instance) => <String, dynamic>{
  'paid_total': instance.paidTotal,
  'pending_deposit_count': instance.pendingDepositCount,
};

_Packages _$PackagesFromJson(Map<String, dynamic> json) =>
    _Packages(activeCount: (json['active_count'] as num).toInt());

Map<String, dynamic> _$PackagesToJson(_Packages instance) => <String, dynamic>{
  'active_count': instance.activeCount,
};

_ShopSettings _$ShopSettingsFromJson(Map<String, dynamic> json) =>
    _ShopSettings(
      cancellationPolicyEnabled: json['cancellation_policy_enabled'] as bool,
      freeCancellationHours: (json['free_cancellation_hours'] as num).toInt(),
    );

Map<String, dynamic> _$ShopSettingsToJson(_ShopSettings instance) =>
    <String, dynamic>{
      'cancellation_policy_enabled': instance.cancellationPolicyEnabled,
      'free_cancellation_hours': instance.freeCancellationHours,
    };

_FitnessPackageModel _$FitnessPackageModelFromJson(Map<String, dynamic> json) =>
    _FitnessPackageModel(
      id: (json['id'] as num).toInt(),
      shop: (json['shop'] as num?)?.toInt(),
      customer: (json['customer'] as num?)?.toInt(),
      totalSessions: (json['total_sessions'] as num).toInt(),
      sessionsRemaining: (json['sessions_remaining'] as num).toInt(),
      price: json['price'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$FitnessPackageModelToJson(
  _FitnessPackageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'shop': instance.shop,
  'customer': instance.customer,
  'total_sessions': instance.totalSessions,
  'sessions_remaining': instance.sessionsRemaining,
  'price': instance.price,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'is_active': instance.isActive,
};

_WorkoutTemplateModel _$WorkoutTemplateModelFromJson(
  Map<String, dynamic> json,
) => _WorkoutTemplateModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$WorkoutTemplateModelToJson(
  _WorkoutTemplateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'exercises': instance.exercises,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

_NutritionPlanModel _$NutritionPlanModelFromJson(Map<String, dynamic> json) =>
    _NutritionPlanModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      notes: json['notes'] as String? ?? '',
      externalLinks:
          (json['external_links'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NutritionPlanModelToJson(_NutritionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'notes': instance.notes,
      'external_links': instance.externalLinks,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
