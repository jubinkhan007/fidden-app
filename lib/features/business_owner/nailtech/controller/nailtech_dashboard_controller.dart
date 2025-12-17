import 'package:get/get.dart';
import '../data/nailtech_dashboard_model.dart';
import '../services/nailtech_dashboard_service.dart';

/// Controller for Nail Tech Dashboard summary and metrics
class NailTechDashboardController extends GetxController {
  final NailTechDashboardService _service = NailTechDashboardService();

  final Rx<NailTechDashboard?> dashboard = Rx<NailTechDashboard?>(null);
  final Rx<TipSummary?> tipSummary = Rx<TipSummary?>(null);
  final Rx<BookingsByStyleResponse?> bookingsByStyle = Rx<BookingsByStyleResponse?>(null);
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  /// Fetch all dashboard data
  Future<void> fetchAll() async {
    await Future.wait([
      fetchDashboard(),
      fetchTipSummary(),
      fetchBookingsByStyle(),
    ]);
  }

  /// Fetch dashboard summary
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getDashboard();
      dashboard.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch tip summary
  Future<void> fetchTipSummary({String period = 'week'}) async {
    try {
      final data = await _service.getTipSummary(period: period);
      tipSummary.value = data;
    } catch (e) {
      // Silent fail - tips are optional
    }
  }

  /// Fetch bookings by style
  Future<void> fetchBookingsByStyle({int days = 30}) async {
    try {
      final data = await _service.getBookingsByStyle(days: days);
      bookingsByStyle.value = data;
    } catch (e) {
      // Silent fail - chart data is optional
    }
  }

  // Convenience getters
  double get todayRevenue => dashboard.value?.todayRevenue ?? 0.0;
  int get pendingStyleRequests => dashboard.value?.pendingStyleRequests ?? 0;
  double get repeatCustomerRate => dashboard.value?.repeatCustomerRate ?? 0.0;
  double get weeklyTips => dashboard.value?.weeklyTips ?? 0.0;
  int get lookbookCount => dashboard.value?.lookbookCount ?? 0;
}
