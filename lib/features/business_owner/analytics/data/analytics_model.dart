class AnalyticsModel {
  final String? totalRevenue;
  final int? totalBookings;
  final double? cancellationRate;
  final double? repeatCustomerRate;
  final double? averageRating;
  final String? topService;
  final String? peakBookingTime;
  final String? detail;
  final String? updatedAt;

  AnalyticsModel({
    this.totalRevenue,
    this.totalBookings,
    this.cancellationRate,
    this.repeatCustomerRate,
    this.averageRating,
    this.topService,
    this.peakBookingTime,
    this.detail,
    this.updatedAt,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      totalRevenue: json['total_revenue'],
      totalBookings: json['total_bookings'],
      cancellationRate: (json['cancellation_rate'] as num?)?.toDouble(),
      repeatCustomerRate: (json['repeat_customer_rate'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      topService: json['top_service'],
      peakBookingTime: json['peak_booking_time'],
      detail: json['detail'],
      updatedAt: json['updated_at'],
    );
  }
}