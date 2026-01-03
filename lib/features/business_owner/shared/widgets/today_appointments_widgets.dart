import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../barber/controller/today_appointments_controller.dart';
import '../../barber/data/today_appointments_model.dart';
import '../../home/controller/business_owner_controller.dart';
import '../../nav_bar/controllers/user_nav_bar_controller.dart';
import '../../profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/features/user/booking/presentation/api_time_format.dart';

/// Resolves Shop Timezone using Profile (Primary) or All Bookings Metadata (Secondary).
String? _resolveShopTimezone() {
  // 1. Profile Source
  if (Get.isRegistered<BusinessOwnerProfileController>()) {
    final p = Get.find<BusinessOwnerProfileController>();
    if (p.timeZone.value.isNotEmpty && p.timeZone.value != 'America/New_York') {
      return p.timeZone.value;
    }
  }

  // 2. All Bookings Source (Metadata Discovery)
  if (Get.isRegistered<BusinessOwnerController>()) {
    try {
      final boc = Get.find<BusinessOwnerController>();
      final bookings = boc.allBusinessOwnerBookingOne.value.results;
      final validBooking = bookings.firstWhereOrNull(
        (b) =>
            b.shopTimezone != null &&
            b.shopTimezone!.isNotEmpty &&
            b.shopTimezone != 'America/New_York',
      );
      if (validBooking != null) {
        return validBooking.shopTimezone;
      }
    } catch (_) {}
  }
  return null;
}

/// Formats appointment time consistently using resolved timezone or local fallback.
/// [appointmentTimezone] - Direct timezone from the appointment (highest priority).
String _formatAppointmentTime(String iso, {String? appointmentTimezone}) {
  // Priority: 1. Appointment's own timezone, 2. Global resolution, 3. Fallback
  final shopTimeZone = appointmentTimezone ?? _resolveShopTimezone();
  final tIndex = iso.indexOf('T');
  final hasOffset =
      iso.endsWith('Z') ||
      iso.contains('+') ||
      (tIndex != -1 && iso.substring(tIndex).contains('-'));

  if (shopTimeZone != null && shopTimeZone.isNotEmpty) {
    return formatApiTimeInTimezone(iso, shopTimeZone);
  }

  // Fallback
  if (hasOffset) {
    try {
      // Use Local Device Time
      return DateFormat('hh:mm a').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return formatWallClockTime(iso);
    }
  } else {
    return formatWallClockTime(iso);
  }
}

/// Shared widget for displaying the next upcoming appointment on niche dashboards.
/// Uses TodayAppointmentsController data instead of paginated booking data.
class UpcomingAppointmentCard extends StatelessWidget {
  final TodayAppointmentsController controller;

  /// Optional filter function to show only specific services.
  /// Return true if the appointment should be shown.
  final bool Function(Appointment)? serviceFilter;

  const UpcomingAppointmentCard({
    super.key,
    required this.controller,
    this.serviceFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      // Get upcoming appointments, optionally filtered
      var upcomingAppointments = controller.upcomingAppointments;
      if (serviceFilter != null) {
        upcomingAppointments = upcomingAppointments
            .where(serviceFilter!)
            .toList();
      }

      final nextAppointment = upcomingAppointments.isEmpty
          ? null
          : (upcomingAppointments
                  ..sort((a, b) => a.startTime.compareTo(b.startTime)))
                .first;

      if (nextAppointment == null) {
        return _buildEmptyState();
      }

      return _buildAppointmentCard(nextAppointment);
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: () {
        Get.find<BusinessOwnerNavBarController>().changeIndex(1);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No upcoming appointments',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'View all bookings',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    // Use centralized helper for consistent formatting
    final timeText = _formatAppointmentTime(
      appointment.startTimeIso,
      appointmentTimezone: appointment.shopTimezone,
    );

    return GestureDetector(
      onTap: () {
        Get.find<BusinessOwnerNavBarController>().changeIndex(1);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Customer Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF52B788), const Color(0xFF40916C)],
                ),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  appointment.customerName.isNotEmpty
                      ? appointment.customerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF52B788),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Customer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF2D3436),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.content_cut_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          appointment.serviceName,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF52B788).withOpacity(0.3),
                ),
              ),
              child: Text(
                timeText,
                style: const TextStyle(
                  color: Color(0xFF2D7A5A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Shows a bottom sheet with today's appointments for the selected date.
/// Uses TodayAppointmentsController data.
///
/// [serviceFilter] - Optional filter function to show only specific services.
void showDayAppointmentsBottomSheet(
  BuildContext context,
  DateTime date,
  TodayAppointmentsController controller, {
  bool Function(Appointment)? serviceFilter,
}) {
  var allAppointments = controller.allAppointments;

  // Apply optional service filter
  if (serviceFilter != null) {
    allAppointments = allAppointments.where(serviceFilter).toList();
  }

  // Filter appointments for the selected date
  final dayAppointments = allAppointments.where((a) {
    return a.startTime.year == date.year &&
        a.startTime.month == date.month &&
        a.startTime.day == date.day;
  }).toList();

  // Sort by time
  dayAppointments.sort((a, b) => a.startTime.compareTo(b.startTime));

  debugPrint(
    '📅 showDayAppointmentsBottomSheet: ${dayAppointments.length} appointments for ${date.toIso8601String()}',
  );

  final dateLabel = DateFormat('EEEE, MMM d').format(date);
  final isToday =
      date.day == DateTime.now().day &&
      date.month == DateTime.now().month &&
      date.year == DateTime.now().year;

  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today\'s Appointments' : dateLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${dayAppointments.length} ${dayAppointments.length == 1 ? 'appointment' : 'appointments'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Appointments list
          Flexible(
            child: dayAppointments.isEmpty
                ? _buildEmptyState(date)
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: dayAppointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final appointment = dayAppointments[index];
                      return _buildAppointmentCard(appointment);
                    },
                  ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildEmptyState(DateTime date) {
  final isToday =
      date.day == DateTime.now().day &&
      date.month == DateTime.now().month &&
      date.year == DateTime.now().year;
  final isFuture = date.isAfter(DateTime.now());

  return Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          isToday
              ? 'No appointments today'
              : isFuture
              ? 'No appointments scheduled'
              : 'No appointments were booked',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isToday || isFuture
              ? 'Your schedule is free!'
              : 'This day had no bookings',
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
      ],
    ),
  );
}

Widget _buildAppointmentCard(Appointment appointment) {
  final status = appointment.status.toLowerCase();

  // Get status styling based on actual appointment status
  Color statusBgColor;
  Color statusTextColor;
  String statusText;

  switch (status) {
    case 'completed':
    case 'confirmed':
      statusBgColor = const Color(0xFFE6F4EA);
      statusTextColor = const Color(0xFF2E7D32);
      statusText = status == 'completed' ? 'Completed' : 'Confirmed';
      break;
    case 'active':
      statusBgColor = const Color(0xFFE3F2FD);
      statusTextColor = const Color(0xFF1565C0);
      statusText = 'Active';
      break;
    case 'cancelled':
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
      statusText = 'Cancelled';
      break;
    case 'pending':
    default:
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFF57C00);
      statusText = 'Pending';
      break;
  }

  // Use centralized helper for consistent formatting
  final timeText = _formatAppointmentTime(
    appointment.startTimeIso,
    appointmentTimezone: appointment.shopTimezone,
  );

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        // Time column
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE5E7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            timeText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE63946),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Customer info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                appointment.serviceName,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${appointment.serviceDuration} min',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ),

        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusTextColor,
            ),
          ),
        ),
      ],
    ),
  );
}
