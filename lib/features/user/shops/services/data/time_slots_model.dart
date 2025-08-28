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

class SlotItem {
  final int id;
  final int shop;
  final int service;
  final DateTime startTimeUtc;
  final DateTime endTimeUtc;
  final int capacityLeft;
  final bool available;

  SlotItem({
    required this.id,
    required this.shop,
    required this.service,
    required this.startTimeUtc,
    required this.endTimeUtc,
    required this.capacityLeft,
    required this.available,
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) => SlotItem(
    id: json["id"],
    shop: json["shop"],
    service: json["service"],
    startTimeUtc: DateTime.parse(json["start_time"]),
    endTimeUtc: DateTime.parse(json["end_time"]),
    capacityLeft: json["capacity_left"] ?? 0,
    available: json["available"] ?? false,
  );
}
