import 'package:flutter/material.dart';
import '../../../../../core/utils/constants/app_sizes.dart';

class BookingStats extends StatelessWidget {
  const BookingStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatItem("Total Bookings", "125", Colors.blue),
        SizedBox(width: getWidth(16)),
        _buildStatItem("Completed", "98", Colors.green),
        SizedBox(width: getWidth(16)),
        _buildStatItem("Canceled", "27", Colors.red),
      ],
    );
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
