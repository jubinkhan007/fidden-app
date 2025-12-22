import 'package:get/get.dart';
import '../data/mua_models.dart';
import '../services/mua_service.dart';

/// Controller for MUA Dashboard summary metrics
class MUADashboardController extends GetxController {
  final MUAService _service = MUAService();

  final Rx<MUADashboard?> dashboardData = Rx<MUADashboard?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getDashboard();
      dashboardData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Convenience getters
  int get todayAppointments => dashboardData.value?.todayAppointmentsCount ?? 0;
  double get todayRevenue => dashboardData.value?.todayRevenue ?? 0.0;
  int get clientProfilesCount => dashboardData.value?.clientProfilesCount ?? 0;
  int get productKitCount => dashboardData.value?.productKitCount ?? 0;
  int get faceChartsCount => dashboardData.value?.faceChartsCount ?? 0;
  int get mobileServicesCount => dashboardData.value?.mobileServicesCount ?? 0;
}
