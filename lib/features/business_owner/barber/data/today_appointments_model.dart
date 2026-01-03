class TodayAppointmentsResponse {
  final String date;
  final int count;
  final AppointmentStats stats;
  final List<Appointment> appointments;

  TodayAppointmentsResponse({
    required this.date,
    required this.count,
    required this.stats,
    required this.appointments,
  });

  factory TodayAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    return TodayAppointmentsResponse(
      date: json['date'] as String,
      count: json['count'] as int,
      stats: AppointmentStats.fromJson(json['stats'] as Map<String, dynamic>),
      appointments: (json['appointments'] as List)
          .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'count': count,
      'stats': stats.toJson(),
      'appointments': appointments.map((a) => a.toJson()).toList(),
    };
  }
}

class AppointmentStats {
  final int confirmed;
  final int completed;
  final int cancelled;
  final int noShow;

  AppointmentStats({
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.noShow,
  });

  factory AppointmentStats.fromJson(Map<String, dynamic> json) {
    return AppointmentStats(
      confirmed: json['confirmed'] as int,
      completed: json['completed'] as int,
      cancelled: json['cancelled'] as int,
      noShow: json['no_show'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmed': confirmed,
      'completed': completed,
      'cancelled': cancelled,
      'no_show': noShow,
    };
  }
}

class Appointment {
  final int id;
  final String customerName;
  final String customerEmail;
  final String serviceName;
  final int serviceDuration;
  final String startTimeIso;
  final String endTimeIso;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final DateTime createdAt;
  final String? shopTimezone;
  final String? serviceNiche;

  Appointment({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.serviceName,
    required this.serviceDuration,
    required this.startTimeIso,
    required this.endTimeIso,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    this.shopTimezone,
    this.serviceNiche,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // DEBUG: Inspect raw JSON for timezone or alternative time fields
    // if (json['id'].toString() == '50')
    print('📅 RAW APPOINTMENT JSON (ID ${json['id']}): $json');
    return Appointment(
      id: json['id'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      serviceName: json['service_name'] as String,
      serviceDuration: json['service_duration'] as int,
      startTimeIso: json['start_time'] as String,
      endTimeIso: json['end_time'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      shopTimezone: json['shop_timezone'] as String?,
      serviceNiche: json['service_niche'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'service_name': serviceName,
      'service_duration': serviceDuration,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
