// lib/features/ai_assistant/ai_api.dart

import 'package:flutter/foundation.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

import '../../core/services/network_caller.dart'; // for AppUrls.baseUrl

/// Simple model for the AI report response from /api/ai-report/
class AiReport {
  final int totalAppointments;
  final double totalRevenue;
  final int noShowsFilled;
  final String topSellingService;
  final String forecastSummary;
  final String motivationalNudge;
  final DateTime updatedAt;
  final String aiPartnerName;

  AiReport({
    required this.totalAppointments,
    required this.totalRevenue,
    required this.noShowsFilled,
    required this.topSellingService,
    required this.forecastSummary,
    required this.motivationalNudge,
    required this.updatedAt,
    required this.aiPartnerName,
  });

  factory AiReport.fromJson(Map<String, dynamic> j) => AiReport(
    totalAppointments: (j['total_appointments'] ?? 0) as int,
    totalRevenue: ((j['total_revenue'] ?? 0) as num).toDouble(),
    noShowsFilled: (j['no_shows_filled'] ?? 0) as int,
    topSellingService: (j['top_selling_service'] ?? '-') as String,
    forecastSummary: (j['forecast_summary'] ?? '') as String,
    motivationalNudge: (j['motivational_nudge'] ?? '') as String,
    updatedAt: DateTime.parse(j['updated_at'] as String),
    aiPartnerName: (j['ai_partner_name'] ?? 'Amara') as String,
  );
}

class AiApi {
  AiApi();

  final _net = NetworkCaller();

  // // Build full URLs since NetworkCaller expects absolute endpoints
  // String get _aiReport => '${AppUrls.baseUrl}/api/ai-report/';
  // String get _subDetails => '${AppUrls.baseUrl}/api/subscriptions/details/';
  // String get _checkoutAiAddon =>
  //     '${AppUrls.baseUrl}/api/subscriptions/create-ai-addon-checkout-session/';

  /// Returns true if AI is included/active.
  /// Matches the payload you shared:
  /// {
  ///   "plan": {"ai_assistant": "included", ...},
  ///   "ai":   {"state": "included" | "active" | ...}
  /// }

  /// Cancels the AI add-on subscription (POST /subscriptions/cancel-ai-addon/).
  /// Returns true on success, otherwise throws with the backend error message.
  Future<bool> cancelAiAddon() async {
    final res = await _net.postRequest(
      AppUrls.cancelAiAddon,         // <-- ensure this constant is defined to "/subscriptions/cancel-ai-addon/"
      body: const {},                // <-- important so request.data isn't null on DRF side
      // NetworkCaller should send Content-Type: application/json
    );

    if (res.isSuccess) return true;

    // Surface the server's message if available
    final msg = (res.errorMessage.isNotEmpty)
        ? res.errorMessage
        : (res.responseData is Map<String, dynamic> && (res.responseData as Map<String, dynamic>).containsKey('error'))
        ? (res.responseData as Map<String, dynamic>)['error']?.toString() ?? 'Cancellation failed'
        : 'Cancellation failed';
    throw Exception(msg);
  }



Future<bool> getIsAiActive() async {
    try {
      final res = await _net.getRequest(AppUrls.subscriptionDetails);
      if (!res.isSuccess || res.responseData == null) return false;

      final data  = res.responseData as Map<String, dynamic>;
      final ai    = (data['ai'] as Map<String, dynamic>?) ?? const {};
      final plan  = (data['plan'] as Map<String, dynamic>?) ?? const {};

      final aiState = (ai['state'] ?? '').toString().toLowerCase();
      final planAi  = (plan['ai_assistant'] ?? '').toString().toLowerCase();

      // Treat both "included" and "addon_active" as active (keep "active" for backward compat)
      final activeByAiState = const {'included', 'addon_active', 'active'}.contains(aiState);
      final activeByPlan    = planAi == 'included';
      return activeByAiState || activeByPlan;
    } catch (e) {
      debugPrint('getIsAiActive error: $e');
      return false;
    }
  }

  Future<({String aiState, String planAi})> getAiFlags() async {
    final res = await _net.getRequest(AppUrls.subscriptionDetails);
    if (!res.isSuccess || res.responseData == null) {
      return (aiState: '', planAi: '');
    }
    final data = res.responseData as Map<String, dynamic>;
    final ai   = (data['ai'] as Map<String, dynamic>?) ?? const {};
    final plan = (data['plan'] as Map<String, dynamic>?) ?? const {};
    return (
    aiState: (ai['state'] ?? '').toString().toLowerCase(),
    planAi:  (plan['ai_assistant'] ?? '').toString().toLowerCase(),
    );
  }



  /// Fetch the weekly report from /api/ai-report/
  Future<AiReport> getWeeklyReport() async {
    final res = await _net.getRequest(AppUrls.aiReport);
    if (!res.isSuccess || res.responseData == null) {
      throw Exception(res.errorMessage.isNotEmpty
          ? res.errorMessage
          : 'Failed to load AI report');
    }
    return AiReport.fromJson(res.responseData as Map<String, dynamic>);
  }

  /// Save the provider’s chosen AI partner.
  /// Backend: POST /api/ai-report/ with { "partner_name": "<Amara|Zuri|Malik|Dre>" }
  Future<void> setPartner(String partner) async {
    final body = {'partner_name': partner};
    final res = await _net.postRequest(AppUrls.aiReport, body: body);
    if (!res.isSuccess) {
      throw Exception(
          res.errorMessage.isNotEmpty ? res.errorMessage : 'Failed to set partner');
    }
  }

  /// Creates a hosted Checkout session for the AI add-on.
  /// Expects { "url": "https://checkout.stripe.com/..." }
  Future<String?> createAiAddonCheckoutSession() async {
    try {
      final res = await _net.postRequest(
        AppUrls.checkoutAiAddon,
        body: const {}, // <- important
        // ensure NetworkCaller sets Content-Type: application/json
      );
      if (!res.isSuccess || res.responseData == null) return null;
      final data = res.responseData as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      debugPrint('createAiAddonCheckoutSession error: $e');
      return null;
    }
  }
}
