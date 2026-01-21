import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
import '../widgets/fitness_top_cards.dart';
import '../widgets/fitness_schedule_preview.dart';
import '../widgets/revenue_tracker_preview.dart';
import '../widgets/fitness_action_grid.dart';

class FitnessTrainerDashboardScreen extends StatelessWidget {
  final int shopId;
  const FitnessTrainerDashboardScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FitnessTrainerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboard(),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.dashboard.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              const FitnessTopCards(),
              const SizedBox(height: 24),
              const RevenueTrackerPreview(),
              const SizedBox(height: 32),
              const FitnessSchedulePreview(),
              const SizedBox(height: 32),
              const FitnessActionGrid(), // Includes Cancellation Toggle
              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trainer Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'Monitor your weekly performance and clients.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
