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

class DesignRequest {
  final int id;
  final int shopId;
  final User user;
  final String description;
  final String placement;
  final String sizeApprox;
  final String status;
  final DateTime createdAt;

  DesignRequest({
    required this.id,
    required this.shopId,
    required this.user,
    required this.description,
    required this.placement,
    required this.sizeApprox,
    required this.status,
    required this.createdAt,
  });

  factory DesignRequest.fromJson(Map<String, dynamic> json) {
    return DesignRequest(
      id: json['id'] as int,
      shopId: json['shop'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      description: json['description'] as String,
      placement: json['placement'] as String? ?? '',
      sizeApprox: json['size_approx'] as String? ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'user': user.toJson(),
      'description': description,
      'placement': placement,
      'size_approx': sizeApprox,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
