import 'package:fidden/core/models/time_range.dart';
import 'package:flutter/material.dart';

class ProviderScheduleEditor extends StatefulWidget {
  final Map<String, List<TimeRange>> initialSchedule;
  final ValueChanged<Map<String, List<TimeRange>>> onChanged;

  const ProviderScheduleEditor({
    super.key,
    required this.initialSchedule,
    required this.onChanged,
  });

  @override
  State<ProviderScheduleEditor> createState() => _ProviderScheduleEditorState();
}

class _ProviderScheduleEditorState extends State<ProviderScheduleEditor> {
  late Map<String, List<TimeRange>> _schedule;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    // Deep copy to avoid mutating parent state directly without callback
    _schedule = {};
    for (var d in _days) {
      final key = d.toLowerCase();
      if (widget.initialSchedule.containsKey(key)) {
        _schedule[key] = List.from(widget.initialSchedule[key]!);
      } else {
        _schedule[key] = [];
      }
    }
  }

  void _notify() {
    widget.onChanged(_schedule);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _days.map((dayName) {
        final key = dayName.toLowerCase();
        final ranges = _schedule[key] ?? [];
        final isOpen = ranges.isNotEmpty;

        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Header Row (Day + Switch)
                Row(
                  children: [
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isOpen,
                      onChanged: (val) {
                        if (val) {
                          // Add default 9-5
                          _schedule[key] = [
                            const TimeRange(start: '09:00 AM', end: '05:00 PM'),
                          ];
                        } else {
                          _schedule[key] = [];
                        }
                        _notify();
                      },
                    ),
                  ],
                ),

                // Ranges Column
                if (isOpen) ...[
                  const Divider(),
                  ...ranges.asMap().entries.map((entry) {
                    final index = entry.key;
                    final range = entry.value;
                    return _RangeEditorRow(
                      range: range,
                      onChanged: (newRange) {
                        ranges[index] = newRange;
                        _notify();
                      },
                      onDelete: () {
                        ranges.removeAt(index);
                        _notify();
                      },
                    );
                  }).toList(),

                  // Add Interval Button
                  if (ranges.length < 3)
                    TextButton.icon(
                      onPressed: () {
                        ranges.add(
                          const TimeRange(start: '01:00 PM', end: '02:00 PM'),
                        );
                        _notify();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Shift Interval'),
                    ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _RangeEditorRow extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onChanged;
  final VoidCallback onDelete;

  const _RangeEditorRow({
    required this.range,
    required this.onChanged,
    required this.onDelete,
  });

  Future<String?> _pickTime(BuildContext context, String current) async {
    // Parse "hh:mm AM"
    TimeOfDay initial = TimeOfDay(hour: 9, minute: 0);
    try {
      final reg = RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false);
      final m = reg.firstMatch(current);
      if (m != null) {
        int h = int.parse(m.group(1)!);
        final min = int.parse(m.group(2)!);
        final ap = m.group(3)!.toUpperCase();
        if (ap == 'PM' && h != 12) h += 12;
        if (ap == 'AM' && h == 12) h = 0;
        initial = TimeOfDay(hour: h, minute: min);
      }
    } catch (_) {}

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      // Format back to "hh:mm AM"
      final local = MaterialLocalizations.of(context);
      return local.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Start Time
          Expanded(
            child: InkWell(
              onTap: () async {
                final t = await _pickTime(context, range.start);
                if (t != null) onChanged(range.copyWith(start: t));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(range.start, textAlign: TextAlign.center),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('to', style: TextStyle(color: Colors.grey)),
          ),
          // End Time
          Expanded(
            child: InkWell(
              onTap: () async {
                final t = await _pickTime(context, range.end);
                if (t != null) onChanged(range.copyWith(end: t));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(range.end, textAlign: TextAlign.center),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
