import 'package:fidden/features/business_owner/calendar/data/calendar_event_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarEventCard extends StatelessWidget {
  final CalendarEventModel event;

  const CalendarEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Determine Color based on CalendarStatus
    final statusColor = _getStatusColor(
      event.calendarStatus.toCalendarStatus(),
    );
    final isBlocked =
        event.eventType == "blocked" ||
        event.calendarStatus.toCalendarStatus() == CalendarStatus.BLOCKED;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Border Color Strip
            Container(width: 6, color: statusColor),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Time & Badges
                    Row(
                      children: [
                        _buildTimeDisplay(),
                        const Spacer(),
                        _buildProviderName(),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title / Description
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Additional Info (Customer/Service/Note)
                    if (isBlocked) ...[
                      if (event.blockedReason != null)
                        Text(
                          "Reason: ${event.blockedReason}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      if (event.note != null)
                        Text(
                          event.note!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ] else ...[
                      if (event.customer != null)
                        Text(
                          "Client: ${event.customer!.name}",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      if (event.service != null)
                        Text(
                          "Service: ${event.service!.title}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                    ],

                    const SizedBox(height: 8),
                    // Badges Row
                    if (event.badges.isNotEmpty)
                      Wrap(spacing: 4, runSpacing: 4, children: _buildBadges()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    // Raw strings from backend: "2026-01-20T10:00:00-05:00"
    // We want to extract "10:00 AM - 11:00 AM" WITHOUT converting to local device time.
    // The backend string has the offset for the shop.
    // The safest way is to parse it, and format it, ensuring we don't accidentally shift it.

    // DateTime.parse() creates a local or UTC date depending on the string.
    // "2026-01-20T10:00:00-05:00" -> DateTime object.
    // If we just use DateFormat.jm().format(dt), it might use local time.

    // BETTER APPROACH:
    // Extract the time part directly from string if ISO format is strict.
    // Or use DateTime.parse and strictly format it.
    //
    // Let's try DateTime.parse() which usually preserves "moment in time".
    // but .hour / .minute are relative closer to the offset if parsed correctly.
    // However, Dart DateTime is either UTC or Local. It doesn't hold arbitrary offsets cleanly.

    // Manual String Parsing for Safety (Per requirements):
    // "2026-01-20T10:00:00-05:00"
    try {
      final t1 = _extractTime(event.startAt);
      final t2 = _extractTime(event.endAt);
      return Text(
        "$t1 - $t2",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      );
    } catch (e) {
      return Text(
        "${event.startAt} - ${event.endAt}", // Fallback
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
    }
  }

  String _extractTime(String isoString) {
    // Remove offset part first to safely parse the "Wall Time" components
    // Regex or simple split 'T'
    if (!isoString.contains('T')) return isoString;

    // 2026-01-20T10:00:00-05:00
    // Split by T -> 10:00:00-05:00
    // final timePartFull = isoString.split('T')[1];

    // Remove the offset part (+/-)
    // Find index of + or - after the first char (since first char could be ?)
    // actually standard ISO time part is HH:mm:ss...

    // Simpler: DateTime.parse(isoString) converts to Local or UTC.
    // If shop is NY (-5) and user is CA (-8),
    // DateTime.parse("...-05:00") -> becomes "user local time".
    // THIS IS WHAT WE WANT TO AVOID.

    // We want the "Face Value" of the time.
    // So we should ignore the offset for display purposes if we want to show "Shop Time".

    // Strategy: Parse the string up to the offset indicator.
    // "2026-01-20T10:00:00"

    final regex = RegExp(r'T(\d{2}:\d{2})');
    final match = regex.firstMatch(isoString);
    if (match != null) {
      // "10:00" (24h)
      // Convert to AM/PM manually or via dummy date
      final rawTime = match.group(1)!;
      final parts = rawTime.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);

      final dt = DateTime(2022, 1, 1, h, m);
      // Format
      final timeStr = TimeOfDay.fromDateTime(dt).format(Get.context!);
      // TimeOfDay.format respects 24h/12h system setting of device?
      // Usually "10:00 AM".

      return timeStr;
    }
    return isoString;
  }

  Widget _buildProviderName() {
    if (event.provider == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        event.provider!.name,
        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
      ),
    );
  }

  List<Widget> _buildBadges() {
    // Order: DEP_DUE, FORMS, PAID, NEW
    final badges = <Widget>[];

    // Helper
    void addBadge(String text, Color bg, Color fg) {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      );
    }

    // Provided list
    final bList = event.badges.map((e) => e.toUpperCase()).toList();

    // DEP_DUE
    if (bList.contains("DEP_DUE")) {
      addBadge("DEP DUE", Colors.orange[100]!, Colors.orange[900]!);
    }
    // FORMS
    if (bList.contains("FORMS")) {
      addBadge("FORMS", Colors.purple[100]!, Colors.purple[900]!);
    }
    // PAID
    if (bList.contains("PAID")) {
      addBadge("PAID", Colors.green[100]!, Colors.green[900]!);
    }
    // NEW
    if (bList.contains("NEW")) {
      addBadge("NEW", Colors.blue[100]!, Colors.blue[900]!);
    }
    // BAL_DUE
    if (bList.contains("BAL_DUE")) {
      addBadge("BAL DUE", Colors.amber[100]!, Colors.amber[900]!);
    }

    // NEW: Session Type Tag (CLASS | 1:1) from event.sessionType
    if (event.sessionType != null) {
      final type = event.sessionType!.toLowerCase();
      if (type == 'class') {
        addBadge("CLASS", Colors.teal[50]!, Colors.teal[800]!);
      } else if (type == '1to1' || type == '1:1') {
        addBadge("1:1", Colors.indigo[50]!, Colors.indigo[800]!);
      }
    }

    return badges;
  }

  Color _getStatusColor(CalendarStatus status) {
    switch (status) {
      case CalendarStatus.CONFIRMED:
        return Colors.green;
      case CalendarStatus.PENDING:
        return Colors.amber;
      case CalendarStatus.COMPLETED:
        return Colors.grey;
      case CalendarStatus.CANCELED:
        return Colors.red;
      case CalendarStatus.NO_SHOW:
        return Colors.black;
      case CalendarStatus.BLOCKED:
        return Colors.grey.withOpacity(0.5); // Striped look replacement
      default:
        return Colors.blue;
    }
  }
}
