import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/today_appointments_model.dart';
import '../services/barber_dashboard_service.dart';

class TodayAppointmentsController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  final Rx<TodayAppointmentsResponse?> appointmentsData =
      Rx<TodayAppointmentsResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentNiche = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch here - let niche dashboards call fetchAppointments with their niche
  }

  /// Fetch today's appointments with optional niche filter
  /// Call this from niche dashboards (tattoo, barber, etc.)
  Future<void> fetchAppointments({String? niche, String? date}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentNiche.value = niche ?? '';

      debugPrint(
        '📅 TodayAppointmentsController: fetching for niche=$niche, date=$date',
      );

      final data = await _service.getTodayAppointments(
        niche: niche,
        date: date,
      );
      appointmentsData.value = data;

      debugPrint(
        '📅 TodayAppointmentsController: loaded ${data.appointments.length} appointments',
      );
    } catch (e) {
      debugPrint('📅 TodayAppointmentsController: error=$e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// All appointments (unfiltered)
  List<Appointment> get allAppointments =>
      appointmentsData.value?.appointments ?? [];

  List<Appointment> get confirmedAppointments =>
      appointmentsData.value?.appointments
          .where((a) => a.status == 'confirmed')
          .toList() ??
      [];

  List<Appointment> get completedAppointments =>
      appointmentsData.value?.appointments
          .where((a) => a.status == 'completed')
          .toList() ??
      [];

  List<Appointment> get upcomingAppointments {
    final appointments = appointmentsData.value?.appointments ?? [];

    // Log all appointment statuses for debugging
    if (appointments.isNotEmpty) {
      final statusCounts = <String, int>{};
      for (final a in appointments) {
        statusCounts[a.status] = (statusCounts[a.status] ?? 0) + 1;
      }
      debugPrint('📅 upcomingAppointments: all statuses=$statusCounts');
    }

    final now = DateTime.now();
    final upcoming = appointments.where((a) {
      final status = a.status.toLowerCase();
      // Include both 'active' and 'confirmed' statuses
      final isValidStatus = status == 'active' || status == 'confirmed';
      final isFuture = a.startTime.isAfter(now);
      debugPrint(
        '📅 Appointment ${a.id}: status=$status, startTime=${a.startTime}, isFuture=$isFuture, isValidStatus=$isValidStatus',
      );
      return isValidStatus && isFuture;
    }).toList();

    debugPrint(
      '📅 upcomingAppointments: ${upcoming.length} upcoming out of ${appointments.length} total',
    );
    return upcoming;
  }

  /// Next upcoming appointment (first in time)
  Appointment? get nextAppointment {
    final upcoming = upcomingAppointments;
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.first;
  }
}
