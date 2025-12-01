import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/design_request_model.dart';
import '../../controller/design_request_controller.dart';

class DesignRequestDetailScreen extends StatelessWidget {
  final DesignRequest request;

  const DesignRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DesignRequestController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Request Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.person, label: 'Name', value: request.user.name),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.email, label: 'Email', value: request.user.email),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Design Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Design Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text('Description:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(request.description),
                    const SizedBox(height: 12),
                    if (request.placement.isNotEmpty) ...[
                      _InfoRow(icon: Icons.location_on, label: 'Placement', value: request.placement),
                      const SizedBox(height: 8),
                    ],
                    if (request.sizeApprox.isNotEmpty) ...[
                      _InfoRow(icon: Icons.straighten, label: 'Size', value: request.sizeApprox),
                      const SizedBox(height: 8),
                    ],
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Submitted',
                      value: request.createdAt.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(request.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(request.status), color: _getStatusColor(request.status)),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${request.status.toUpperCase()}',
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons (only show if pending)
            if (request.isPending) ...[
              Obx(() => Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => _showRejectDialog(context, controller),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => _showApproveDialog(context, controller),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ],
        ),
      ),
    );
  }

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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showApproveDialog(BuildContext context, DesignRequestController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Approve Design Request'),
        content: const Text('Are you sure you want to approve this design request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveRequest(request.id);
              Get.back(); // Close detail screen
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, DesignRequestController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Design Request'),
        content: const Text('Are you sure you want to reject this design request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectRequest(request.id);
              Get.back(); // Close detail screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
