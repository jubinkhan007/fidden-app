import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event_model.freezed.dart';
part 'calendar_event_model.g.dart';

@freezed
abstract class CalendarEventModel with _$CalendarEventModel {
  const factory CalendarEventModel({
    @JsonKey(name: 'event_type')
    required String eventType, // "booking" | "blocked"
    required int id,
    required String title,
    @JsonKey(name: 'start_at')
    required String startAt, // Keep as String to preserve offset
    @JsonKey(name: 'end_at')
    required String endAt, // Keep as String to preserve offset
    @JsonKey(name: 'start_at_utc') required DateTime startAtUtc,
    @JsonKey(name: 'end_at_utc') required DateTime endAtUtc,
    @JsonKey(name: 'timezone_id') required String timezoneId,
    @JsonKey(name: 'calendar_status')
    required String calendarStatus, // CONFIRMED|PENDING...
    @Default([]) List<String> badges, // ["PAID", "DEP_DUE", ...]
    // Joint fields
    @Default(null) ProviderLite? provider,

    // Booking specific
    @Default(null) CustomerLite? customer,
    @Default(null) ServiceLite? service,

    // Blocked specific
    @JsonKey(name: 'blocked_reason') String? blockedReason,
    @Default(null) String? note,

    // Fitness / Session Type
    @Default(null)
    @JsonKey(name: 'session_type')
    String? sessionType, // "class" | "1to1" | null
  }) = _CalendarEventModel;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);
}

@freezed
abstract class ProviderLite with _$ProviderLite {
  const factory ProviderLite({required int id, required String name}) =
      _ProviderLite;

  factory ProviderLite.fromJson(Map<String, dynamic> json) =>
      _$ProviderLiteFromJson(json);
}

@freezed
abstract class CustomerLite with _$CustomerLite {
  const factory CustomerLite({
    required int id,
    required String name, // "John Doe"
  }) = _CustomerLite;

  factory CustomerLite.fromJson(Map<String, dynamic> json) =>
      _$CustomerLiteFromJson(json);
}

@freezed
abstract class ServiceLite with _$ServiceLite {
  const factory ServiceLite({required int id, required String title}) =
      _ServiceLite;

  factory ServiceLite.fromJson(Map<String, dynamic> json) =>
      _$ServiceLiteFromJson(json);
}

// Helper Enums for UI Logic
enum CalendarStatus {
  CONFIRMED,
  PENDING,
  COMPLETED,
  CANCELED,
  NO_SHOW,
  BLOCKED,
  UNKNOWN,
}

extension CalendarStatusExt on String {
  CalendarStatus toCalendarStatus() {
    switch (this.toUpperCase()) {
      case 'CONFIRMED':
        return CalendarStatus.CONFIRMED;
      case 'PENDING':
        return CalendarStatus.PENDING;
      case 'COMPLETED':
        return CalendarStatus.COMPLETED;
      case 'CANCELED':
        return CalendarStatus.CANCELED;
      case 'NO_SHOW':
        return CalendarStatus.NO_SHOW;
      case 'BLOCKED':
        return CalendarStatus.BLOCKED;
      default:
        return CalendarStatus.UNKNOWN;
    }
  }
}

// Display Priority: DEP_DUE, FORMS, PAID, NEW
enum CalendarBadge { DEP_DUE, FORMS, PAID, NEW, UNKNOWN }

extension CalendarBadgeStringExt on String {
  CalendarBadge toCalendarBadge() {
    switch (this.toUpperCase()) {
      case 'DEP_DUE':
        return CalendarBadge.DEP_DUE;
      case 'FORMS':
        return CalendarBadge.FORMS;
      case 'PAID':
        return CalendarBadge.PAID;
      case 'NEW':
        return CalendarBadge.NEW;
      default:
        return CalendarBadge.UNKNOWN;
    }
  }
}
