import 'package:get/get.dart';
import '../data/daily_revenue_model.dart';
import '../services/barber_dashboard_service.dart';

class DailyRevenueController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  final Rx<DailyRevenueResponse?> revenueData = Rx<DailyRevenueResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRevenue();
  }

  Future<void> fetchRevenue() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getDailyRevenue();
      revenueData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
