import 'package:intl/intl.dart';
import 'package:fidden/core/utils/timezone_helper.dart';

/// Default timezone to use when shop_timezone is not available
/// This should match where most shops are located
const String _defaultShopTimezone = 'America/New_York';

/// Extract wall-clock time from ISO string, ignoring timezone
/// This preserves the time as-is from the string (e.g., 09:00 stays 09:00)
Map<String, int>? _parts(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return {
    'y': int.parse(m.group(1)!),
    'M': int.parse(m.group(2)!),
    'd': int.parse(m.group(3)!),
    'H': int.parse(m.group(4)!),
    'm': int.parse(m.group(5)!),
  };
}

/// Format time from ISO string, strictly using the wall-clock time in the string.
/// Does NOT perform any timezone conversion.
/// e.g. "2023-10-10T15:00:00" -> "03:00 PM" regardless of device or shop timezone.
String formatWallClockTime(String iso) {
  final p = _parts(iso);
  if (p == null) return '—';
  var h = p['H']!, m = p['m']!;
  final ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  if (h == 0) h = 12;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
}

/// Format date from ISO string (ignores timezone, uses wall-clock date)
String formatApiDate(String iso) {
  // Try timezone conversion first with default timezone
  return formatApiDateInTimezone(iso, _defaultShopTimezone);
}

/// Format time from ISO string (ignores timezone, uses wall-clock time)
String formatApiTime(String iso) {
  // Try timezone conversion first with default timezone
  return formatApiTimeInTimezone(iso, _defaultShopTimezone);
}

/// Format date from ISO string using shop's timezone
/// Use this when API sends UTC times and you need to display in shop's local time
String formatApiDateInTimezone(String iso, String? shopTimezone) {
  if (iso.isEmpty) return '—';
  final tz = shopTimezone ?? _defaultShopTimezone;
  try {
    // Parse as UTC DateTime
    final utc = DateTime.parse(iso).toUtc();
    // Convert to shop timezone
    final shopLocal = TimezoneHelper.toTimezone(utc, tz);
    return DateFormat('EEE, d MMM yyyy').format(shopLocal);
  } catch (_) {
    // Fallback to wall-clock parsing
    final p = _parts(iso);
    if (p == null) return '—';
    final d = DateTime(p['y']!, p['M']!, p['d']!);
    return DateFormat('EEE, d MMM yyyy').format(d);
  }
}

/// Format time from ISO string using shop's timezone
/// Use this when API sends UTC times and you need to display in shop's local time
String formatApiTimeInTimezone(String iso, String? shopTimezone) {
  if (iso.isEmpty) return '—';
  final tz = shopTimezone ?? _defaultShopTimezone;
  try {
    // Parse as UTC DateTime
    final utc = DateTime.parse(iso).toUtc();
    // Convert to shop timezone and format
    return TimezoneHelper.formatInTimezone(utc, tz);
  } catch (_) {
    // Fallback to wall-clock parsing
    final p = _parts(iso);
    if (p == null) return '—';
    var h = p['H']!, m = p['m']!;
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
  }
}
