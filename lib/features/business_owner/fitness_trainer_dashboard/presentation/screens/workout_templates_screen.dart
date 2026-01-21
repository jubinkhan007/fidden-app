import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
import '../../model/fitness_trainer_models.dart';

class WorkoutTemplatesScreen extends StatelessWidget {
  const WorkoutTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FitnessTrainerDashboardController>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.loadTemplates(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Templates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, controller),
        label: const Text('New Template'),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.templates.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.templates.isEmpty) {
          return const Center(child: Text('No workout templates found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return _buildTemplateCard(context, controller, template);
          },
        );
      }),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    FitnessTrainerDashboardController controller,
    WorkoutTemplateModel template,
  ) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          template.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          template.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exercises:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...template.exercises.map((ex) {
                  final name = ex['name'] ?? 'Exercise';
                  final sets = ex['sets'] ?? '-';
                  final reps = ex['reps'] ?? '-';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $name: $sets sets x $reps reps'),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditDialog(
                        context,
                        controller,
                        template: template,
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.deleteTemplate(template.id),
                      icon: const Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    FitnessTrainerDashboardController controller, {
    WorkoutTemplateModel? template,
  }) {
    final isEdit = template != null;
    final titleCtrl = TextEditingController(text: template?.title ?? '');
    final descCtrl = TextEditingController(text: template?.description ?? '');

    // Simple JSON editor for exercises for now to keep UX simple as requested
    // A proper UI would allow adding rows dynamically
    final exercisesCtrl = TextEditingController(
      text: template != null
          ? const JsonEncoder.withIndent('  ').convert(template.exercises)
          : '[{"name": "Squats", "sets": 3, "reps": 12}]',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Template' : 'New Template'),
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
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                'Exercises (JSON format):',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              TextField(
                controller: exercisesCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '[{"name": "Exercise", "sets": 3, "reps": 10}]',
                ),
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
              try {
                final exercises = jsonDecode(exercisesCtrl.text);
                if (exercises is! List) throw Exception('Must be a list');

                final data = {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'exercises': exercises,
                };

                if (isEdit) {
                  controller.updateTemplate(template.id, data);
                } else {
                  controller.createTemplate(data);
                }
                Navigator.pop(context);
              } catch (e) {
                Get.snackbar('Error', 'Invalid JSON format for exercises');
              }
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
