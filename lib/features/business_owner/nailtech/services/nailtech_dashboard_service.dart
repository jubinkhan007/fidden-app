import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/style_request_model.dart';
import '../data/nailtech_dashboard_model.dart';
import '../../../../features/user/design_requests/data/client_design_request_model.dart';

/// Service for Nail Tech Dashboard API calls
class NailTechDashboardService {
  final NetworkCaller _networkCaller = NetworkCaller();

  // =========================
  // DASHBOARD SUMMARY
  // =========================

  /// Get dashboard summary metrics
  Future<NailTechDashboard> getDashboard() async {
    final response = await _networkCaller.getRequest(
      AppUrls.nailtechDashboard,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return NailTechDashboard.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch dashboard');
  }

  // =========================
  // STYLE REQUESTS
  // =========================

  /// Get all style requests
  Future<List<StyleRequest>> getStyleRequests() async {
    final response = await _networkCaller.getRequest(
      AppUrls.styleRequests,
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      List<dynamic> data;
      if (response.responseData is List) {
        data = response.responseData;
      } else if (response.responseData is Map &&
          response.responseData['results'] != null) {
        data = response.responseData['results'] as List;
      } else {
        data = [];
      }
      return data
          .map((e) => StyleRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch style requests');
  }

  /// Get design requests for the shop (from booking flow)
  Future<List<ClientDesignRequest>> getDesignRequests() async {
    final response = await _networkCaller.getRequest(
      AppUrls.designRequests,
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      List<dynamic> data;
      if (response.responseData is List) {
        data = response.responseData;
      } else if (response.responseData is Map &&
          response.responseData['results'] != null) {
        data = response.responseData['results'] as List;
      } else {
        data = [];
      }
      return data
          .map((e) => ClientDesignRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch design requests');
  }

  /// Update style request status
  Future<StyleRequest> updateStyleRequestStatus(
    int id,
    StyleRequestStatus status,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.styleRequestDetail(id),
      body: {'status': status.toApiString()},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return StyleRequest.fromJson(response.responseData);
    }

    throw Exception('Failed to update style request');
  }

  // =========================
  // LOOKBOOK
  // =========================

  /// Get lookbook items
  Future<LookbookResponse> getLookbook() async {
    final response = await _networkCaller.getRequest(
      AppUrls.nailtechLookbook,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return LookbookResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch lookbook');
  }

  // =========================
  // BOOKINGS BY STYLE
  // =========================

  /// Get bookings grouped by style type
  Future<BookingsByStyleResponse> getBookingsByStyle({int days = 30}) async {
    final response = await _networkCaller.getRequest(
      '${AppUrls.bookingsByStyle}?days=$days',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return BookingsByStyleResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch bookings by style');
  }

  // =========================
  // TIP SUMMARY
  // =========================

  /// Get tip summary for a period
  Future<TipSummary> getTipSummary({String period = 'week'}) async {
    final response = await _networkCaller.getRequest(
      '${AppUrls.tipSummary}?period=$period',
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return TipSummary.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch tip summary');
  }
}
