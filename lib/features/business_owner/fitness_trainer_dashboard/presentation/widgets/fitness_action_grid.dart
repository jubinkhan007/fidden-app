import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
import '../screens/fitness_packages_screen.dart';
import '../screens/workout_templates_screen.dart';
import '../screens/nutrition_plans_screen.dart';

class FitnessActionGrid extends StatelessWidget {
  const FitnessActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FitnessTrainerDashboardController>();

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildActionCard(
              title: 'Packages',
              icon: Icons.card_membership_rounded,
              color: Colors.blue,
              onTap: () => Get.to(() => const FitnessPackagesScreen()),
            ),
            _buildActionCard(
              title: 'Workout Templates',
              icon: Icons.fitness_center_rounded,
              color: Colors.orange,
              onTap: () => Get.to(() => const WorkoutTemplatesScreen()),
            ),
            _buildActionCard(
              title: 'Nutrition Plans',
              icon: Icons.restaurant_menu_rounded,
              color: Colors.green,
              onTap: () => Get.to(() => const NutritionPlansScreen()),
            ),
            _buildActionCard(
              title: 'Progress Photos',
              icon: Icons.photo_camera_back_rounded,
              color: Colors.purple,
              onTap: () => Get.snackbar(
                'Coming Soon',
                'Client Progress Photos feature is under development.',
                snackPosition: SnackPosition.BOTTOM,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final settings = controller.dashboard.value?.shopSettings;
          final isEnabled = settings?.cancellationPolicyEnabled ?? false;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.policy_outlined, color: Colors.grey),
                        SizedBox(width: 12),
                        Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isEnabled,
                      onChanged: (val) {
                        // Optimistic update logic handled in controller or verify with loading check
                        if (!controller.isLoading.value) {
                          controller.updateCancellationPolicy(enabled: val);
                        }
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
                if (isEnabled) ...[
                  const Divider(height: 24),
                  InkWell(
                    onTap: () => _showPolicyTextDialog(context, controller),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          settings?.freeCancellationHours != null
                              ? 'Free cancel up to ${settings!.freeCancellationHours}h before'
                              : 'Configure policy details',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicyTextDialog(
    BuildContext context,
    FitnessTrainerDashboardController controller,
  ) {
    // Note: To show current text, we'd ideally need it in the model.
    // For now allowing update only. Use existing Shop controller or fetch if needed.
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Cancellation Policy'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter policy details...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.updateCancellationPolicy(
                  enabled: true,
                  text: textController.text,
                );
              }
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
