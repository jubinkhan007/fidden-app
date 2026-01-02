import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/walk_in_controller.dart';
import '../../data/walk_in_model.dart';
import '../../../home/controller/business_owner_controller.dart';

/// Screen for managing walk-in queue
class WalkInQueueScreen extends StatelessWidget {
  const WalkInQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalkInController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk-In Queue'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchQueue(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.queue.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.queue.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchQueue(),
          child: Column(
            children: [
              // Stats bar
              _buildStatsBar(controller),

              // Queue list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.queue.length,
                  itemBuilder: (context, index) {
                    final entry = controller.queue[index];
                    return _buildQueueCard(context, entry, controller);
                  },
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalkInSheet(context, controller),
        backgroundColor: const Color(0xFFE63946),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Walk-In', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No walk-ins in queue',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a walk-in customer',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(WalkInController controller) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Waiting',
              controller.waitingCount.toString(),
              const Color(0xFFF57C00),
            ),
            _buildStatItem(
              'In Service',
              controller.inServiceCount.toString(),
              const Color(0xFF1565C0),
            ),
            _buildStatItem(
              'Total',
              controller.totalInQueue.toString(),
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQueueCard(
    BuildContext context,
    WalkInEntry entry,
    WalkInController controller,
  ) {
    Color statusColor;
    String statusText;

    switch (entry.status) {
      case WalkInStatus.waiting:
        statusColor = const Color(0xFFF57C00);
        statusText = 'Waiting';
        break;
      case WalkInStatus.in_service:
        statusColor = const Color(0xFF1565C0);
        statusText = 'In Service';
        break;
      case WalkInStatus.completed:
        statusColor = const Color(0xFF2E7D32);
        statusText = 'Completed';
        break;
      case WalkInStatus.no_show:
        statusColor = const Color(0xFFC62828);
        statusText = 'No Show';
        break;
      case WalkInStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Position badge
                if (entry.isWaiting)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE63946),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#${entry.position}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      entry.isBeingServed ? Icons.content_cut : Icons.check,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),

                // Customer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (entry.serviceName != null)
                        Text(
                          entry.serviceName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),

                // Status and wait time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.waitTimeDisplay,
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),

            // Action buttons
            if (entry.status == WalkInStatus.waiting ||
                entry.status == WalkInStatus.in_service)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    if (entry.isWaiting) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.startService(entry.id),
                          icon: const Icon(Icons.record_voice_over, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.markNoShow(entry.id),
                          icon: const Icon(Icons.person_off, size: 18),
                          label: const Text('No Show'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC62828),
                          ),
                        ),
                      ),
                    ],
                    if (entry.isBeingServed) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showCheckoutSheet(context, controller, entry),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddWalkInSheet(BuildContext context, WalkInController controller) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    int? selectedServiceId;

    // Get services from BusinessOwnerController
    final boController = Get.find<BusinessOwnerController>();
    final services = boController.allServiceList;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Walk-In Customer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),

              if (services.isNotEmpty)
                DropdownButtonFormField<int>(
                  value: selectedServiceId,
                  decoration: InputDecoration(
                    labelText: 'Service (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.content_cut),
                  ),
                  items: services
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.title ?? 'Service'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => selectedServiceId = val,
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Customer name is required',
                              );
                              return;
                            }

                            // Close sheet immediately
                            Get.back();

                            // Then add to queue in background
                            controller.addToQueue(
                              customerName: nameController.text.trim(),
                              customerPhone:
                                  phoneController.text.trim().isNotEmpty
                                  ? phoneController.text.trim()
                                  : null,
                              serviceId: selectedServiceId,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE63946),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add to Queue'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCheckoutSheet(
    BuildContext context,
    WalkInController controller,
    WalkInEntry entry,
  ) {
    final amountController = TextEditingController(
      text: (entry.servicePrice ?? 0.0).toStringAsFixed(2),
    );
    final tipsController = TextEditingController(text: '0.00');
    final RxString selectedMethod = 'cash'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Complete Service',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (entry.serviceName != null) ...[
                Text(
                  'Service: ${entry.serviceName}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Payment Method',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    _buildPaymentOption('Cash', 'cash', selectedMethod),
                    const SizedBox(width: 8),
                    _buildPaymentOption('Card', 'card', selectedMethod),
                    const SizedBox(width: 8),
                    _buildPaymentOption('Other', 'other', selectedMethod),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount Paid',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: tipsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Tips',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () {
                            final amount =
                                double.tryParse(amountController.text) ?? 0.0;
                            final tips =
                                double.tryParse(tipsController.text) ?? 0.0;

                            Get.back(); // Close sheet

                            controller.completeWithPayment(
                              id: entry.id,
                              paymentMethod: selectedMethod.value,
                              amountPaid: amount,
                              tipsAmount: tips,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Complete & Checkout'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPaymentOption(String label, String value, RxString selected) {
    final isSelected = selected.value == value;
    return Expanded(
      child: InkWell(
        onTap: () => selected.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
