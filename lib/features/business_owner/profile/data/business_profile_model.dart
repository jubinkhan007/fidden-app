// business_profile_model.dart
//
// Handles the business-owner profile JSON:
// {
//   "id": 1,
//   "name": "Beauty Salon-nafiz",
//   "address": "123 Main St",
//   "location": "12.345,67.890",
//   "capacity": 10,
//   "start_at": "09:00:00",
//   "close_at": "18:00:00",
//   "about_us": "Best salon in town",
//   "shop_img": null,
//   "close_days": ["monday","tuesday"],
//   "owner_id": 1
// }
// lib/features/business_owner/profile/data/business_profile_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';

GetBusinesModel getBusinesModelFromJson(String str) =>
    GetBusinesModel.fromJson(json.decode(str) as Map<String, dynamic>);

String getBusinesModelToJson(GetBusinesModel data) =>
    json.encode(data.toJson());

class GetBusinesModel {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  GetBusinesModel({this.success, this.statusCode, this.message, this.data});

  factory GetBusinesModel.fromJson(Map<String, dynamic> json) {
    return GetBusinesModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] .toString(),
      data: json['data'] == null
          ? Data.fromJson(json) // sometimes API returns the object directly
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'statusCode': statusCode,
    'message': message,
    'data': data?.toJson(),
  };
}

class UploadedFile {
  final int id;
  final String file;
  final DateTime? uploadedAt;

  UploadedFile({required this.id, required this.file, this.uploadedAt});

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      file: json['file'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : null,
    );
  }
}

class Data {
  // API/raw fields
  String? id; // "id"
  String? userId; // "owner_id"
  String? businessName; // "name"
  String? businessAddress; // "address"
  String? details; // "about_us"
  String? image; // "shop_img" (can be null or absolute/relative)
  int? capacity; // "capacity"

  // Times
  String? rawStartAt; // "start_at" (e.g. "09:00:00")
  String? rawCloseAt; // "close_at" (e.g. "18:00:00")
  String? startTime; // UI-friendly "09:00 AM"
  String? endTime; // UI-friendly "06:00 PM"

  // Legacy single-range day fields (optional for UI compatibility)
  String? startDay; // first of closeDays if you want to show a range
  String? endDay; // second of closeDays if you want to show a range

  // Days
  List<String>? closeDays; // from API: ["monday","tuesday"]
  List<String>? openDays; // computed: allDays - closeDays (title-cased)

  // Location
  double? latitude;
  double? longitude;

  // Timestamps (if present)
  DateTime? createdAt;
  DateTime? updatedAt;

  bool? isVarified;
  String? status;
  List<UploadedFile>? verificationFiles;

  Data({
    this.id,
    this.userId,
    this.businessName,
    this.businessAddress,
    this.details,
    this.image,
    this.capacity,
    this.rawStartAt,
    this.rawCloseAt,
    this.startTime,
    this.endTime,
    this.startDay,
    this.endDay,
    this.closeDays,
    this.openDays,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.isVarified,
    this.status,
    this.verificationFiles,
  });

