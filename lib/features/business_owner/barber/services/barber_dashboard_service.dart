import '../data/today_appointments_model.dart';
import '../data/daily_revenue_model.dart';
import '../data/no_show_alerts_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class BarberDashboardService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get today's appointments with stats
  Future<TodayAppointmentsResponse> getTodayAppointments() async {
    final response = await _networkCaller.getRequest(
      AppUrls.todayAppointments,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return TodayAppointmentsResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch today\'s appointments');
  }

  /// Get daily revenue metrics
  Future<DailyRevenueResponse> getDailyRevenue() async {
    final response = await _networkCaller.getRequest(
      AppUrls.dailyRevenue,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return DailyRevenueResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch daily revenue');
  }

  /// Get no-show alerts
  Future<NoShowAlertsResponse> getNoShowAlerts({int? days}) async {
    String url = AppUrls.noShowAlerts;
    if (days != null) {
      url = '$url?days=$days';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return NoShowAlertsResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch no-show alerts');
  }
}
