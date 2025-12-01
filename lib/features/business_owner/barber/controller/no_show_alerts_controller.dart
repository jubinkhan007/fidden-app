import 'package:get/get.dart';
import '../data/no_show_alerts_model.dart';
import '../services/barber_dashboard_service.dart';

class NoShowAlertsController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  final Rx<NoShowAlertsResponse?> alertsData = Rx<NoShowAlertsResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedDays = 30.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlerts();
  }

  Future<void> fetchAlerts({int? days}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      if (days != null) {
        selectedDays.value = days;
      }
      
      final data = await _service.getNoShowAlerts(days: selectedDays.value);
      alertsData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
