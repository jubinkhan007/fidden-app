import '../data/today_appointments_model.dart';
import '../data/daily_revenue_model.dart';
import '../data/no_show_alerts_model.dart';
import '../data/walk_in_model.dart';
import '../data/loyalty_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class BarberDashboardService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get today's appointments with stats
  Future<TodayAppointmentsResponse> getTodayAppointments({String? date}) async {
    String url = AppUrls.todayAppointments;
    if (date != null) {
      url = '$url?date=$date';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return TodayAppointmentsResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch today\'s appointments');
  }

  /// Get daily revenue metrics with optional filters
  /// [date] - Filter by specific date (YYYY-MM-DD)
  /// [niche] - Filter by niche: 'hairstylist' uses separate endpoint, others use query param
  /// [serviceType] - Filter by specific service type
  Future<DailyRevenueResponse> getDailyRevenue({
    String? date,
    String? niche,
    String? serviceType,
  }) async {
    // Hairstylist uses a different endpoint with different response format
    if (niche?.toLowerCase() == 'hairstylist') {
      return _getHairstylistRevenue();
    }

    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;
    if (niche != null) queryParams['niche'] = niche;
    if (serviceType != null) queryParams['service_type'] = serviceType;

    String url = AppUrls.dailyRevenue;
    if (queryParams.isNotEmpty) {
      url = Uri.parse(url).replace(queryParameters: queryParams).toString();
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return DailyRevenueResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch daily revenue');
  }

  /// Get hairstylist-specific revenue from the hairstylist dashboard endpoint
  Future<DailyRevenueResponse> _getHairstylistRevenue() async {
    final response = await _networkCaller.getRequest(
      AppUrls.hairstylistDashboard,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      final data = response.responseData as Map<String, dynamic>;
      // Map hairstylist dashboard response to DailyRevenueResponse
      // Hairstylist returns: { "today_revenue": 32.0, "today_appointments_count": 2, ... }
      return DailyRevenueResponse(
        date: DateTime.now().toString().split(' ')[0], // Today's date
        totalRevenue: (data['today_revenue'] as num?)?.toDouble() ?? 0.0,
        bookingCount: data['today_appointments_count'] as int? ?? 0,
        averageBookingValue: 0.0, // Not provided by this endpoint
      );
    }

    throw Exception('Failed to fetch hairstylist revenue');
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

  // =====================
  // WALK-IN QUEUE METHODS
  // =====================

  /// Get walk-in queue (returns list, not wrapped object)
  Future<List<WalkInEntry>> getWalkInQueue({
    String? status,
    String? serviceNiche,
  }) async {
    var url = AppUrls.walkIns;
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (serviceNiche != null) params['service_niche'] = serviceNiche;
    if (params.isNotEmpty) {
      url =
          '$url?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((e) => WalkInEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch walk-in queue');
  }

  /// Get walk-in queue stats
  Future<Map<String, int>> getWalkInStats({String? serviceNiche}) async {
    var url = AppUrls.walkInStats;
    if (serviceNiche != null) url = '$url?service_niche=$serviceNiche';

    final response = await _networkCaller.getRequest(
      url,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      final data = response.responseData as Map<String, dynamic>;
      return {
        'waiting': data['waiting'] as int? ?? 0,
        'in_service': data['in_service'] as int? ?? 0,
        'completed': data['completed'] as int? ?? 0,
        'no_show': data['no_show'] as int? ?? 0,
        'total': data['total'] as int? ?? 0,
      };
    }

    throw Exception('Failed to fetch walk-in stats');
  }

  /// Add customer to walk-in queue
  Future<WalkInEntry> addToWalkInQueue({
    required String customerName,
    String? customerPhone,
    int? serviceId,
    String? notes,
  }) async {
    final response = await _networkCaller.postRequest(
      AppUrls.walkIns,
      body: {
        'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
        if (serviceId != null) 'service': serviceId,
        if (notes != null) 'notes': notes,
      },
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return WalkInEntry.fromJson(response.responseData);
    }

    throw Exception('Failed to add to walk-in queue');
  }

  /// Start service for a walk-in customer (POST /start/)
  Future<WalkInEntry> startWalkInService(int id) async {
    final response = await _networkCaller.postRequest(
      AppUrls.walkInStart(id),
      body: {},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return WalkInEntry.fromJson(response.responseData);
    }

    throw Exception('Failed to start service');
  }

  /// Complete walk-in with payment (POST /complete/) - Creates SlotBooking + Payment
  Future<WalkInEntry> completeWalkInWithPayment({
    required int id,
    required String paymentMethod, // 'cash', 'card', 'other'
    required double amountPaid,
    double tipsAmount = 0,
  }) async {
    final response = await _networkCaller.postRequest(
      AppUrls.walkInComplete(id),
      body: {
        'payment_method': paymentMethod,
        'amount_paid': amountPaid,
        'tips_amount': tipsAmount,
      },
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return WalkInEntry.fromJson(response.responseData);
    }

    throw Exception('Failed to complete walk-in');
  }

  /// Mark walk-in as no-show (POST /no_show/)
  Future<WalkInEntry> markWalkInNoShow(int id) async {
    final response = await _networkCaller.postRequest(
      AppUrls.walkInNoShow(id),
      body: {},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return WalkInEntry.fromJson(response.responseData);
    }

    throw Exception('Failed to mark as no-show');
  }

  /// Update walk-in entry (PATCH) - for notes, etc.
  Future<WalkInEntry> updateWalkInEntry(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.walkInDetail(id),
      body: data,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return WalkInEntry.fromJson(response.responseData);
    }

    throw Exception('Failed to update walk-in');
  }

  /// Remove customer from walk-in queue
  Future<void> removeFromWalkInQueue(int id) async {
    final response = await _networkCaller.deleteRequest(
      AppUrls.walkInDetail(id),
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to remove from walk-in queue');
    }
  }

  // =========================
  // LOYALTY PROGRAM METHODS
  // =========================

  /// Get loyalty program settings
  Future<LoyaltyProgram> getLoyaltyProgram() async {
    final response = await _networkCaller.getRequest(
      AppUrls.loyaltyProgram,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return LoyaltyProgram.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch loyalty program');
  }

  /// Update loyalty program settings
  Future<LoyaltyProgram> updateLoyaltyProgram({
    bool? isActive,
    double? pointsPerDollar,
    int? pointsForRedemption,
    String? rewardType,
    double? rewardValue,
  }) async {
    final response = await _networkCaller.patchRequest(
      AppUrls.loyaltyProgram,
      body: {
        if (isActive != null) 'is_active': isActive,
        if (pointsPerDollar != null) 'points_per_dollar': pointsPerDollar,
        if (pointsForRedemption != null)
          'points_for_redemption': pointsForRedemption,
        if (rewardType != null) 'reward_type': rewardType,
        if (rewardValue != null) 'reward_value': rewardValue,
      },
      token: AuthService.accessToken,
    );

    if (response.isSuccess) {
      dynamic data = response.responseData;

      // Handle string responses that need parsing
      if (data is String) {
        try {
          data = Map<String, dynamic>.from((data.isNotEmpty) ? {} : {});
        } catch (_) {}
      }

      if (data is Map<String, dynamic>) {
        return LoyaltyProgram.fromJson(data);
      }

      // If we got 200 but can't parse, refetch the program
      return await getLoyaltyProgram();
    }

    throw Exception('Failed to update loyalty program');
  }

  /// Get list of loyal customers
  Future<LoyaltyCustomersResponse> getLoyaltyCustomers() async {
    final response = await _networkCaller.getRequest(
      AppUrls.loyaltyCustomers,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return LoyaltyCustomersResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to fetch loyalty customers');
  }

  /// Add loyalty points for a customer
  Future<AddPointsResponse> addLoyaltyPoints({
    required int userId,
    required double amountSpent,
  }) async {
    final response = await _networkCaller.postRequest(
      AppUrls.loyaltyAddPoints,
      body: {'user_id': userId, 'amount_spent': amountSpent},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return AddPointsResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to add loyalty points');
  }

  /// Redeem loyalty points for a customer
  Future<RedeemResponse> redeemLoyaltyPoints({required int userId}) async {
    final response = await _networkCaller.postRequest(
      AppUrls.loyaltyRedeem,
      body: {'user_id': userId},
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return RedeemResponse.fromJson(response.responseData);
    }

    throw Exception('Failed to redeem loyalty points');
  }
}
