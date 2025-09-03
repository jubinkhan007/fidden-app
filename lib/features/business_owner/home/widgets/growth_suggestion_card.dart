import 'package:flutter/material.dart';
import '../../../../../core/utils/constants/app_sizes.dart';

class GrowthSuggestionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const GrowthSuggestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 28),
            SizedBox(width: getWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: getHeight(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: getWidth(14),
                      color: Colors.grey.shade600,
                    ),
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
