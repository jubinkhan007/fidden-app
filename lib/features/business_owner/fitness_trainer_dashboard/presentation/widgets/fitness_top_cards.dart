import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';

class FitnessTopCards extends StatelessWidget {
  const FitnessTopCards({super.key});

  @override
  Widget build(BuildContext context) {
    // If controller not found (e.g. testing in isolation), handle gracefully or Get.put
    final controller = Get.isRegistered<FitnessTrainerDashboardController>()
        ? Get.find<FitnessTrainerDashboardController>()
        : Get.put(FitnessTrainerDashboardController());

    return Obx(() {
      final data = controller.dashboard.value;

      return Row(
        children: [
          Expanded(
            child: _buildCard(
              title: 'Weekly Bookings',
              value: data?.schedule.total.toString() ?? '0',
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF6366F1),
              isLoading: controller.isLoading.value,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(
              title: 'Revenue',
              value: '\$${data?.revenue.paidTotal.toStringAsFixed(0) ?? '0'}',
              icon: Icons.attach_money_rounded,
              color: const Color(0xFF10B981),
              isLoading: controller.isLoading.value,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(
              title: 'Active Pkgs',
              value: data?.packages.activeCount.toString() ?? '0',
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFFF59E0B),
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE2E8F0).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 40,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
