import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../consultation/data/consultation_model.dart';

/// Card showing next upcoming consultation
class UpcomingConsultationCard extends StatelessWidget {
  final Consultation? consultation;
  final VoidCallback? onTap;

  const UpcomingConsultationCard({
    super.key,
    this.consultation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (consultation == null) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.calendar_today, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No upcoming consultations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Schedule a new consultation',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C757D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFFE5E7),
                child: Text(
                  consultation!.customerName.isNotEmpty
                      ? consultation!.customerName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE63946),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation!.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (consultation!.notes.isNotEmpty)
                      Text(
                        consultation!.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(consultation!.dateTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF52B788),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6C757D)),
            ],
          ),
        ),
      ),
    );
  }
}
