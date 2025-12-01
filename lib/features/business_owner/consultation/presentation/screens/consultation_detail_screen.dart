import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/consultation_model.dart';
import '../../controller/consultation_controller.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailScreen({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConsultationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, controller),
          ),
        ],
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
                    _InfoRow(icon: Icons.person, label: 'Name', value: consultation.customerName),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.email, label: 'Email', value: consultation.customerEmail),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.phone, label: 'Phone', value: consultation.customerPhone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Appointment Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appointment Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: DateFormat('MMMM dd, yyyy').format(consultation.dateTime),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: DateFormat('h:mm a').format(consultation.dateTime),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.timer, label: 'Duration', value: '${consultation.durationMinutes} minutes'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes
            if (consultation.notes.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(consultation.notes),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(consultation.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(consultation.status), color: _getStatusColor(consultation.status)),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${consultation.status.replaceAll('_', ' ').toUpperCase()}',
                    style: TextStyle(
                      color: _getStatusColor(consultation.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Obx(() => Column(
              children: [
                if (consultation.isScheduled) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.confirmConsultation(consultation.id),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm Consultation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (consultation.isConfirmed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => _showCompleteDialog(context, controller),
                      icon: const Icon(Icons.done_all),
                      label: const Text('Mark as Completed'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (!consultation.isCompleted && !consultation.isCancelled && !consultation.isNoShow) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.cancelConsultation(consultation.id),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.markNoShow(consultation.id),
                          icon: const Icon(Icons.person_off),
                          label: const Text('No-Show'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'scheduled':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      default:
        return Icons.help;
    }
  }

  void _showDeleteDialog(BuildContext context, ConsultationController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Consultation'),
        content: const Text('Are you sure you want to delete this consultation?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteConsultation(consultation.id);
              Get.back(); // Close detail screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, ConsultationController controller) {
    final notesController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add any final notes about the consultation:'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'e.g., Design approved, ready to schedule session',
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
              Get.back();
              controller.completeConsultation(
                consultation.id,
                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );
            },
            child: const Text('Complete'),
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
