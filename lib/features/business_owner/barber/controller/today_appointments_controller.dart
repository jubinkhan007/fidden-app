import 'package:get/get.dart';
import '../data/today_appointments_model.dart';
import '../services/barber_dashboard_service.dart';

class TodayAppointmentsController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  final Rx<TodayAppointmentsResponse?> appointmentsData = Rx<TodayAppointmentsResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getTodayAppointments();
      appointmentsData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<Appointment> get confirmedAppointments =>
      appointmentsData.value?.appointments.where((a) => a.status == 'confirmed').toList() ?? [];

  List<Appointment> get completedAppointments =>
      appointmentsData.value?.appointments.where((a) => a.status == 'completed').toList() ?? [];

  List<Appointment> get upcomingAppointments =>
      appointmentsData.value?.appointments
          .where((a) => a.status == 'confirmed' && a.startTime.isAfter(DateTime.now()))
          .toList() ?? [];
}
