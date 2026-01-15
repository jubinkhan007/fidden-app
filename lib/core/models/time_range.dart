import 'package:flutter/foundation.dart';

/// Simple container for a time slot (start, end) in "hh:mm AM/PM" format.
@immutable
class TimeRange {
  final String start; // e.g. "09:00 AM"
  final String end; // e.g. "06:00 PM"

  const TimeRange({required this.start, required this.end});

  TimeRange copyWith({String? start, String? end}) =>
      TimeRange(start: start ?? this.start, end: end ?? this.end);

  /// Helper to convert from legacy Tuple or other formats if needed
  factory TimeRange.fromPair(String start, String end) =>
      TimeRange(start: start, end: end);

  Map<String, String> toJson() => {'start': start, 'end': end};
}
