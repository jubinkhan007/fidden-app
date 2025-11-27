// Design Request Model
class DesignRequest {
  final int id;
  final int shop;
  final DesignRequestUser user;
  final String description;
  final String placement;
  final String sizeApprox;
  final String status; // pending, approved, discussing, rejected
  final int? booking;
  final DateTime createdAt;

  DesignRequest({
    required this.id,
    required this.shop,
    required this.user,
    required this.description,
    required this.placement,
    required this.sizeApprox,
    required this.status,
    this.booking,
    required this.createdAt,
  });

  factory DesignRequest.fromJson(Map<String, dynamic> json) {
    return DesignRequest(
      id: json['id'] as int,
      shop: json['shop'] as int,
      user: DesignRequestUser.fromJson(json['user'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      sizeApprox: json['size_approx'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      booking: json['booking'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class DesignRequestUser {
  final int id;
  final String name;
  final String email;

  DesignRequestUser({required this.id, required this.name, required this.email});

  factory DesignRequestUser.fromJson(Map<String, dynamic> json) {
    return DesignRequestUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}
