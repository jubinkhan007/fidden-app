// lib/features/ai/ai_api.dart
//
// Uses NetworkCaller (+ AuthService inside it) to auto-attach the token.
// Endpoints come from AppUrls.*
// Requires: intl

import 'dart:convert';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:intl/intl.dart';

/// --- Models ---

/// --- Custom Exception ---
class AiApiException implements Exception {
  final String message;
  final int? statusCode;
  AiApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'AiApiException(statusCode: $statusCode, message: $message)';
}

class WeeklySummary {
  final String id;
  final DateTime weekStartDate;
  final DateTime weekEndDate;

  final int totalAppointments;
  final double revenueGenerated;
  final double rebookingRate;
  final double growthRate;
  final int noShowsFilled;

  final String? topService;
  final int? topServiceCount;

  final int openSlotsNextWeek;
  final double forecastEstimatedRevenue;

  final String aiMotivation;
  final AiRecommendations recommendations;

  final List<String> deliveredChannels;
  final String? deepLink;

  final DateTime createdAt;

  // --- AI subscription info ---
  final String? aiState; // "addon_active", "included", "addon_inactive", "locked", etc.
  final bool legacy500;
  final String? aiPriceId; // Stripe price id (used to infer plan)

  WeeklySummary({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalAppointments,
    required this.revenueGenerated,
    required this.rebookingRate,
    required this.growthRate,
    required this.noShowsFilled,
    this.topService,
    this.topServiceCount,
    required this.openSlotsNextWeek,
    required this.forecastEstimatedRevenue,
    required this.aiMotivation,
    required this.recommendations,
    required this.deliveredChannels,
    this.deepLink,
    required this.createdAt,
    this.aiState,
    required this.legacy500,
    this.aiPriceId,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0.0);
    int _i(dynamic v) =>
        (v is int) ? v : (int.tryParse('$v') ?? 0);

    final rec = j['ai_recommendations'] ?? {};
    final aiPayload = j['ai'] ?? {};

    return WeeklySummary(
      id: (j['id'] ?? '').toString(),
      weekStartDate: DateTime.parse(j['week_start_date']),
      weekEndDate: DateTime.parse(j['week_end_date']),
      totalAppointments: _i(j['total_appointments']),
      revenueGenerated: _d(j['revenue_generated']),
      rebookingRate: _d(j['rebooking_rate']),
      growthRate: _d(j['growth_rate']),
      noShowsFilled: _i(j['no_shows_filled']),
      topService: j['top_service']?.toString(),
      topServiceCount: j['top_service_count'] == null
          ? null
          : _i(j['top_service_count']),
      openSlotsNextWeek: _i(j['open_slots_next_week']),
      forecastEstimatedRevenue:
      _d(j['forecast_estimated_revenue']),
      aiMotivation: (j['ai_motivation'] ?? '').toString(),
      recommendations: AiRecommendations.fromJson(rec),
      deliveredChannels:
      (j['delivered_channels'] as List?)
          ?.map((e) => '$e')
          .toList() ??
          const [],
      deepLink: j['deep_link']?.toString(),
      createdAt: DateTime.parse(j['created_at']),
      aiState: aiPayload['state']?.toString(),
      legacy500: aiPayload['legacy'] == true,
      aiPriceId: aiPayload['price_id']?.toString(),
    );
  }
}

extension WeeklySummaryExtras on WeeklySummary {
  /// Infer plan from price id / state.
  String get planName {
    final id = (aiPriceId ?? '').toLowerCase();
    if (id.contains('icon') || aiState == 'included') {
      return 'Icon';
    }
    if (id.contains('momentum')) {
      return 'Momentum';
    }
    // Default / unknown -> treat as Foundation for gating
    return 'Foundation';
  }

  /// AI considered active when addon is on or included in plan.
  bool get isAiActive =>
      aiState == 'addon_active' || aiState == 'included';

  /// Only explicitly inactive / locked / null is treated as "can start checkout".
  bool get isAiInactive =>
      aiState == null ||
          aiState == 'addon_inactive' ||
          aiState == 'locked';

  /// Show cancel when add-on is active, non-Icon, non-legacy.
  bool get canCancelAi =>
      aiState == 'addon_active' && !legacy500 && planName != 'Icon';

  /// Show upgrade only when:
  /// - not legacy
  /// - on Foundation / Momentum
  /// - AI is explicitly not active.
  bool get canPurchaseAi {
    if (legacy500) return false;

    // Never show upgrade if backend says it's active or included.
    if (aiState == 'addon_active' || aiState == 'included') {
      return false;
    }

    if (planName != 'Foundation' && planName != 'Momentum') {
      return false;
    }

    // Only allow when backend clearly reports "off" / "locked" / nothing.
    return isAiInactive;
  }
}

class GeneratedCaptionResult {
  final bool ok;
  final String caption;
  final String shareUrl;
  final String deepLink;
  final bool previewOnly;

  GeneratedCaptionResult({
    required this.ok,
    required this.caption,
    required this.shareUrl,
    required this.deepLink,
    required this.previewOnly,
  });

  factory GeneratedCaptionResult.fromJson(Map<String, dynamic> j) {
    return GeneratedCaptionResult(
      ok: j['ok'] == true,
      caption: (j['caption'] ?? '').toString(),
      shareUrl: (j['share_url'] ?? '').toString(),
      deepLink: (j['deep_link'] ?? '').toString(),
      previewOnly: j['preview_only'] == true,
    );
  }
}

