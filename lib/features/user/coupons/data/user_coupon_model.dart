import 'package:intl/intl.dart';

class UserCoupon {
  final int id;
  final String code;
  final String description;
  final double amount;        // normalized number
  final bool inPercentage;    // % or fixed
  final String discountType;  // "percentage" | "amount"
  final int shop;
  final List<int> services;
  final DateTime validityDate;
  final bool isActive;
  final int maxUsagePerUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserCoupon({
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

  factory UserCoupon.fromJson(Map<String, dynamic> json) {
    double _num(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    List<int> _services(dynamic v) {
      if (v is List) {
        return v.map((e) => e is int ? e : int.tryParse('$e') ?? 0)
            .where((x) => x > 0).toList();
      }
      return const <int>[];
    }

    DateTime? _ts(dynamic s) => s == null ? null : DateTime.tryParse('$s');

    return UserCoupon(
      id: json['id'] ?? 0,
      code: '${json['code'] ?? ''}',
      description: '${json['description'] ?? ''}',
      amount: _num(json['amount']),
      inPercentage: json['in_percentage'] == true,
      discountType: '${json['discount_type'] ?? ''}',
      shop: (json['shop'] is int) ? json['shop'] : int.tryParse('${json['shop']}') ?? 0,
      services: _services(json['services']),
      validityDate: DateTime.parse('${json['validity_date']}'),
      isActive: json['is_active'] == true,
      maxUsagePerUser: (json['max_usage_per_user'] is int)
          ? json['max_usage_per_user']
          : int.tryParse('${json['max_usage_per_user']}') ?? 1,
      createdAt: _ts(json['created_at']),
      updatedAt: _ts(json['updated_at']),
    );
  }

  String get shortAmountLabel {
    if (inPercentage) {
      final whole = amount == amount.truncateToDouble();
      return '${amount.toStringAsFixed(whole ? 0 : 2)}%';
    }
    final f = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return f.format(amount);
  }
}