  /// All 7 days for computing openDays
  static const List<String> _allDays = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// Title-case a weekday string (e.g., "monday" -> "Monday").
  static String _titleCaseDay(String d) {
    if (d.isEmpty) return d;
    final lower = d.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  /// Convert "HH:mm:ss" -> "hh:mm AM/PM"
  static String? _toUiTime(String? hhmmss) {
    if (hhmmss == null || hhmmss.isEmpty) return null;
    // Expecting e.g. "09:00:00" or "18:05:30"
    final parts = hhmmss.split(':');
    if (parts.length < 2) return hhmmss; // fallback as-is
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;
    final ampm = (h < 12) ? 'AM' : 'PM';
    final mm = m.toString().padLeft(2, '0');
    final hh = hour12.toString().padLeft(2, '0');
    return '$hh:$mm $ampm';
  }

  /// Convert "hh:mm AM/PM" -> "HH:mm:ss" (seconds fixed to :00)
  static String? _toApiTime(String? uiTime) {
    if (uiTime == null || uiTime.isEmpty) return null;
    final reg = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    );
    final m = reg.firstMatch(uiTime);
    if (m == null) return uiTime; // fallback as-is

    int hour = int.parse(m.group(1)!);
    final minute = int.parse(m.group(2)!);
    final ampm = m.group(3)!.toUpperCase();

    if (ampm == 'PM' && hour != 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;

    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  /// Parse "12.345,67.890" into (lat, lon)
  static (double?, double?) _parseLocation(String? loc) {
    if (loc == null || loc.isEmpty) return (null, null);
    final parts = loc.split(',');
    if (parts.isEmpty) return (null, null);
    final lat = double.tryParse(parts[0].trim());
    final lon = parts.length > 1 ? double.tryParse(parts[1].trim()) : null;
    return (lat, lon);
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    // Parse base fields
    final id = json['id']?.toString();
    final ownerId = json['owner_id']?.toString();
    final name = json['name'] .toString();
    final address = json['address'] .toString();
    final details = json['about_us'] .toString();
    final img = json['shop_img'] .toString();
    final capacity = (json['capacity'] is int)
        ? json['capacity'] as int
        : int.tryParse('${json['capacity']}');

    // Times
    final rawStartAt = json['start_at'] .toString();
    final rawCloseAt = json['close_at'] .toString();
    final uiStart = _toUiTime(rawStartAt);
    final uiClose = _toUiTime(rawCloseAt);

    // Location
    final (lat, lon) = _parseLocation(json['location'] .toString());

    // close_days (array of strings, usually lowercase)
    final List<String> closeDays =
        (json['close_days'] as List?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
        <String>[];

    // Compute openDays as the complement of closeDays
    final Set<String> openSet = _allDays
        .where((d) => !closeDays.contains(d))
        .toSet();
    final List<String> openDays = openSet.toList();

    // Optional legacy single-range (if you still show start/end day somewhere)
    final startDay = closeDays.isNotEmpty
        ? _titleCaseDay(closeDays.first)
        : null;
    final endDay = closeDays.length > 1 ? _titleCaseDay(closeDays[1]) : null;

    // Parse optional timestamps if ever sent
    DateTime? createdAt;
    DateTime? updatedAt;
    try {
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt'] as String);
      }
    } catch (_) {}
    try {
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.parse(json['updatedAt'] as String);
      }
    } catch (_) {}

    return Data(
      id: id,
      userId: ownerId,
      businessName: name,
      businessAddress: address,
      details: details,
      image: img,
      capacity: capacity,
      rawStartAt: rawStartAt,
      rawCloseAt: rawCloseAt,
      startTime: uiStart, // UI-friendly
      endTime: uiClose, // UI-friendly
      startDay: startDay,
      endDay: endDay,
      closeDays: closeDays
          .map(_titleCaseDay)
          .toList(), // e.g. ["Monday","Tuesday"]
      openDays: openDays.map(_titleCaseDay).toList(), // computed complement
      latitude: lat,
      longitude: lon,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isVarified: json['is_varified'] as bool?,
      status: json['status'] .toString(),
      verificationFiles: json['uploaded_files'] != null
          ? (json['uploaded_files'] as List)
                .map((fileJson) => UploadedFile.fromJson(fileJson))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Prefer sending raw API time format if available; otherwise convert UI to API
    final startAtToSend = rawStartAt ?? _toApiTime(startTime);
    final closeAtToSend = rawCloseAt ?? _toApiTime(endTime);

    // Format location back to "lat,long" if both are present
    final loc = (latitude != null && longitude != null)
        ? '${latitude!},${longitude!}'
        : null;

    // Convert TitleCase days back to lowercase for API
    final closeDaysApi = (closeDays ?? [])
        .map((d) => d.toString().toLowerCase())
        .toList();

    return {
      'id': id,
      'owner_id': userId,
      'name': businessName,
      'address': businessAddress,
      'about_us': details,
      'shop_img': image,
      'capacity': capacity,
      'location': loc,
      'start_at': startAtToSend,
      'close_at': closeAtToSend,
      'close_days': closeDaysApi,
      // NOTE: API doesn’t accept open_days; it infers from close_days.
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'is_varified': false,
      'status': status,
      'verification_files': verificationFiles,
    };
  }
}

/// Represents the full API response for the business profile.
class BusinessProfileResponse {
  final bool success;
  final int statusCode;
  final String message;
  final BusinessProfileModel data;

  const BusinessProfileResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory BusinessProfileResponse.fromJson(Map<String, dynamic> json) {
    // Handles cases where the 'data' key might be missing and the profile is at the root.
    final dataJson = json['data'] != null
        ? json['data'] as Map<String, dynamic>
        : json;

    return BusinessProfileResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 500,
      message: json['message'] ?? 'Unknown error',
      data: BusinessProfileModel.fromJson(dataJson),
    );
  }
}

/// Represents the core business profile data.
@immutable
class BusinessProfileModel {
  final int id;
  final int ownerId;
  final String name;
  final String address;
  final String aboutUs;
  final String? shopImg;
  final int capacity;
  final TimeOfDay startAt;
  final TimeOfDay closeAt;
  final List<String> closeDays; // e.g., ["monday", "tuesday"]
  final (double, double)? location; // (latitude, longitude)
  final List<VerificationFile> verificationFiles;

  // Computed properties for easier UI access
  List<String> get openDays {
    const allDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final closed = closeDays.toSet();
    return allDays.where((day) => !closed.contains(day)).toList();
  }

  const BusinessProfileModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.aboutUs,
    this.shopImg,
    required this.capacity,
    required this.startAt,
    required this.closeAt,
    this.closeDays = const [],
    this.location,
    this.verificationFiles = const [],
  });

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      id: _parseInt(json['id']),
      ownerId: _parseInt(json['owner_id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      aboutUs: json['about_us'] ?? '',
      shopImg: json['shop_img'],
      capacity: _parseInt(json['capacity']),
      startAt:
          _parseTime(json['start_at']) ?? const TimeOfDay(hour: 9, minute: 0),
      closeAt:
          _parseTime(json['close_at']) ?? const TimeOfDay(hour: 17, minute: 0),
      closeDays:
          (json['close_days'] as List?)
              ?.map((day) => day.toString().toLowerCase())
              .toList() ??
          [],
      location: _parseLocation(json['location']),
      verificationFiles:
          (json['uploaded_files'] as List?)
              ?.map(
                (file) =>
                    VerificationFile.fromJson(file as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // Helper to safely parse an integer from various types
  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  // Helper to parse "HH:mm:ss" into a TimeOfDay object
  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return null;
  }

  // Helper to parse "lat,lon" into a tuple
  static (double, double)? _parseLocation(String? locStr) {
    if (locStr == null) return null;
    final parts = locStr.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());
      if (lat != null && lon != null) {
        return (lat, lon);
      }
    }
    return null;
  }
}

/// Represents a file uploaded for verification.
@immutable
class VerificationFile {
  final int id;
  final String fileUrl;
  final DateTime? uploadedAt;

  const VerificationFile({
    required this.id,
    required this.fileUrl,
    this.uploadedAt,
  });

  factory VerificationFile.fromJson(Map<String, dynamic> json) {
    return VerificationFile(
      id: json['id'] ?? 0,
      fileUrl: json['file'] ?? '',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }
}
