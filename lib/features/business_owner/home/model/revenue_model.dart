// lib/features/business_owner/home/models/revenue_models.dart
class RevenuePoint {
  final DateTime ts;
  final double revenue;

  RevenuePoint({required this.ts, required this.revenue});

  factory RevenuePoint.fromJson(Map<String, dynamic> j) => RevenuePoint(
    ts: DateTime.parse(j['timestamp'] as String),
    revenue: double.tryParse('${j['revenue']}') ?? 0.0,
  );
}

class RevenueResponse {
  final double totalRevenue;
  final List<RevenuePoint> points;

  RevenueResponse({required this.totalRevenue, required this.points});

  factory RevenueResponse.fromJson(Map<String, dynamic> j) => RevenueResponse(
    totalRevenue: (j['total_revenue'] is num)
        ? (j['total_revenue'] as num).toDouble()
        : double.tryParse('${j['total_revenue']}') ?? 0.0,
    points: (j['revenues'] as List? ?? const [])
        .map((e) => RevenuePoint.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
