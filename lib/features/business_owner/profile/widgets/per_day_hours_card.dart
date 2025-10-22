import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/busines_owner_profile_controller.dart';

class PerDayHoursCard extends StatelessWidget {
  final BusinessOwnerProfileController c;
  final bool disabled;
  const PerDayHoursCard({required this.c, this.disabled = false});

  static const _days = [
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ensure BH has all days
      for (final d in _days) {
        c.businessHours.putIfAbsent(d.toLowerCase(), () => []);
      }
      return Card(
        color: Colors.grey.shade100,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Per-day Business Hours',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._days.map((d) {
                final key = d.toLowerCase();
                final ranges = c.businessHours[key]!;
                final isOpen = ranges.isNotEmpty;

                return Opacity(
                  opacity: disabled ? 0.5 : 1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Switch(
                            value: isOpen,
                            onChanged: disabled ? null : (val) {
                              if (val) {
                                c.businessHours[key] = [Range(
                                  c.startTime.value.isNotEmpty ? c.startTime.value : '09:00 AM',
                                  c.endTime.value.isNotEmpty   ? c.endTime.value   : '06:00 PM',
                                )];
                              } else {
                                c.businessHours[key] = [];
                              }
                              c.businessHours.refresh();
                              c.syncOpenDaysFromBH();
                            },
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            for (int i = 0; i < ranges.length; i++)
                              _RangeRow(
                                label: 'Interval ${i+1}',
                                value: ranges[i],
                                onChanged: disabled ? null : (newRange) {
                                  final list = [...c.businessHours[key]!];
                                  list[i] = newRange;
                                  c.businessHours[key] = list;
                                  c.businessHours.refresh();
                                },
                                onDelete: disabled ? null : () {
                                  final list = [...c.businessHours[key]!];
                                  list.removeAt(i);
                                  c.businessHours[key] = list;
                                  c.businessHours.refresh();
                                  c.syncOpenDaysFromBH();
                                },
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: disabled ? null : () {
                                  final list = [...c.businessHours[key]!];
                                  // basic cap to 3 intervals to avoid spam
                                  if (list.length >= 3) {
                                    Get.snackbar('Limit reached', 'Max 3 intervals per day');
                                    return;
                                  }
                                  list.add(Range('01:00 PM','02:00 PM'));
                                  c.businessHours[key] = list;
                                  c.businessHours.refresh();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add interval'),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

class _RangeRow extends StatelessWidget {
  final String label;
  final Range value;
  final ValueChanged<Range>? onChanged;
  final VoidCallback? onDelete;

  const _RangeRow({
    required this.label,
    required this.value,
    this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Future<String?> pick(String initial) async {
      final t = await showTimePicker(
        context: context,
        initialTime: _parseOrNow(initial),
      );
      if (t == null) return null;
      return TimeOfDay(hour: t.hour, minute: t.minute).format(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 2,
            child: InkWell(
              onTap: onChanged == null ? null : () async {
                final s = await pick(value.start);
                if (s != null) onChanged!(value.copyWith(start: s));
              },
              child: _pill('Start', value.start),
            ),
          ),
          SizedBox(
            width: (MediaQuery.of(context).size.width - 64) / 2,
            child: InkWell(
              onTap: onChanged == null ? null : () async {
                final e = await pick(value.end);
                if (e != null) onChanged!(value.copyWith(end: e));
              },
              child: _pill('End', value.end),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _pill(String title, String v) {
    return Container(
      // was: height: 48,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, color: Colors.grey, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // <- important
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                const SizedBox(height: 2),
                Text(
                  v,
                  style: const TextStyle(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

}

TimeOfDay _parseOrNow(String s) {
  try {
    final reg = RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false);
    final m = reg.firstMatch(s.trim());
    if (m != null) {
      var hour = int.parse(m.group(1)!);
      final minute = int.parse(m.group(2)!);
      final ampm = m.group(3)!.toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
  } catch (_) {}
  return TimeOfDay.now();
}

