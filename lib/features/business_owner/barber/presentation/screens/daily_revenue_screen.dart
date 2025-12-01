import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/daily_revenue_controller.dart';

class DailyRevenueScreen extends StatelessWidget {
  const DailyRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyRevenueController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Revenue'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.revenueData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.revenueData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchRevenue(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = controller.revenueData.value;
        if (data == null) {
          return const Center(child: Text('No revenue data available'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchRevenue(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Center(
                  child: Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.parse(data.date)),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),

                // Total Revenue Card
                Card(
                  elevation: 4,
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Total Revenue',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${data.totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.receipt,
                        label: 'Bookings',
                        value: data.bookingCount.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.attach_money,
                        label: 'Avg. Value',
                        value: '\$${data.averageBookingValue.toStringAsFixed(2)}',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Additional Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Revenue Breakdown',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.calendar_today, label: 'Date', value: data.date),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.trending_up,
                          label: 'Total Earnings',
                          value: '\$${data.totalRevenue.toStringAsFixed(2)}',
                        ),
                        const Divider(),
                        _InfoRow(icon: Icons.people, label: 'Total Bookings', value: data.bookingCount.toString()),
                        const Divider(),
                        _InfoRow(
                          icon: Icons.calculate,
                          label: 'Average per Booking',
                          value: '\$${data.averageBookingValue.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
