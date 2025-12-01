class Consultation {
  final int id;
  final int shopId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String date;
  final String time;
  final int durationMinutes;
  final String status;
  final String notes;
  final List<String> designReferenceImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.shopId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.status,
    required this.notes,
    required this.designReferenceImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String? ?? '',
      date: json['date'] as String,
      time: json['time'] as String,
      durationMinutes: json['duration_minutes'] as int,
      status: json['status'] as String,
      notes: json['notes'] as String? ?? '',
      designReferenceImages: json['design_reference_images'] != null
          ? List<String>.from(json['design_reference_images'] as List)
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'date': date,
      'time': time,
      'duration_minutes': durationMinutes,
      'status': status,
      'notes': notes,
      'design_reference_images': designReferenceImages,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isScheduled => status == 'scheduled';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNoShow => status == 'no_show';
  
  DateTime get dateTime {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}
