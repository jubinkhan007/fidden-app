import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/id_verification_controller.dart';
import 'id_verification_detail_screen.dart';

class IDVerificationQueueScreen extends StatelessWidget {
  const IDVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IDVerificationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification Queue'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.fetchIDVerifications(status: value == 'all' ? null : value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'under_review', child: Text('Under Review')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.verifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.verifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchIDVerifications(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.verifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No ID verifications pending',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchIDVerifications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.verifications.length,
            itemBuilder: (context, index) {
              final verification = controller.verifications[index];
              return _IDVerificationCard(
                verification: verification,
                onTap: () => Get.to(() => IDVerificationDetailScreen(verification: verification)),
              );
            },
          ),
        );
      }),
    );
  }
}

class _IDVerificationCard extends StatelessWidget {
  final dynamic verification;
  final VoidCallback onTap;

  const _IDVerificationCard({
    required this.verification,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending_upload':
        return Colors.grey;
      case 'under_review':
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
          backgroundColor: _getStatusColor(verification.status).withOpacity(0.1),
          child: Icon(
            Icons.badge,
            color: _getStatusColor(verification.status),
          ),
        ),
        title: Text(
          verification.user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(verification.user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    verification.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(verification.status).withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  verification.createdAt.toString().split(' ')[0],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
