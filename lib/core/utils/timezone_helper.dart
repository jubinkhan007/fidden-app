import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// Helper class for timezone operations
class TimezoneHelper {
  static bool _initialized = false;

  /// Initialize timezone database - call once at app startup
  static void ensureInitialized() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  /// List of common US timezones with display labels
  static const List<Map<String, String>> usTimezones = [
    {'value': 'America/New_York', 'label': 'Eastern Time (ET)'},
    {'value': 'America/Chicago', 'label': 'Central Time (CT)'},
    {'value': 'America/Denver', 'label': 'Mountain Time (MT)'},
    {'value': 'America/Los_Angeles', 'label': 'Pacific Time (PT)'},
    {'value': 'America/Anchorage', 'label': 'Alaska Time (AKT)'},
    {'value': 'Pacific/Honolulu', 'label': 'Hawaii Time (HST)'},
  ];

  /// Get device's IANA timezone, fallback to Eastern if detection fails
  static Future<String> getDeviceTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      return timezone;
    } catch (e) {
      return 'America/New_York';
    }
  }

  /// Get display label for a timezone value
  /// Returns the IANA value if no matching label is found
  static String getLabel(String value) {
    final match = usTimezones.firstWhere(
      (tz) => tz['value'] == value,
      orElse: () => {'label': value},
    );
    return match['label']!;
  }

  /// Check if a timezone value is in our supported list
  static bool isSupported(String value) {
    return usTimezones.any((tz) => tz['value'] == value);
  }

  /// Get the closest matching US timezone for a detected timezone
  /// Falls back to Eastern if no match found
  static String getNearestUsTimezone(String detected) {
    if (isSupported(detected)) {
      return detected;
    }
    // Fallback to Eastern if detected timezone isn't in our list
    return 'America/New_York';
  }

  /// Convert UTC DateTime to a specific timezone and format as "h:mm a"
  /// [utc] - the UTC DateTime to convert
  /// [tzId] - IANA timezone ID (e.g., "America/New_York")
  static String formatInTimezone(DateTime utc, String? tzId) {
    ensureInitialized();
    
    // Default to Eastern if no timezone provided
    final tzIdSafe = tzId?.isNotEmpty == true ? tzId! : 'America/New_York';
    
    try {
      final location = tz.getLocation(tzIdSafe);
      final tzTime = tz.TZDateTime.from(utc.toUtc(), location);
      return DateFormat('h:mm a').format(tzTime);
    } catch (e) {
      // Fallback to local time if timezone lookup fails
      return DateFormat('h:mm a').format(utc.toLocal());
    }
  }

  /// Convert UTC DateTime to a specific timezone
  /// Returns TZDateTime for further manipulation
  static DateTime toTimezone(DateTime utc, String? tzId) {
    ensureInitialized();
    
    final tzIdSafe = tzId?.isNotEmpty == true ? tzId! : 'America/New_York';
    
    try {
      final location = tz.getLocation(tzIdSafe);
      final utcTime = utc.toUtc();
      final tzTime = tz.TZDateTime.from(utcTime, location);
      debugPrint('🕐 TZ Convert: UTC=$utcTime → $tzIdSafe → $tzTime (hour=${tzTime.hour})');
      return tzTime;
    } catch (e) {
      debugPrint('🕐 TZ Convert FAILED: $e, falling back to local');
      return utc.toLocal();
    }
  }
}

