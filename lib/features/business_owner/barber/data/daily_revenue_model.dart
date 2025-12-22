class DailyRevenueResponse {
  final String date;
  final double totalRevenue;
  final int bookingCount;
  final double averageBookingValue;
  final Map<String, dynamic>? filtersApplied;

  DailyRevenueResponse({
    required this.date,
    required this.totalRevenue,
    required this.bookingCount,
    required this.averageBookingValue,
    this.filtersApplied,
  });

  factory DailyRevenueResponse.fromJson(Map<String, dynamic> json) {
    return DailyRevenueResponse(
      date: json['date'] as String,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      bookingCount: json['booking_count'] as int,
      averageBookingValue: (json['average_booking_value'] as num).toDouble(),
      filtersApplied: json['filters_applied'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_revenue': totalRevenue,
      'booking_count': bookingCount,
      'average_booking_value': averageBookingValue,
      'filters_applied': filtersApplied,
    };
  }
}
