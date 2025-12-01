import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/consultation_controller.dart';
import 'consultation_create_screen.dart';
import 'consultation_detail_screen.dart';

class ConsultationCalendarScreen extends StatelessWidget {
  const ConsultationCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultationController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Calendar'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.fetchConsultations(status: value == 'all' ? null : value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'scheduled', child: Text('Scheduled')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.consultations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.consultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchConsultations(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.consultations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No consultations scheduled',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const ConsultationCreateScreen()),
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule Consultation'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchConsultations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.consultations.length,
            itemBuilder: (context, index) {
              final consultation = controller.consultations[index];
              return _ConsultationCard(
                consultation: consultation,
                onTap: () => Get.to(() => ConsultationDetailScreen(consultation: consultation)),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ConsultationCreateScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final dynamic consultation;
  final VoidCallback onTap;

  const _ConsultationCard({
    required this.consultation,
    required this.onTap,
  });

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

  String _formatDateTime(String date, String time) {
    try {
      final dateParts = date.split('-');
      final timeParts = time.split(':');
      final dateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
    } catch (e) {
      return '$date • $time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(consultation.status).withOpacity(0.1),
          child: Icon(
            Icons.calendar_today,
            color: _getStatusColor(consultation.status),
          ),
        ),
        title: Text(
          consultation.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(consultation.date, consultation.time)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${consultation.durationMinutes} min'),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    consultation.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(consultation.status).withOpacity(0.2),
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
