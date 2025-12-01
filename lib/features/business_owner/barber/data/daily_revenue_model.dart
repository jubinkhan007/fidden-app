class DailyRevenueResponse {
  final String date;
  final double totalRevenue;
  final int bookingCount;
  final double averageBookingValue;

  DailyRevenueResponse({
    required this.date,
    required this.totalRevenue,
    required this.bookingCount,
    required this.averageBookingValue,
  });

  factory DailyRevenueResponse.fromJson(Map<String, dynamic> json) {
    return DailyRevenueResponse(
      date: json['date'] as String,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      bookingCount: json['booking_count'] as int,
      averageBookingValue: (json['average_booking_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_revenue': totalRevenue,
      'booking_count': bookingCount,
      'average_booking_value': averageBookingValue,
    };
  }
}
