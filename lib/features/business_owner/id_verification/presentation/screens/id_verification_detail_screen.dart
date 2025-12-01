import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/id_verification_model.dart';
import '../../controller/id_verification_controller.dart';

class IDVerificationDetailScreen extends StatefulWidget {
  final IDVerificationRequest verification;

  const IDVerificationDetailScreen({super.key, required this.verification});

  @override
  State<IDVerificationDetailScreen> createState() => _IDVerificationDetailScreenState();
}

class _IDVerificationDetailScreenState extends State<IDVerificationDetailScreen> {
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IDVerificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification Details'),
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
                    _InfoRow(icon: Icons.person, label: 'Name', value: widget.verification.user.name),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.email, label: 'Email', value: widget.verification.user.email),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Submitted',
                      value: widget.verification.createdAt.toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ID Images
            const Text(
              'ID Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (widget.verification.frontImageUrl != null) ...[
              const Text('Front:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showImageDialog(widget.verification.frontImageUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.verification.frontImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (widget.verification.backImageUrl != null) ...[
              const Text('Back:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showImageDialog(widget.verification.backImageUrl!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.verification.backImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.verification.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(widget.verification.status), color: _getStatusColor(widget.verification.status)),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${widget.verification.status.replaceAll('_', ' ').toUpperCase()}',
                    style: TextStyle(
                      color: _getStatusColor(widget.verification.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.verification.rejectionReason != null && widget.verification.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rejection Reason:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.verification.rejectionReason!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons (only show if under review)
            if (widget.verification.isUnderReview) ...[
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending_upload':
        return Icons.upload_file;
      case 'under_review':
        return Icons.schedule;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, IDVerificationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Approve ID Verification'),
        content: const Text('Are you sure this ID is valid and the customer is 18+ years old?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approveID(widget.verification.id);
              Get.back(); // Close detail screen
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, IDVerificationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reject ID Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                hintText: 'e.g., Image is blurry, please retake',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (_rejectionReasonController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please provide a rejection reason');
                return;
              }
              Get.back();
              controller.rejectID(widget.verification.id, _rejectionReasonController.text.trim());
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
