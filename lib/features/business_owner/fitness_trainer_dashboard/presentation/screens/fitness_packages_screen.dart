import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/fitness_trainer_dashboard_controller.dart';
import '../../model/fitness_trainer_models.dart';
import 'package:intl/intl.dart';

class FitnessPackagesScreen extends StatelessWidget {
  const FitnessPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FitnessTrainerDashboardController>();

    // Load packages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPackages();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Packages')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, controller),
        label: const Text('Add Package'),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.packages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.packages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No packages found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.packages.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pkg = controller.packages[index];
            return _buildPackageCard(context, controller, pkg);
          },
        );
      }),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    FitnessTrainerDashboardController controller,
    FitnessPackageModel pkg,
  ) {
    final isExpired =
        pkg.expiresAt != null && pkg.expiresAt!.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Text(
              '${pkg.totalSessions} Sessions',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pkg.isActive ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pkg.isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  color: pkg.isActive ? Colors.green[800] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Price: \$${pkg.price}'),
            const SizedBox(height: 4),
            Text('Remaining: ${pkg.sessionsRemaining} / ${pkg.totalSessions}'),
            if (pkg.expiresAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(pkg.expiresAt!)}',
                style: TextStyle(
                  color: isExpired ? Colors.red : Colors.grey[600],
                ),
              ),
            ],
            if (pkg.customer != null) ...[
              const SizedBox(height: 4),
              Text('Customer ID: ${pkg.customer}'),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context, controller, pkg: pkg);
            } else if (value == 'delete') {
              controller.deletePackage(pkg.id);
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    FitnessTrainerDashboardController controller, {
    FitnessPackageModel? pkg,
  }) {
    final isEdit = pkg != null;

    final sessionsController = TextEditingController(
      text: pkg?.totalSessions.toString() ?? '',
    );
    final remainingController = TextEditingController(
      text: pkg?.sessionsRemaining.toString() ?? '',
    );
    final priceController = TextEditingController(text: pkg?.price ?? '');
    final customerController = TextEditingController(
      text: pkg?.customer?.toString() ?? '',
    );

    bool isActive = pkg?.isActive ?? true;
    DateTime? expiresAt = pkg?.expiresAt;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Package' : 'New Package'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID (Target User)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: sessionsController,
                    decoration: const InputDecoration(
                      labelText: 'Total Sessions',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: remainingController,
                    decoration: const InputDecoration(
                      labelText: 'Sessions Remaining',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Expiry Date'),
                    subtitle: Text(
                      expiresAt != null
                          ? DateFormat('yyyy-MM-dd').format(expiresAt!)
                          : 'No expiry set',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            expiresAt ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 2),
                        ),
                      );
                      if (date != null) {
                        setState(() => expiresAt = date);
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
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
                  final data = {
                    'total_sessions':
                        int.tryParse(sessionsController.text) ?? 0,
                    'sessions_remaining':
                        int.tryParse(remainingController.text) ?? 0,
                    'price': priceController.text,
                    'is_active': isActive,
                    if (expiresAt != null)
                      'expires_at': expiresAt!.toIso8601String(),
                    if (customerController.text.isNotEmpty)
                      'customer': int.tryParse(customerController.text),
                  };

                  if (isEdit) {
                    controller.updatePackage(pkg.id, data);
                  } else {
                    // For create, default sessions remaining to total if empty
                    if (data['sessions_remaining'] == 0 &&
                        data['total_sessions'] != 0) {
                      data['sessions_remaining'] = data['total_sessions'];
                    }
                    controller.createPackage(data);
                  }
                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Save' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
