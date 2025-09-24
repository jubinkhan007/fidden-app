// lib/features/business_owner/coupons/data/coupon_model.dart
class Coupon {
  final int id;
  final String code;
  final String description;
  final double amount;            // normalized to double
  final bool inPercentage;
  final String discountType;      // e.g. "percentage"
  final int shop;
  final List<int> services;       // multiple services
  final DateTime validityDate;    // parsed to DateTime
  final bool isActive;
  final int maxUsagePerUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.amount,
    required this.inPercentage,
    required this.discountType,
    required this.shop,
    required this.services,
    required this.validityDate,
    required this.isActive,
    required this.maxUsagePerUser,
    this.createdAt,
    this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    // amount can be "20.00" (String) or 20/20.0 (num)
    double _parseAmount(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    List<int> _parseServices(dynamic v) {
      if (v is List) {
        return v.map((e) {
          if (e is int) return e;
          if (e is String) return int.tryParse(e) ?? 0;
          return 0;
        }).where((id) => id > 0).toList();
      }
      // some legacy shapes may send single service id:
      if (v is int) return [v];
      if (v is String) {
        final id = int.tryParse(v);
        return id == null ? <int>[] : <int>[id];
      }
      return <int>[];
    }

    DateTime? _parseTime(String? s) {
      if (s == null || s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    // validity_date from GET is "YYYY-MM-DD"
    final validity = json['validity_date']?.toString();

    return Coupon(
      id: json['id'] ?? 0,
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _parseAmount(json['amount']),
      inPercentage: json['in_percentage'] == true,
      discountType: json['discount_type']?.toString() ?? '',
      shop: json['shop'] is int ? json['shop'] : int.tryParse('${json['shop']}') ?? 0,
      services: _parseServices(json['services']),
      validityDate: validity != null
          ? DateTime.parse(validity) // "2025-12-31"
          : DateTime.now(),
      isActive: json['is_active'] == true,
      maxUsagePerUser: (json['max_usage_per_user'] is int)
          ? json['max_usage_per_user']
          : int.tryParse('${json['max_usage_per_user']}') ?? 1,
      createdAt: _parseTime(json['created_at']?.toString()),
      updatedAt: _parseTime(json['updated_at']?.toString()),
    );
  }
}

/// Slim model for create/update requests (what the API expects in body)
class CouponDraft {
  final String description;
  final double amount;
  final bool inPercentage;
  final int shop;
  final List<int> services;
  final DateTime validityDate;
  final int maxUsagePerUser;
  final bool? isActive; // only needed for update

  CouponDraft({
    required this.description,
    required this.amount,
    required this.inPercentage,
    required this.shop,
    required this.services,
    required this.validityDate,
    required this.maxUsagePerUser,
    this.isActive,
  });

  Map<String, dynamic> toCreateJson() => {
    "description": description,
    "amount": amount, // number
    "in_percentage": inPercentage,
    "shop": shop,
    "services": services,
    "validity_date":
    "${validityDate.year.toString().padLeft(4, '0')}-${validityDate.month.toString().padLeft(2, '0')}-${validityDate.day.toString().padLeft(2, '0')}",
    "max_usage_per_user": maxUsagePerUser,
  };

  Map<String, dynamic> toUpdateJson() {
    // You can include only fields that are editable server-side
    final body = toCreateJson();
    if (isActive != null) body["is_active"] = isActive;
    return body;
  }
}
