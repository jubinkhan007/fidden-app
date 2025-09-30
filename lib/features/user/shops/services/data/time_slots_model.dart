// lib/features/user/shops/services/data/slots_model.dart
import 'dart:convert';

SlotsResponse slotsResponseFromJson(String str) =>
    SlotsResponse.fromJson(json.decode(str));

class SlotsResponse {
  final List<SlotItem> slots;

  SlotsResponse({required this.slots});

  factory SlotsResponse.fromJson(Map<String, dynamic> json) => SlotsResponse(
    slots: (json["slots"] as List<dynamic>? ?? [])
        .map((e) => SlotItem.fromJson(e))
        .toList(),
  );
}

// lib/features/user/shops/services/data/time_slots_model.dart
class SlotItem {
  final int id;
  final int shop;
  final int service;
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
    this.disabledByService = false,  // default
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) => SlotItem(
    id: json['id'],
    shop: json['shop'],
    service: json['service'],
    startTimeUtc: DateTime.parse(json['start_time']).toUtc(),
    endTimeUtc: DateTime.parse(json['end_time']).toUtc(),
    capacityLeft: json['capacity_left'],
    available: json['available'] == true,
    // json may contain `disabled_by_service`; if present, use it
    disabledByService: json['disabled_by_service'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop': shop,
    'service': service,
    'start_time': startTimeUtc.toIso8601String(),
    'end_time': endTimeUtc.toIso8601String(),
    'capacity_left': capacityLeft,
    'available': available,
  };

  SlotItem copyWith({bool? disabledByService}) => SlotItem(
    id: id,
    shop: shop,
    service: service,
    startTimeUtc: startTimeUtc,
    endTimeUtc: endTimeUtc,
    capacityLeft: capacityLeft,
    available: available,
    disabledByService: disabledByService ?? this.disabledByService,
  );
}

