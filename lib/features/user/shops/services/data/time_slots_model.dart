// lib/features/user/shops/services/data/slots_model.dart
import 'dart:convert';

SlotsResponse slotsResponseFromJson(String str) =>
    SlotsResponse.fromJson(json.decode(str));

class SlotsResponse {
  final List<SlotItem> slots;
  final String? timezoneId; // New field

  SlotsResponse({required this.slots, this.timezoneId});

  factory SlotsResponse.fromJson(Map<String, dynamic> json) {
    // 1. New Format: { "available_slots": [...], "timezone_id": "...", ... }
    if (json.containsKey('available_slots')) {
      final list = (json['available_slots'] as List<dynamic>? ?? []).map((e) {
        // Inject top-level fields into slot json if needed, or SlotItem handles it
        // Assuming slot objects inside available_slots have necessary data
        if (e is Map<String, dynamic>) {
          // Inject shop_id/service_id if missing in slot but present in parent
          if (!e.containsKey('shop_id')) e['shop_id'] = json['shop_id'];
          if (!e.containsKey('service_id'))
            e['service_id'] = json['service_id'];
        }
        return SlotItem.fromJson(e);
      }).toList();
      return SlotsResponse(slots: list, timezoneId: json['timezone_id']);
    }

    // 2. Legacy Format: { "slots": [...] }
    return SlotsResponse(
      slots: (json["slots"] as List<dynamic>? ?? [])
          .map((e) => SlotItem.fromJson(e))
          .toList(),
    );
  }
}

// lib/features/user/shops/services/data/time_slots_model.dart
// lib/features/user/shops/services/data/time_slots_model.dart
class SlotItem {
  final int id; // 0 if computed slot, or non-zero if physical slot
  final int shop;
  final int service;

  // Rule-based fields
  final String? startAtIso; // with offset e.g. "2026-03-09T09:00:00-05:00"
  final String? startAtUtcIso; // "2026-03-09T14:00:00Z"
  final int availabilityCount;

  // Legacy/Computed fields
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final int capacityLeft;
  final bool available;

  // NEW: local-only flag for owner UI (not part of API)
  final bool disabledByService;

  SlotItem({
    required this.id,
    required this.shop,
    required this.service,
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.capacityLeft,
    required this.available,
    this.startAtIso,
    this.startAtUtcIso,
    this.availabilityCount = 1,
    this.disabledByService = false,
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    // 1. Try new Rule-Based format
    if (json.containsKey('start_at')) {
      final isoStart = json['start_at'] as String;
      final isoUtc = json['start_at_utc'] as String;

      // Parse to DateTime for internal compatibility (legacy logic rely on DateTime)
      // Note: DateTime.parse(isoStart) preserves offset if isUtc=false,
      // but Dart DateTime is naive or UTC. We just store the ISO string for truth.
      final startDt = DateTime.parse(isoUtc).toUtc();
      // Assume duration or end time is handled elsewhere or irrelevant for start-time based booking
      // Mocking end time as +30m just for null-safety if needed, or derived
      final endDt = startDt.add(const Duration(minutes: 30));

      return SlotItem(
        id: json['id'] ?? 0, // might be 0 for computed slots
        shop: json['shop_id'] ?? 0,
        service: json['service_id'] ?? 0,
        startTimeUtc: startDt,
        endTimeUtc: endDt, // approximation
        capacityLeft: json['availability_count'] ?? 1,
        available: true,
        startAtIso: isoStart,
        startAtUtcIso: isoUtc,
        availabilityCount: json['availability_count'] ?? 1,
      );
    }

    // 2. Fallback to Legacy Format (avail_starts / physical slots)
    return SlotItem(
      id: json['id'] ?? 0,
      shop: json['shop'] ?? 0,
      service: json['service'] ?? 0,
      startTimeUtc:
          DateTime.tryParse(json['start_time'] ?? '')?.toUtc() ??
          DateTime.now(),
      endTimeUtc:
          DateTime.tryParse(json['end_time'] ?? '')?.toUtc() ?? DateTime.now(),
      capacityLeft: json['capacity_left'] ?? 0,
      available: json['available'] == true,
      disabledByService: json['disabled_by_service'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop': shop,
    'service': service,
    'start_time': startTimeUtc.toIso8601String(),
    'end_time': endTimeUtc.toIso8601String(),
    'start_at': startAtIso,
    'start_at_utc': startAtUtcIso,
    'capacity_left': capacityLeft,
    'available': available,
    'disabled_by_service': disabledByService,
  };

  SlotItem copyWith({bool? disabledByService}) => SlotItem(
    id: id,
    shop: shop,
    service: service,
    startTimeUtc: startTimeUtc,
    endTimeUtc: endTimeUtc,
    capacityLeft: capacityLeft,
    available: available,
    startAtIso: startAtIso,
    startAtUtcIso: startAtUtcIso,
    availabilityCount: availabilityCount,
    disabledByService: disabledByService ?? this.disabledByService,
  );
}
