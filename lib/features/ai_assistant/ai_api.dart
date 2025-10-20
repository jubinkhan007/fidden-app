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
  Future<bool> getIsAiActive() async {
    try {
      final res = await _net.getRequest(AppUrls.subscriptionDetails);
      if (!res.isSuccess || res.responseData == null) return false;

      final data = res.responseData as Map<String, dynamic>;
      final ai = (data['ai'] as Map<String, dynamic>?) ?? const {};
      final plan = (data['plan'] as Map<String, dynamic>?) ?? const {};

      final aiState = (ai['state'] ?? '').toString().toLowerCase();
      final planAi = (plan['ai_assistant'] ?? '').toString().toLowerCase();

      final activeByAiState = aiState == 'included' || aiState == 'active';
      final activeByPlan = planAi == 'included';
      return activeByAiState || activeByPlan;
    } catch (e) {
      debugPrint('getIsAiActive error: $e');
      return false;
    }
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
      final res = await _net.postRequest(AppUrls.checkoutAiAddon);
      if (!res.isSuccess || res.responseData == null) return null;
      final data = res.responseData as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      debugPrint('createAiAddonCheckoutSession error: $e');
      return null;
    }
  }
}
