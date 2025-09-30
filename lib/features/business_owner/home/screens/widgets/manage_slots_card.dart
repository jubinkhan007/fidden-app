import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/owner_service_slot_controller.dart';

class ManageSlotsCard extends StatelessWidget {
  const ManageSlotsCard({required this.ctrl});
  final OwnerServiceSlotsController ctrl;

  @override
  Widget build(BuildContext context) {
    final todPretty = DateFormat('h:mm a');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Manage Time Slots',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                  // Optional: show "Unsaved" chip when there are local changes
                  if (ctrl.hasUnsavedChanges.value)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text('Unsaved', style: TextStyle(fontSize: 12)),
                    ),
                  IconButton(
                    tooltip: 'Refresh slots',
                    onPressed: ctrl.isLoadingSlots.value ? null : ctrl.refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Toggling a time disables/enables it for ALL dates.\n"
                    "New services won’t show slots until 12:00 AM next day.",
                style: TextStyle(color: Colors.grey.shade600, height: 1.3),
              ),
              const SizedBox(height: 8),

              // Optional: show which date we're displaying
              if (ctrl.fetchedForDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Showing slots for ${ctrl.fetchedForDate.value}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

              if (ctrl.isLoadingSlots.value)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (ctrl.slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No slots found yet. They appear after midnight.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ctrl.slots.map((s) {
                    final startLocal = s.startTimeUtc.toLocal();
                    final hhmm = DateFormat('HH:mm').format(startLocal);
                    final label = todPretty.format(startLocal);
                    final isDisabledByService = s.disabledByService;
                    final isFullyBooked = s.capacityLeft <= 0;
                    final selectable = !isFullyBooked;

                    Color bg;
                    Color fg;
                    BorderSide border;
                    IconData icon;
                    if (isFullyBooked) {
                      bg = Colors.grey.shade200;
                      fg = Colors.grey.shade500;
                      border = BorderSide(color: Colors.grey.shade300);
                      icon = Icons.event_busy;
                    } else if (isDisabledByService) {
                      bg = Colors.red.shade50;
                      fg = Colors.red.shade700;
                      border = const BorderSide(color: Colors.red);
                      icon = Icons.block;
                    } else {
                      bg = Colors.green.shade50;
                      fg = Colors.green.shade700;
                      border = const BorderSide(color: Colors.green);
                      icon = Icons.check_circle;
                    }

                    return InkWell(
                      onTap: selectable ? () => ctrl.toggleDisableFor(hhmm) : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.fromBorderSide(border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 16, color: fg),
                            const SizedBox(width: 6),
                            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        }),
      ),
    );
  }
}
