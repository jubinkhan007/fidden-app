import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/app_sizes.dart';
import '../controller/business_owner_controller.dart';

class BookingStats extends StatelessWidget {
  const BookingStats({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BusinessOwnerController>();

    return Obx(() {
      final s = c.allBusinessOwnerBookingOne.value.stats;
      final total = s?.totalBookings ?? 0;
      final completed = s?.completed ?? 0;
      final cancelled = s?.cancelled ?? 0;

      return Row(
        children: [
          _buildStatItem("Total Bookings", "$total", Colors.blue),
          SizedBox(width: getWidth(16)),
          _buildStatItem("Completed", "$completed", Colors.green),
          SizedBox(width: getWidth(16)),
          _buildStatItem("Cancelled", "$cancelled", Colors.red),
        ],
      );
    });
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: getWidth(20),
              fontWeight: FontWeight.bold,
              color: color, // optional accent
            ),
          ),
          SizedBox(height: getHeight(4)),
          Text(
            title,
            style: TextStyle(
              fontSize: getWidth(14),
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
