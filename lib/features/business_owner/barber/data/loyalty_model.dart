/// Loyalty Program models for barber dashboard

/// Reward types for loyalty program
enum RewardType {
  discountPercent,
  discountFixed,
  freeService;

  static RewardType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'discount_percent':
        return RewardType.discountPercent;
      case 'discount_fixed':
        return RewardType.discountFixed;
      case 'free_service':
        return RewardType.freeService;
      default:
        return RewardType.discountPercent;
    }
  }

  String toApiString() {
    switch (this) {
      case RewardType.discountPercent:
        return 'discount_percent';
      case RewardType.discountFixed:
        return 'discount_fixed';
      case RewardType.freeService:
        return 'free_service';
    }
  }

  String get displayName {
    switch (this) {
      case RewardType.discountPercent:
        return '% Discount';
      case RewardType.discountFixed:
        return 'Fixed Discount';
      case RewardType.freeService:
        return 'Free Service';
    }
  }
}

/// Loyalty program settings for a shop
class LoyaltyProgram {
  final int id;
  final int shopId;
  final bool isActive;
  final double pointsPerDollar;
  final int pointsForRedemption;
  final RewardType rewardType;
  final double rewardValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoyaltyProgram({
    required this.id,
    required this.shopId,
    required this.isActive,
    required this.pointsPerDollar,
    required this.pointsForRedemption,
    required this.rewardType,
    required this.rewardValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    // Helper to parse either num or String to double
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return LoyaltyProgram(
      id: json['id'] as int? ?? 0,
      shopId: json['shop'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      pointsPerDollar: parseDouble(json['points_per_dollar'], 1.0),
      pointsForRedemption: json['points_for_redemption'] as int? ?? 100,
      rewardType: RewardType.fromString(json['reward_type'] as String? ?? ''),
      rewardValue: parseDouble(json['reward_value'], 10.0),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'is_active': isActive,
      'points_per_dollar': pointsPerDollar,
      'points_for_redemption': pointsForRedemption,
      'reward_type': rewardType.toApiString(),
      'reward_value': rewardValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get reward display text
  String get rewardDisplayText {
    switch (rewardType) {
      case RewardType.discountPercent:
        return '${rewardValue.toStringAsFixed(0)}% off';
      case RewardType.discountFixed:
        return '\$${rewardValue.toStringAsFixed(2)} off';
      case RewardType.freeService:
        return 'Free service worth \$${rewardValue.toStringAsFixed(2)}';
    }
  }
}

/// Individual loyal customer with points
class LoyaltyCustomer {
  final int id;
  final int shopId;
  final int userId;
  final String? userName;
  final String? userEmail;
  final int pointsBalance;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final bool canRedeem;
  final DateTime? lastEarnedAt;
  final DateTime? lastRedeemedAt;

  LoyaltyCustomer({
    required this.id,
    required this.shopId,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.pointsBalance,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.canRedeem,
    this.lastEarnedAt,
    this.lastRedeemedAt,
  });

  factory LoyaltyCustomer.fromJson(Map<String, dynamic> json) {
    return LoyaltyCustomer(
      id: json['id'] as int? ?? 0,
      shopId: json['shop'] as int? ?? 0,
      userId: json['user'] as int? ?? 0,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      pointsBalance: json['points_balance'] as int? ?? 0,
      totalPointsEarned: json['total_points_earned'] as int? ?? 0,
      totalPointsRedeemed: json['total_points_redeemed'] as int? ?? 0,
      canRedeem: json['can_redeem'] as bool? ?? false,
      lastEarnedAt: json['last_earned_at'] != null 
          ? DateTime.tryParse(json['last_earned_at'].toString()) 
          : null,
      lastRedeemedAt: json['last_redeemed_at'] != null 
          ? DateTime.tryParse(json['last_redeemed_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shopId,
      'user': userId,
      'user_name': userName,
      'user_email': userEmail,
      'points_balance': pointsBalance,
      'total_points_earned': totalPointsEarned,
      'total_points_redeemed': totalPointsRedeemed,
      'can_redeem': canRedeem,
      'last_earned_at': lastEarnedAt?.toIso8601String(),
      'last_redeemed_at': lastRedeemedAt?.toIso8601String(),
    };
  }

  /// Display name or fallback to email
  String get displayName => userName?.isNotEmpty == true 
      ? userName! 
      : userEmail ?? 'Customer #$userId';
}

/// Response for listing loyal customers
class LoyaltyCustomersResponse {
  final int count;
  final List<LoyaltyCustomer> customers;

  LoyaltyCustomersResponse({
    required this.count,
    required this.customers,
  });

  factory LoyaltyCustomersResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyCustomersResponse(
      count: json['count'] as int? ?? 0,
      customers: (json['customers'] as List? ?? [])
          .map((e) => LoyaltyCustomer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Count of customers who can redeem rewards
  int get redeemableCount => customers.where((c) => c.canRedeem).length;
}

/// Response when adding points
class AddPointsResponse {
  final int pointsEarned;
  final int newBalance;
  final bool canRedeem;

  AddPointsResponse({
    required this.pointsEarned,
    required this.newBalance,
    required this.canRedeem,
  });

  factory AddPointsResponse.fromJson(Map<String, dynamic> json) {
    return AddPointsResponse(
      pointsEarned: json['points_earned'] as int? ?? 0,
      newBalance: json['new_balance'] as int? ?? 0,
      canRedeem: json['can_redeem'] as bool? ?? false,
    );
  }
}

/// Response when redeeming points
class RedeemResponse {
  final bool success;
  final RewardType rewardType;
  final double rewardValue;
  final int pointsRemaining;

  RedeemResponse({
    required this.success,
    required this.rewardType,
    required this.rewardValue,
    required this.pointsRemaining,
  });

  factory RedeemResponse.fromJson(Map<String, dynamic> json) {
    return RedeemResponse(
      success: json['success'] as bool? ?? false,
      rewardType: RewardType.fromString(json['reward_type'] as String? ?? ''),
      rewardValue: (json['reward_value'] as num?)?.toDouble() ?? 0,
      pointsRemaining: json['points_remaining'] as int? ?? 0,
    );
  }
}
