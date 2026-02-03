// lib/features/user/shops/data/provider_model.dart
import 'package:fidden/core/models/time_range.dart';

/// Represents a service provider (barber, stylist, etc.) at a shop
class Provider {
  final int id;
  final String name;
  final String? profileImage;
  final String? bio;
  final List<int>? serviceIds;

  /// Schedule: {'monday': [TimeRange(start,end)], ...}
  /// If null, provider inherits shop hours.
  final Map<String, List<TimeRange>>? schedule;

  /// Concurrency Control: Maximum simultaneous "processing" tasks
  final int maxConcurrentProcessingJobs;

  Provider({
    required this.id,
    required this.name,
    this.profileImage,
    this.bio,
    this.serviceIds,
    this.schedule,
    this.maxConcurrentProcessingJobs = 1,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    Map<String, List<TimeRange>>? scheduleMap;
    if (json['working_hours'] != null && json['working_hours'] is Map) {
      scheduleMap = {};
      (json['working_hours'] as Map<String, dynamic>).forEach((key, val) {
        if (val is List) {
          scheduleMap![key] = val.map((x) {
            // Handle [[start, end], ...] or similar structures
            // Expected from backend: [ ["09:00", "17:00"], ... ] (24hr)
            // or [ ["09:00 AM", "05:00 PM"] ] (12hr)
            if (x is List && x.length >= 2) {
              String start = x[0].toString();
              String end = x[1].toString();
              // Convert 24-hour format to 12-hour if needed
              start = _format24To12(start);
              end = _format24To12(end);
              return TimeRange(start: start, end: end);
            }
            return TimeRange(start: "09:00 AM", end: "06:00 PM"); // fallback
          }).toList();
        }
      });
    }

    return Provider(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      serviceIds: (json['services'] as List?)?.map((e) => e as int).toList(),
      schedule: scheduleMap,
      maxConcurrentProcessingJobs:
          json['max_concurrent_processing_jobs'] as int? ?? 1,
    );
  }

  /// Convert 24-hour format (HH:mm) to 12-hour format (hh:mm AM/PM)
  /// If already in 12-hour format, returns as-is
  static String _format24To12(String time) {
    // Check if already in 12-hour format (contains AM/PM)
    if (time.contains('AM') || time.contains('PM')) {
      return time;
    }

    // Parse 24-hour format
    final parts = time.split(':');
    if (parts.length != 2) return time;

    try {
      final hour = int.parse(parts[0]);
      final minute = parts[1];

      if (hour < 0 || hour > 23) return time;

      final isPM = hour >= 12;
      int displayHour = hour;
      if (hour == 0) {
        displayHour = 12; // 00:xx becomes 12:xx AM
      } else if (hour > 12) {
        displayHour = hour - 12; // 13:xx becomes 1:xx PM
      }

      final period = isPM ? 'PM' : 'AM';
      return '$displayHour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> workingHours = {};
    schedule?.forEach((k, v) {
      workingHours[k] = v.map((r) => [r.start, r.end]).toList();
    });

    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'bio': bio,
      'services': serviceIds,
      'working_hours': workingHours,
      'max_concurrent_processing_jobs': maxConcurrentProcessingJobs,
    };
  }

  /// Creates the "Any Available" placeholder provider
  static Provider anyAvailable() =>
      Provider(id: 0, name: 'Any Available', profileImage: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Provider && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
