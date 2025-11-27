import 'package:fidden/features/business_owner/design_requests/controller/design_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesignRequestsTabScreen extends StatelessWidget {
  const DesignRequestsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DesignRequestController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.designRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.designRequests.isEmpty) {
          return const Center(child: Text('No design requests'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.designRequests.length,
          itemBuilder: (context, index) {
            final request = controller.designRequests[index];
            return Card(
              child: ListTile(
                title: Text(request.user.name),
                subtitle: Text('${request.placement} - \${request.description}'),
                trailing: Chip(label: Text(request.status)),
                onTap: () {
                  _showActionDialog(context, controller, request);
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showActionDialog(BuildContext context, DesignRequestController controller, dynamic request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status'),
        actions: [
          TextButton(
            onPressed: () {
              controller.updateStatus(request.id, 'approved');
              Navigator.pop(ctx);
            },
            child: const Text('Approve'),
          ),
          TextButton(
            onPressed: () {
              controller.updateStatus(request.id, 'rejected');
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
