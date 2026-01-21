import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
import '../../model/fitness_trainer_models.dart';

class NutritionPlansScreen extends StatelessWidget {
  const NutritionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FitnessTrainerDashboardController>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.loadNutritionPlans(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Plans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, controller),
        label: const Text('New Plan'),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.nutritionPlans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.nutritionPlans.isEmpty) {
          return const Center(child: Text('No nutrition plans found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.nutritionPlans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final plan = controller.nutritionPlans[index];
            return Card(
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  plan.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (plan.notes.isNotEmpty)
                      Text(
                        plan.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (plan.externalLinks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${plan.externalLinks.length} Links attached',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _showEditDialog(context, controller, plan: plan),
                ),
                onLongPress: () => _confirmDelete(context, controller, plan.id),
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FitnessTrainerDashboardController controller,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text(
          'Are you sure you want to delete this nutrition plan?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteNutritionPlan(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    FitnessTrainerDashboardController controller, {
    NutritionPlanModel? plan,
  }) {
    final isEdit = plan != null;
    final titleCtrl = TextEditingController(text: plan?.title ?? '');
    final notesCtrl = TextEditingController(text: plan?.notes ?? '');
    final linksCtrl = TextEditingController(
      text: plan?.externalLinks.join('\n') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Plan' : 'New Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes/Details'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linksCtrl,
                decoration: const InputDecoration(
                  labelText: 'External Links (one per line)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final links = linksCtrl.text
                  .split('\n')
                  .where((l) => l.trim().isNotEmpty)
                  .map((l) => l.trim())
                  .toList();

              final data = {
                'title': titleCtrl.text,
                'notes': notesCtrl.text,
                'external_links': links,
              };

              if (isEdit) {
                controller.updateNutritionPlan(plan.id, data);
              } else {
                controller.createNutritionPlan(data);
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
