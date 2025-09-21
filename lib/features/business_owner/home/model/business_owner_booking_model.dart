import 'dart:convert';

OwnerBookingsResponse ownerBookingsResponseFromJson(String str) =>
    OwnerBookingsResponse.fromJson(json.decode(str));

String ownerBookingsResponseToJson(OwnerBookingsResponse data) =>
    json.encode(data.toJson());

class OwnerBookingsResponse {
  final String? next;
  final String? previous;
  final List<OwnerBookingItem> results;

  OwnerBookingsResponse({
    this.next,
    this.previous,
    required this.results,
  });

  factory OwnerBookingsResponse.fromJson(Map<String, dynamic> json) {
    return OwnerBookingsResponse(
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => OwnerBookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'next': next,
        'previous': previous,
        'results': results.map((e) => e.toJson()).toList(),
      };
}

class OwnerBookingItem {
  final int id;
  final int user;
  final String userEmail;
  final String? userName;
  final String? profileImage;
  final int shop;
  final String shopName;
  final int slot;
  final DateTime slotTime;
  final String serviceTitle;
  final String serviceDuration; // "30"
  final String status; // "active"
  final DateTime createdAt;
  final DateTime updatedAt;

  OwnerBookingItem({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.userName,
    required this.profileImage,
    required this.shop,
    required this.shopName,
    required this.slot,
    required this.slotTime,
    required this.serviceTitle,
    required this.serviceDuration,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OwnerBookingItem.fromJson(Map<String, dynamic> j) {
  int _toInt(v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  // Parse the datetime but keep the clock fields as-is (ignore Z / +HH:MM)
  DateTime _dtKeepWall(v) {
    final s = '$v';
    // remove trailing 'Z' or '+HH:MM' or '-HH:MM'
    final core = s.replaceFirst(RegExp(r'(Z|[+-]\d{2}:\d{2})$'), '');
    // also tolerate space instead of 'T'
    final normalized = core.replaceFirst(' ', 'T');
    return DateTime.parse(normalized); // same HH:mm as the original string
  }

  return OwnerBookingItem(
    id: _toInt(j['id']),
    user: _toInt(j['user']),
    userEmail: j['user_email'] ?? '',
    userName: j['user_name'],
    profileImage: j['profile_image'],
    shop: _toInt(j['shop']),
    shopName: j['shop_name'] ?? '',
    slot: _toInt(j['slot']),
    slotTime: _dtKeepWall(j['slot_time']),  // ← keeps 09:00 if payload had 09:00+06:00
    serviceTitle: j['service_title'] ?? '',
    serviceDuration: j['service_duration'] ?? '',
    status: (j['status'] ?? '').toString(),
    createdAt: _dtKeepWall(j['created_at']),
    updatedAt: _dtKeepWall(j['updated_at']),
  );
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'user_email': userEmail,
        'user_name': userName,
        'profile_image': profileImage,
        'shop': shop,
        'shop_name': shopName,
        'slot': slot,
        'slot_time': slotTime.toIso8601String(),
        'service_title': serviceTitle,
        'service_duration': serviceDuration,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
