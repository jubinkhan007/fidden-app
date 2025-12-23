import 'package:fidden/core/utils/timezone_helper.dart';
import 'package:intl/intl.dart';

/// Centralized helper for displaying appointment times consistently
///
/// USE THIS EVERYWHERE for displaying appointment times to ensure:
/// - Pros see times in their shop's timezone
/// - Clients see times in their device's local timezone
class TimeDisplayHelper {
  /// Format appointment time for BUSINESS OWNER (use shop timezone)
  ///
  /// [isoUtc] - ISO 8601 time string (should be UTC with Z suffix)
  /// [shopTimezone] - IANA timezone ID (e.g., "America/New_York")
  ///
  /// Returns formatted time like "10:30 AM"
  static String formatTimeForPro(String? isoUtc, String? shopTimezone) {
    if (isoUtc == null || isoUtc.isEmpty) return '--:--';

    try {
      final dt = DateTime.parse(isoUtc);
      return TimezoneHelper.formatInTimezone(dt.toUtc(), shopTimezone);
    } catch (e) {
      return '--:--';
    }
  }

  /// Format appointment time for CLIENT (use device timezone)
  ///
  /// [isoUtc] - ISO 8601 time string (should be UTC with Z suffix)
  ///
  /// Returns formatted time like "10:30 AM" in device's local time
  static String formatTimeForClient(String? isoUtc) {
    if (isoUtc == null || isoUtc.isEmpty) return '--:--';

    try {
      final dt = DateTime.parse(isoUtc).toLocal();
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return '--:--';
    }
  }

  /// Format appointment date for BUSINESS OWNER (use shop timezone)
  ///
  /// [isoUtc] - ISO 8601 time string (should be UTC with Z suffix)
  /// [shopTimezone] - IANA timezone ID (e.g., "America/New_York")
  /// [format] - Date format pattern (default: "MMM d, yyyy")
  ///
  /// Returns formatted date like "Jan 15, 2025"
  static String formatDateForPro(
    String? isoUtc,
    String? shopTimezone, {
    String format = 'MMM d, yyyy',
  }) {
    if (isoUtc == null || isoUtc.isEmpty) return '--';

    try {
      final dt = DateTime.parse(isoUtc).toUtc();
      final tzDt = TimezoneHelper.toTimezone(dt, shopTimezone);
      return DateFormat(format).format(tzDt);
    } catch (e) {
      return '--';
    }
  }

  /// Format appointment date for CLIENT (use device timezone)
  ///
  /// [isoUtc] - ISO 8601 time string
  /// [format] - Date format pattern (default: "MMM d, yyyy")
  ///
  /// Returns formatted date like "Jan 15, 2025" in device's local time
  static String formatDateForClient(
    String? isoUtc, {
    String format = 'MMM d, yyyy',
  }) {
    if (isoUtc == null || isoUtc.isEmpty) return '--';

    try {
      final dt = DateTime.parse(isoUtc).toLocal();
      return DateFormat(format).format(dt);
    } catch (e) {
      return '--';
    }
  }

  /// Format full date and time for BUSINESS OWNER
  ///
  /// Returns formatted string like "Jan 15, 2025 at 10:30 AM"
  static String formatDateTimeForPro(String? isoUtc, String? shopTimezone) {
    if (isoUtc == null || isoUtc.isEmpty) return '--';

    final date = formatDateForPro(isoUtc, shopTimezone);
    final time = formatTimeForPro(isoUtc, shopTimezone);
    return '$date at $time';
  }

  /// Format full date and time for CLIENT
  ///
  /// Returns formatted string like "Jan 15, 2025 at 10:30 AM"
  static String formatDateTimeForClient(String? isoUtc) {
    if (isoUtc == null || isoUtc.isEmpty) return '--';

    final date = formatDateForClient(isoUtc);
    final time = formatTimeForClient(isoUtc);
    return '$date at $time';
  }

  /// Format relative day description for appointments
  ///
  /// Returns "Today", "Tomorrow", "Yesterday", or the weekday name
  static String formatRelativeDay(
    String? isoUtc,
    String? shopTimezone, {
    bool isForPro = true,
  }) {
    if (isoUtc == null || isoUtc.isEmpty) return '--';

    try {
      final DateTime appointmentDate;
      final DateTime today;

      if (isForPro && shopTimezone != null) {
        appointmentDate = TimezoneHelper.toTimezone(
          DateTime.parse(isoUtc).toUtc(),
          shopTimezone,
        );
        today = TimezoneHelper.toTimezone(DateTime.now().toUtc(), shopTimezone);
      } else {
        appointmentDate = DateTime.parse(isoUtc).toLocal();
        today = DateTime.now();
      }

      final appointmentDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      final todayDay = DateTime(today.year, today.month, today.day);

      final difference = appointmentDay.difference(todayDay).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Tomorrow';
      if (difference == -1) return 'Yesterday';
      if (difference > 1 && difference <= 7)
        return DateFormat('EEEE').format(appointmentDate);

      return DateFormat('MMM d').format(appointmentDate);
    } catch (e) {
      return '--';
    }
  }
}
