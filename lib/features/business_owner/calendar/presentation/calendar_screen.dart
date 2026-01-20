import 'package:fidden/features/business_owner/calendar/controller/calendar_controller.dart';
import 'package:fidden/features/business_owner/calendar/presentation/widgets/calendar_event_card.dart';
import 'package:fidden/features/business_owner/calendar/presentation/widgets/calendar_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  final int shopId; // Passed from navigation
  const CalendarScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());

    // Initialize once on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.shopId != shopId) {
        controller.init(shopId);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: const Text("Calendar"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshEvents,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Date Navigation & Provider Filter container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Bar
                _buildDateBar(controller),
                const SizedBox(height: 12),

                // Provider Filter Chips
                SizedBox(
                  height: 40,
                  child: Obx(() {
                    if (controller.isProvidersLoading.value &&
                        controller.providers.isEmpty) {
                      return const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.providers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final provider = controller.providers[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedProviderId.value ==
                              provider.id;
                          return ChoiceChip(
                            label: Text(provider.name),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              // If unselecting, default to 'All' (null) if logic permits,
                              // but UI usually enforces one selection.
                              // Here tapping 'All' (id=null) sets null.
                              if (selected) {
                                controller.onProviderSelected(provider.id);
                              }
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.black,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // 2. Event List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CalendarShimmer();
              }

              if (controller.events.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: controller.events.length,
                itemBuilder: (context, index) {
                  final event = controller.events[index];
                  return CalendarEventCard(event: event);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No appointments for this date.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar(CalendarController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              controller.onDateSelected(
                controller.selectedDate.value.subtract(const Duration(days: 1)),
              );
            },
          ),
          Obx(
            () => GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  controller.onDateSelected(picked);
                }
              },
              child: Row(
                children: [
                  Text(
                    DateFormat(
                      'EEEE, MMM d, y',
                    ).format(controller.selectedDate.value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              controller.onDateSelected(
                controller.selectedDate.value.add(const Duration(days: 1)),
              );
            },
          ),
        ],
      ),
    );
  }
}
