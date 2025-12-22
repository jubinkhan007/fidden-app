import 'package:get/get.dart';
import '../data/hairstylist_models.dart';
import '../services/hairstylist_service.dart';

/// Controller for hairstylist dashboard
class HairstylistDashboardController extends GetxController {
  final HairstylistService _service = HairstylistService();

  final Rx<HairstylistDashboard?> dashboard = Rx<HairstylistDashboard?>(null);
  final Rx<WeeklyScheduleResponse?> weeklySchedule =
      Rx<WeeklyScheduleResponse?>(null);
  final RxList<PrepNoteItem> prepNotes = <PrepNoteItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  /// Fetch all dashboard data
  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.wait([
        fetchDashboard(),
        fetchWeeklySchedule(),
        fetchPrepNotes(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch dashboard summary
  Future<void> fetchDashboard() async {
    try {
      dashboard.value = await _service.getDashboard();
    } catch (e) {
      // Log but don't throw - allow other fetches to continue
      print('Error fetching dashboard: $e');
    }
  }

  /// Fetch weekly schedule
  Future<void> fetchWeeklySchedule({int days = 7}) async {
    try {
      weeklySchedule.value = await _service.getWeeklySchedule(days: days);
    } catch (e) {
      print('Error fetching weekly schedule: $e');
    }
  }

  /// Fetch prep notes
  Future<void> fetchPrepNotes() async {
    try {
      prepNotes.value = await _service.getPrepNotes();
    } catch (e) {
      print('Error fetching prep notes: $e');
    }
  }

  /// Update prep notes for a booking
  Future<bool> updatePrepNotes(int bookingId, String notes) async {
    try {
      await _service.updatePrepNotes(bookingId, notes);
      // Refresh prep notes after update
      await fetchPrepNotes();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  // === Computed getters ===

  int get todayAppointmentsCount =>
      dashboard.value?.todayAppointmentsCount ?? 0;
  int get weekAppointmentsCount => dashboard.value?.weekAppointmentsCount ?? 0;
  double get todayRevenue => dashboard.value?.todayRevenue ?? 0;
  int get clientProfilesCount => dashboard.value?.clientProfilesCount ?? 0;
  int get productRecommendationsCount =>
      dashboard.value?.productRecommendationsCount ?? 0;

  /// Get upcoming prep notes (max 3)
  List<PrepNoteItem> get upcomingPrepNotes {
    final now = DateTime.now();
    return prepNotes
        .where((item) => item.slotTime.isAfter(now))
        .take(3)
        .toList();
  }

  bool get hasData => dashboard.value != null;
}
