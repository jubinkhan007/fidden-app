import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/no_show_alerts_controller.dart';

class NoShowAlertsScreen extends StatelessWidget {
  const NoShowAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoShowAlertsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('No-Show Alerts'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (days) => controller.fetchAlerts(days: days),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 60, child: Text('Last 60 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.alertsData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.alertsData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchAlerts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = controller.alertsData.value;
        if (data == null || data.noShows.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'No no-show alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last ${controller.selectedDays.value} days',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAlerts(),
          child: Column(
            children: [
              // Summary Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    const Icon(Icons.person_off, size: 32, color: Colors.orange),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.count} No-Shows',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Last ${data.days} days',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // No-Show List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.noShows.length,
                  itemBuilder: (context, index) {
                    final noShow = data.noShows[index];
                    return _NoShowCard(noShow: noShow);
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

class _NoShowCard extends StatelessWidget {
  final dynamic noShow;

  const _NoShowCard({required this.noShow});

  @override
  Widget build(BuildContext context) {
    final phone = noShow.customerPhone?.toString() ?? '';
    final email = noShow.customerEmail?.toString() ?? '';
    final hasPhone = phone.isNotEmpty && phone != 'null';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            const CircleAvatar(
              backgroundColor: Color(0xFFFFF3E0),
              child: Icon(Icons.person_off, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noShow.customerName ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  
                  // Email row
                  if (email.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.email, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(email, style: TextStyle(color: Colors.grey[700]))),
                      ],
                    ),
                  
                  // Phone row - only show if exists
                  if (hasPhone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(phone, style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.content_cut, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(noShow.serviceName ?? 'Service'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${noShow.scheduledDate ?? ''} at ${noShow.scheduledTime ?? ''}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