class AiRecommendations {
  final RecCard? revenueBooster;
  final RecCard? retentionPlay;
  final Forecast? forecast;

  AiRecommendations({this.revenueBooster, this.retentionPlay, this.forecast});

  factory AiRecommendations.fromJson(Map<String, dynamic> j) {
    return AiRecommendations(
      revenueBooster: j['revenue_booster'] == null
          ? null
          : RecCard.fromJson(j['revenue_booster']),
      retentionPlay: j['retention_play'] == null
          ? null
          : RecCard.fromJson(j['retention_play']),
      forecast: j['forecast'] == null
          ? null
          : Forecast.fromJson(j['forecast']),
    );
  }
}

class RecCard {
  final String headline;
  final String text;
  final String ctaLabel;
  final String ctaAction;

  RecCard({
    required this.headline,
    required this.text,
    required this.ctaLabel,
    required this.ctaAction,
  });

  factory RecCard.fromJson(Map<String, dynamic> j) => RecCard(
    headline: (j['headline'] ?? '').toString(),
    text: (j['text'] ?? '').toString(),
    ctaLabel: (j['cta_label'] ?? '').toString(),
    ctaAction: (j['cta_action'] ?? '').toString(),
  );
}

class Forecast {
  final int openSlotsNextWeek;
  final double forecastEstimatedRevenue;

  Forecast({
    required this.openSlotsNextWeek,
    required this.forecastEstimatedRevenue,
  });

  factory Forecast.fromJson(Map<String, dynamic> j) {
    double _d(dynamic v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0.0);
    int _i(dynamic v) =>
        (v is int) ? v : (int.tryParse('$v') ?? 0);
    return Forecast(
      openSlotsNextWeek: _i(j['open_slots_next_week']),
      forecastEstimatedRevenue:
      _d(j['forecast_estimated_revenue']),
    );
  }
}

/// --- API Client ---

class AiApi {
  final _net = NetworkCaller();

  Future<WeeklySummary> fetchLatest() async {
    final resp = await _net.getRequest(AppUrls.aiReport);
    if (!resp.isSuccess) {
      String errorMsg =
          resp.errorMessage ?? 'Failed to load summary';
      if (resp.responseData is Map<String, dynamic> &&
          resp.responseData['detail'] != null) {
        errorMsg = resp.responseData['detail'].toString();
      }
      throw AiApiException(
        message: errorMsg,
        statusCode: resp.statusCode,
      );
    }

    final Map<String, dynamic> data =
    (resp.responseData is Map<String, dynamic>)
        ? resp.responseData
        : jsonDecode(resp.responseData as String)
    as Map<String, dynamic>;

    return WeeklySummary.fromJson(data);
  }

  Future<GeneratedCaptionResult>
  generateMarketingCaptionWithResult(
      String summaryId, {
        bool previewOnly = false,
      }) async {
    var base = AppUrls.generateContent;
    if (!base.endsWith('/')) base = '$base/';
    final endpoint = '${base}generate_marketing_caption/';

    final body = {
      'summary_id': summaryId,
      'preview_only': previewOnly,
    };

    final resp =
    await _net.postRequest(endpoint, body: body);
    if (!resp.isSuccess) {
      throw Exception(
        'Failed to generate caption: '
            '${resp.statusCode} '
            '${resp.responseData ?? resp.errorMessage}',
      );
    }

    final Map<String, dynamic> data =
    (resp.responseData is Map<String, dynamic>)
        ? resp.responseData
        : jsonDecode(resp.responseData as String)
    as Map<String, dynamic>;

    return GeneratedCaptionResult.fromJson(data);
  }

  Future<bool> triggerAction({
    required String summaryId,
    required String action,
    Map<String, dynamic>? extraPayload,
  }) async {
    var base = AppUrls.generateContent;
    if (!base.endsWith('/')) base = '$base/';
    final endpoint = '$base$action/';

    final body = {
      'summary_id': summaryId,
      if (extraPayload != null) ...extraPayload,
    };

    final resp =
    await _net.postRequest(endpoint, body: body);
    return resp.isSuccess;
  }

  Future<bool> generateMarketingCaption(String summaryId) =>
      triggerAction(
        summaryId: summaryId,
        action: 'generate_marketing_caption',
      );

  Future<bool> sendLoyaltySms(String summaryId) =>
      triggerAction(
        summaryId: summaryId,
        action: 'send_loyalty_sms',
      );

  Future<void> cancelAiAddon() async {
    final resp =
    await _net.postRequest(AppUrls.cancelAiAddon, body: {});
    if (!resp.isSuccess) {
      String errorMsg =
          resp.errorMessage ?? 'Failed to cancel add-on';
      if (resp.responseData is Map<String, dynamic> &&
          resp.responseData['error'] != null) {
        errorMsg =
            resp.responseData['error'].toString();
      }
      throw AiApiException(
        message: errorMsg,
        statusCode: resp.statusCode,
      );
    }
  }
}

/// --- Formatting helpers ---
final _moneyFmt = NumberFormat.currency(
  locale: 'en_BD',
  symbol: '৳',
  decimalDigits: 0,
);
String bdMoney(num v) => _moneyFmt.format(v);
String signedPct(num v) =>
    (v >= 0) ? '+${v.toStringAsFixed(0)}%' : '${v.toStringAsFixed(0)}%';
