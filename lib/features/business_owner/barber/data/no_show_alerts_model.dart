class NoShowAlertsResponse {
  final int count;
  final int days;
  final List<NoShowCustomer> noShows;

  NoShowAlertsResponse({
    required this.count,
    required this.days,
    required this.noShows,
  });

  factory NoShowAlertsResponse.fromJson(Map<String, dynamic> json) {
    return NoShowAlertsResponse(
      count: json['count'] as int,
      days: json['days'] as int,
      noShows: (json['no_shows'] as List)
          .map((item) => NoShowCustomer.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'days': days,
      'no_shows': noShows.map((item) => item.toJson()).toList(),
    };
  }
}

class NoShowCustomer {
  final int id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String serviceName;
  final String scheduledDate;
  final String scheduledTime;
  final DateTime createdAt;

  NoShowCustomer({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.serviceName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.createdAt,
  });

  factory NoShowCustomer.fromJson(Map<String, dynamic> json) {
    return NoShowCustomer(
      id: json['id'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String,
      serviceName: json['service_name'] as String,
      scheduledDate: json['scheduled_date'] as String,
      scheduledTime: json['scheduled_time'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
