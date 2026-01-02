/// Walk-In Queue models for barber dashboard

/// Status enum for walk-in entries
enum WalkInStatus {
  waiting,
  in_service,
  completed,
  no_show,
  cancelled;

  static WalkInStatus fromString(String value) {
    return WalkInStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase().replaceAll('-', '_'),
      orElse: () => WalkInStatus.waiting,
    );
  }

  String toApiString() => name;
}

/// Single walk-in entry in the queue
class WalkInEntry {
  final int id;
  final int shopId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final int? userId;
  final String? userName;
  final int? serviceId;
  final String? serviceName;
  final double? servicePrice;
  final int position;
  final int estimatedWaitMinutes;
  final String waitTimeDisplay;
  final WalkInStatus status;
  final String? notes;
  final DateTime joinedAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  // Payment fields (populated after checkout)
  final int? slotBooking;
  final double amountPaid;
  final double tipsAmount;
  final String? paymentMethod; // 'cash', 'card', 'other'
  final String? serviceNiche;

  WalkInEntry({
    required this.id,
    required this.shopId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.userId,
    this.userName,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    required this.position,
    required this.estimatedWaitMinutes,
    required this.waitTimeDisplay,
    required this.status,
    this.notes,
    required this.joinedAt,
    this.calledAt,
    this.completedAt,
    this.slotBooking,
    this.amountPaid = 0,
    this.tipsAmount = 0,
    this.paymentMethod,
    this.serviceNiche,
  });

  factory WalkInEntry.fromJson(Map<String, dynamic> json) {
    return WalkInEntry(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      customerName: json['customer_name'] as String? ?? 'Walk-in',
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      userId: json['user'] as int?,
      userName: json['user_name'] as String?,
      serviceId: json['service'] as int?,
      serviceName: json['service_name'] as String?,
      servicePrice: json['service_price'] != null
          ? double.tryParse(json['service_price'].toString())
          : null,
      position: json['position'] as int? ?? 0,
      estimatedWaitMinutes: json['estimated_wait_minutes'] as int? ?? 0,
      waitTimeDisplay:
          json['wait_time_display'] as String? ??
          '${json['wait_time_minutes'] ?? 0} min',
      status: WalkInStatus.fromString(json['status'] as String? ?? 'waiting'),
      notes: json['notes'] as String?,
      joinedAt:
          DateTime.tryParse(json['joined_at']?.toString() ?? '') ??
          DateTime.now(),
      calledAt: json['called_at'] != null
          ? DateTime.tryParse(json['called_at'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      slotBooking: json['slot_booking'] as int?,
      amountPaid: double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0,
      tipsAmount: double.tryParse(json['tips_amount']?.toString() ?? '0') ?? 0,
      paymentMethod: json['payment_method'] as String?,
      serviceNiche: json['service_niche'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'user': userId,
      'user_name': userName,
      'service': serviceId,
      'service_name': serviceName,
      'service_price': servicePrice,
      'position': position,
      'estimated_wait_minutes': estimatedWaitMinutes,
      'wait_time_display': waitTimeDisplay,
      'status': status.toApiString(),
      'notes': notes,
      'joined_at': joinedAt.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'slot_booking': slotBooking,
      'amount_paid': amountPaid,
      'tips_amount': tipsAmount,
      'payment_method': paymentMethod,
      'service_niche': serviceNiche,
    };
  }

  /// Check if customer is currently being served
  bool get isBeingServed => status == WalkInStatus.in_service;

  /// Check if waiting in queue
  bool get isWaiting => status == WalkInStatus.waiting;
}

/// Response wrapper for walk-in queue list
class WalkInQueueResponse {
  final List<WalkInEntry> queue;
  final int waitingCount;
  final int inServiceCount;
  final int totalInQueue;

  WalkInQueueResponse({
    required this.queue,
    required this.waitingCount,
    required this.inServiceCount,
    required this.totalInQueue,
  });

  factory WalkInQueueResponse.fromJson(Map<String, dynamic> json) {
    return WalkInQueueResponse(
      queue: (json['queue'] as List? ?? [])
          .map((e) => WalkInEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      waitingCount: json['waiting_count'] as int? ?? 0,
      inServiceCount: json['in_service_count'] as int? ?? 0,
      totalInQueue: json['total_in_queue'] as int? ?? 0,
    );
  }

  /// Get only waiting customers
  List<WalkInEntry> get waitingQueue =>
      queue.where((e) => e.status == WalkInStatus.waiting).toList();

  /// Get customer currently being served
  List<WalkInEntry> get inService =>
      queue.where((e) => e.status == WalkInStatus.in_service).toList();
}
