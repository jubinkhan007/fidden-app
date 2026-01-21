import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
// import 'package:fidden/features/business_owner/calendar/data/calendar_event_model.dart';
// Temporarily commenting out model import to avoid errors if model isn't ready/found
// We will mock the display for now or use dynamic if needed, but best to use real data.

class FitnessSchedulePreview extends StatelessWidget {
  const FitnessSchedulePreview({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll just show a static placeholder or basic text
    // since the controller logic for *list* of events wasn't strictly detailed
    // in the "dashboard overview" endpoint (only counts).
    // If we want real events, we'd need to fetch them.
    // The requirement said "Weekly Schedule summary (classes vs 1:1 sessions)"
    // which is covered by the numbers in TopCards.
    // However, the original UI had a list. Let's keep a simple list placeholder
    // or fetch if we have the data.

    // The dashboard response only gives counts.
    // To show actual events, we might need to use the CalendarController or fetch separately.
    // For this task logic, I will implement a visual summary of the COUNTS specifically
    // properly formatted as a "Preview" card.

    final controller = Get.find<FitnessTrainerDashboardController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final schedule = controller.dashboard.value?.schedule;
            final classes = schedule?.classes ?? 0;
            final oneToOne = schedule?.oneToOne ?? 0;
            final total = schedule?.total ?? 0;

            if (total == 0) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No sessions scheduled this week.')),
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Classes',
                    classes.toString(),
                    Colors.purple,
                    Icons.groups_rounded,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildStatItem(
                    '1:1 Sessions',
                    oneToOne.toString(),
                    Colors.orange,
                    Icons.person_rounded,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}
