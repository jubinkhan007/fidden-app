class IDVerificationRequest {
  final int id;
  final int shopId;
  final User user;
  final int? bookingId;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  IDVerificationRequest({
    required this.id,
    required this.shopId,
    required this.user,
    this.bookingId,
    this.frontImageUrl,
    this.backImageUrl,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory IDVerificationRequest.fromJson(Map<String, dynamic> json) {
    return IDVerificationRequest(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      bookingId: json['booking'] as int?,
      frontImageUrl: json['front_image'] as String?,
      backImageUrl: json['back_image'] as String?,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'user': user.toJson(),
      if (bookingId != null) 'booking': bookingId,
      if (frontImageUrl != null) 'front_image': frontImageUrl,
      if (backImageUrl != null) 'back_image': backImageUrl,
      'status': status,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending_upload';
  bool get isUnderReview => status == 'under_review';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  
  String get customerName => user.name;
  String get customerEmail => user.email;
}

// Reusing User model
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
