/// Nail Tech Dashboard models
import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';
export 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';

/// Dashboard summary metrics
class NailTechDashboard {
  final int todayAppointmentsCount;
  final double todayRevenue;
  final int pendingStyleRequests;
  final double repeatCustomerRate;
  final double weeklyTips;
  final int lookbookCount;

  NailTechDashboard({
    required this.todayAppointmentsCount,
    required this.todayRevenue,
    required this.pendingStyleRequests,
    required this.repeatCustomerRate,
    required this.weeklyTips,
    required this.lookbookCount,
  });

  factory NailTechDashboard.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return NailTechDashboard(
      todayAppointmentsCount: json['today_appointments_count'] as int? ?? 0,
      todayRevenue: parseDouble(json['today_revenue'], 0.0),
      pendingStyleRequests: json['pending_style_requests'] as int? ?? 0,
      repeatCustomerRate: parseDouble(json['repeat_customer_rate'], 0.0),
      weeklyTips: parseDouble(json['weekly_tips'], 0.0),
      lookbookCount: json['lookbook_count'] as int? ?? 0,
    );
  }
}

/// Lookbook response - uses GalleryItemModel from portfolio
class LookbookResponse {
  final int count;
  final List<GalleryItemModel> items;

  LookbookResponse({
    required this.count,
    required this.items,
  });

  factory LookbookResponse.fromJson(Map<String, dynamic> json) {
    return LookbookResponse(
      count: json['count'] as int? ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => GalleryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Style type statistics for bookings
class StyleTypeStats {
  final String styleType;
  final String styleDisplay;
  final int count;
  final double revenue;

  StyleTypeStats({
    required this.styleType,
    required this.styleDisplay,
    required this.count,
    required this.revenue,
  });

  factory StyleTypeStats.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return StyleTypeStats(
      styleType: json['style_type'] as String? ?? '',
      styleDisplay: json['style_display'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      revenue: parseDouble(json['revenue'], 0.0),
    );
  }
}

/// Response for bookings grouped by style
class BookingsByStyleResponse {
  final int periodDays;
  final List<StyleTypeStats> styles;

  BookingsByStyleResponse({
    required this.periodDays,
    required this.styles,
  });

  factory BookingsByStyleResponse.fromJson(Map<String, dynamic> json) {
    return BookingsByStyleResponse(
      periodDays: json['period_days'] as int? ?? 30,
      styles: (json['styles'] as List? ?? [])
          .map((e) => StyleTypeStats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total bookings across all styles
  int get totalBookings => styles.fold(0, (sum, s) => sum + s.count);

  /// Total revenue across all styles
  double get totalRevenue => styles.fold(0.0, (sum, s) => sum + s.revenue);
}

/// Tip summary
class TipSummary {
  final String period;
  final double totalTips;
  final int tipCount;
  final double averageTip;

  TipSummary({
    required this.period,
    required this.totalTips,
    required this.tipCount,
    required this.averageTip,
  });

  factory TipSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return TipSummary(
      period: json['period'] as String? ?? 'week',
      totalTips: parseDouble(json['total_tips'], 0.0),
      tipCount: json['tip_count'] as int? ?? 0,
      averageTip: parseDouble(json['average_tip'], 0.0),
    );
  }
}
