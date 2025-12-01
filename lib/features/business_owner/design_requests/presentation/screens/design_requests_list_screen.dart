import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/design_request_controller.dart';
import 'design_request_detail_screen.dart';

class DesignRequestsListScreen extends StatelessWidget {
  const DesignRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DesignRequestController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Requests'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.fetchDesignRequests(status: value == 'all' ? null : value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchDesignRequests(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.design_services_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No design requests yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDesignRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return _DesignRequestCard(
                request: request,
                onTap: () => Get.to(() => DesignRequestDetailScreen(request: request)),
              );
            },
          ),
        );
      }),
    );
  }
}

class _DesignRequestCard extends StatelessWidget {
  final dynamic request;
  final VoidCallback onTap;

  const _DesignRequestCard({
    required this.request,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
          child: Icon(
            Icons.design_services,
            color: _getStatusColor(request.status),
          ),
        ),
        title: Text(
          request.user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (request.placement.isNotEmpty) ...[
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(request.placement, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                ],
                Chip(
                  label: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(request.status).withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
