import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/today_appointments_controller.dart';

class TodayAppointmentsScreen extends StatelessWidget {
  const TodayAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodayAppointmentsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Appointments'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.appointmentsData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.appointmentsData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAppointments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = controller.appointmentsData.value;
        if (data == null || data.appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No appointments today',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAppointments(),
          child: Column(
            children: [
              // Stats Summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Confirmed', count: data.stats.confirmed, color: Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(child: _StatCard(label: 'Completed', count: data.stats.completed, color: Colors.green)),
                        const SizedBox(width: 8),
                        Expanded(child: _StatCard(label: 'Cancelled', count: data.stats.cancelled, color: Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(child: _StatCard(label: 'No-Show', count: data.stats.noShow, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),

              // Appointments List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = data.appointments[index];
                    return _AppointmentCard(appointment: appointment);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final dynamic appointment;

  const _AppointmentCard({required this.appointment});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'no_show':
        return Colors.orange;
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
          backgroundColor: _getStatusColor(appointment.status).withOpacity(0.1),
          child: Icon(Icons.person, color: _getStatusColor(appointment.status)),
        ),
        title: Text(
          appointment.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.content_cut, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(appointment.serviceName)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(DateFormat('h:mm a').format(appointment.startTime)),
                const SizedBox(width: 4),
                Text('(${appointment.serviceDuration} min)'),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    appointment.status.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getStatusColor(appointment.status).withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
