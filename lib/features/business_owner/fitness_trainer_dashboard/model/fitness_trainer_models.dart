import 'package:freezed_annotation/freezed_annotation.dart';

part 'fitness_trainer_models.freezed.dart';
part 'fitness_trainer_models.g.dart';

@freezed
abstract class FitnessDashboardModel with _$FitnessDashboardModel {
  const factory FitnessDashboardModel({
    @JsonKey(name: 'weekly_schedule') required WeeklySchedule schedule,
    required Revenue revenue,
    required Packages packages,
    @JsonKey(name: 'shop_settings') required ShopSettings shopSettings,
  }) = _FitnessDashboardModel;

  factory FitnessDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$FitnessDashboardModelFromJson(json);
}

@freezed
abstract class WeeklySchedule with _$WeeklySchedule {
  const factory WeeklySchedule({
    required int classes,
    @JsonKey(name: 'one_to_one') required int oneToOne,
    required int total,
  }) = _WeeklySchedule;

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) =>
      _$WeeklyScheduleFromJson(json);
}

@freezed
abstract class Revenue with _$Revenue {
  const factory Revenue({
    @JsonKey(name: 'paid_total') required double paidTotal,
    @JsonKey(name: 'pending_deposit_count') required int pendingDepositCount,
  }) = _Revenue;

  factory Revenue.fromJson(Map<String, dynamic> json) =>
      _$RevenueFromJson(json);
}

@freezed
abstract class Packages with _$Packages {
  const factory Packages({
    @JsonKey(name: 'active_count') required int activeCount,
  }) = _Packages;

  factory Packages.fromJson(Map<String, dynamic> json) =>
      _$PackagesFromJson(json);
}

@freezed
abstract class ShopSettings with _$ShopSettings {
  const factory ShopSettings({
    @JsonKey(name: 'cancellation_policy_enabled')
    required bool cancellationPolicyEnabled,
    @JsonKey(name: 'free_cancellation_hours')
    required int freeCancellationHours,
  }) = _ShopSettings;

  factory ShopSettings.fromJson(Map<String, dynamic> json) =>
      _$ShopSettingsFromJson(json);
}

@freezed
abstract class FitnessPackageModel with _$FitnessPackageModel {
  const factory FitnessPackageModel({
    required int id,
    int? shop, // ID of the shop
    int? customer, // ID of the customer (optional/nullable in list?)
    @JsonKey(name: 'total_sessions') required int totalSessions,
    @JsonKey(name: 'sessions_remaining') required int sessionsRemaining,
    required String price,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _FitnessPackageModel;

  factory FitnessPackageModel.fromJson(Map<String, dynamic> json) =>
      _$FitnessPackageModelFromJson(json);
}

@freezed
abstract class WorkoutTemplateModel with _$WorkoutTemplateModel {
  const factory WorkoutTemplateModel({
    required int id,
    required String title,
    required String description,
    @Default([]) List<Map<String, dynamic>> exercises,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _WorkoutTemplateModel;

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateModelFromJson(json);
}

@freezed
abstract class NutritionPlanModel with _$NutritionPlanModel {
  const factory NutritionPlanModel({
    required int id,
    required String title,
    @Default('') String notes,
    @JsonKey(name: 'external_links') @Default([]) List<String> externalLinks,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _NutritionPlanModel;

  factory NutritionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$NutritionPlanModelFromJson(json);
}
