// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) =>
    _CalendarEventModel(
      eventType: json['event_type'] as String,
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      startAt: json['start_at'] as String,
      endAt: json['end_at'] as String,
      startAtUtc: DateTime.parse(json['start_at_utc'] as String),
      endAtUtc: DateTime.parse(json['end_at_utc'] as String),
      timezoneId: json['timezone_id'] as String,
      calendarStatus: json['calendar_status'] as String,
      badges:
          (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      provider: json['provider'] == null
          ? null
          : ProviderLite.fromJson(json['provider'] as Map<String, dynamic>),
      customer: json['customer'] == null
          ? null
          : CustomerLite.fromJson(json['customer'] as Map<String, dynamic>),
      service: json['service'] == null
          ? null
          : ServiceLite.fromJson(json['service'] as Map<String, dynamic>),
      blockedReason: json['blocked_reason'] as String?,
      note: json['note'] as String? ?? null,
    );

Map<String, dynamic> _$CalendarEventModelToJson(_CalendarEventModel instance) =>
    <String, dynamic>{
      'event_type': instance.eventType,
      'id': instance.id,
      'title': instance.title,
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'start_at_utc': instance.startAtUtc.toIso8601String(),
      'end_at_utc': instance.endAtUtc.toIso8601String(),
      'timezone_id': instance.timezoneId,
      'calendar_status': instance.calendarStatus,
      'badges': instance.badges,
      'provider': instance.provider,
      'customer': instance.customer,
      'service': instance.service,
      'blocked_reason': instance.blockedReason,
      'note': instance.note,
    };

_ProviderLite _$ProviderLiteFromJson(Map<String, dynamic> json) =>
    _ProviderLite(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$ProviderLiteToJson(_ProviderLite instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_CustomerLite _$CustomerLiteFromJson(Map<String, dynamic> json) =>
    _CustomerLite(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$CustomerLiteToJson(_CustomerLite instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_ServiceLite _$ServiceLiteFromJson(Map<String, dynamic> json) => _ServiceLite(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
);

Map<String, dynamic> _$ServiceLiteToJson(_ServiceLite instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};
