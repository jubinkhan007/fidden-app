import 'package:get/get.dart';
import '../data/daily_revenue_model.dart';
import '../services/barber_dashboard_service.dart';

class DailyRevenueController extends GetxController {
  final BarberDashboardService _service = BarberDashboardService();

  final Rx<DailyRevenueResponse?> revenueData = Rx<DailyRevenueResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// The niche to filter revenue by (set this before calling fetchRevenue)
  String? niche;

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch here - let the dashboard set the niche first and trigger fetch
  }

  Future<void> fetchRevenue({String? forNiche}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Use provided niche or the one set on controller
      final nicheToUse = forNiche ?? niche;
      final data = await _service.getDailyRevenue(niche: nicheToUse);
      revenueData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Convenience getters
  double get totalRevenue => revenueData.value?.totalRevenue ?? 0.0;
  int get bookingCount => revenueData.value?.bookingCount ?? 0;
  double get averageBookingValue =>
      revenueData.value?.averageBookingValue ?? 0.0;
}
