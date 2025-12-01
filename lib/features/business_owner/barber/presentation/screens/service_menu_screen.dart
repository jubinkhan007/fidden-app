import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/service_management_controller.dart';
import 'service_create_screen.dart';

class ServiceMenuScreen extends StatelessWidget {
  const ServiceMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceManagementController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Menu'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchServices(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cut, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No services yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ServiceCreateScreen()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Service'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchServices(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.services.length,
            itemBuilder: (context, index) {
              final service = controller.services[index];
              return _ServiceCard(
                service: service,
                controller: controller,
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ServiceCreateScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final dynamic service;
  final ServiceManagementController controller;

  const _ServiceCard({
    required this.service,
    required this.controller,
  });

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this service?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'This action cannot be undone. Future bookings may be affected.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteService(service['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = service['is_active'] ?? true;
    final String name = service['name'] ?? service['title'] ?? 'Unnamed Service';
    final String description = service['description'] ?? '';
    final double price = (service['price'] is String)
        ? double.tryParse(service['price']) ?? 0.0
        : (service['price'] as num?)?.toDouble() ?? 0.0;
    final int duration = service['duration'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.blue[100] : Colors.grey[300],
          child: Icon(Icons.cut, color: isActive ? Colors.blue : Colors.grey),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.grey[600]),
                Text('\$${price.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$duration min'),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(isActive ? Icons.visibility_off : Icons.visibility, size: 20),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
              onTap: () => controller.toggleServiceStatus(service['id'], isActive),
            ),
            const PopupMenuItem(
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
              value: 'delete',
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
        ),
      ),
    );
  }
}
