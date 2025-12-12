// lib/features/user/booking/data/user_booking_model.dart
import 'dart:convert';

BookingListResponse bookingListResponseFromJson(String str) =>
    BookingListResponse.fromJson(json.decode(str));

class BookingListResponse {
  final String? next;      // may be null
  final String? previous;  // may be null
  final List<BookingItem> results;

  BookingListResponse({
    required this.next,
    required this.previous,
    required this.results,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ✅ Add this
  Map<String, dynamic> toJson() => {
        'next': next,
        'previous': previous,
        'results': results.map((e) => e.toJson()).toList(),
      };
}

class UserBookingsModel {
  final int count;
  final String? next;
  final String? previous;
  final List<BookingItem> results;

  UserBookingsModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory UserBookingsModel.fromJson(Map<String, dynamic> json) =>
      UserBookingsModel(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<BookingItem>.from(
          (json["results"] as List<dynamic>? ?? [])
              .map((x) => BookingItem.fromJson(x as Map<String, dynamic>)),
        ),
      );

  // (Optional) only if you ever want to cache this shape directly:
  Map<String, dynamic> toJson() => {
        'count': count,
        'next': next,
        'previous': previous,
        'results': results.map((e) => e.toJson()).toList(),
      };
}

class AddOnService {
  final String title;
  final String duration; // minutes as string

  AddOnService({
    required this.title,
    required this.duration,
  });

  factory AddOnService.fromJson(Map<String, dynamic> json) {
    return AddOnService(
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'duration': duration,
      };
}

class BookingItem {
  final int id;
  final int user;
  final String userEmail;
  final int shop;
  final int serviceId;
  final String shopName;
  final String shopAddress;
  final String shopImg;
  final int slot;
  final String slotTimeIso;      // keep ISO string (as you do)
  final String serviceTitle;
  final String serviceDuration;  // minutes as string from API
  final List<AddOnService> addOnServices; // Add-on services
  final String status;           // "active" / "completed" / "cancelled" etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final double avgRating;
  final int totalReviews;
  bool isReviewed;
  final String? shopTimezone; // Shop's IANA timezone (e.g., "America/New_York")
  
  // Checkout/Payment fields
  final String? depositStatus;      // 'held', 'credited', 'forfeited', null
  final double? depositAmount;      // Amount held as deposit
  final double? servicePrice;       // Total service price
  final double? remainingAmount;    // servicePrice - depositAmount
  final bool checkoutInitiated;     // True when owner has initiated checkout

  BookingItem({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.shop,
    required this.serviceId,
    required this.shopName,
    required this.shopAddress,
    required this.shopImg,
    required this.slot,
    required this.slotTimeIso,
    required this.serviceTitle,
    required this.serviceDuration,
    this.addOnServices = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.avgRating,
    required this.totalReviews,
    this.isReviewed = false,
    this.shopTimezone,
    // Checkout fields
    this.depositStatus,
    this.depositAmount,
    this.servicePrice,
    this.remainingAmount,
    this.checkoutInitiated = false,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    double _toDouble(v) => v is num ? v.toDouble() : double.tryParse("$v") ?? 0.0;
    double? _toDoubleOrNull(v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse("$v"));
    int _toInt(v) => v is num ? v.toInt() : int.tryParse("$v") ?? 0;

    // Parse add-on services
    final List<AddOnService> addOns = [];
    if (json['add_on_services'] is List) {
      addOns.addAll(
        (json['add_on_services'] as List)
            .map((e) => AddOnService.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    return BookingItem(
      id: _toInt(json['id']),
      user: _toInt(json['user']),
      userEmail: json['user_email'] ?? '',
      shop: _toInt(json['shop']),
      serviceId: _toInt(json['service_id']),
      shopName: json['shop_name'] ?? '',
      shopAddress: json['shop_address'] ?? '',
      shopImg: json['shop_img'] ?? '',
      slot: _toInt(json['slot']),
      slotTimeIso: (json['slot_time'] ?? '').toString(),
      serviceTitle: json['service_title'] ?? '',
      serviceDuration: json['service_duration'] ?? '',
      addOnServices: addOns,
      status: (json['status'] ?? '').toString().toLowerCase(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      avgRating: _toDouble(json['avg_rating']),
      totalReviews: _toInt(json['total_reviews']),
      isReviewed: json["is_reviewed"] ?? false,
      shopTimezone: json['shop_timezone']?.toString(),
      // Checkout fields
      depositStatus: json['deposit_status']?.toString(),
      depositAmount: _toDoubleOrNull(json['deposit_amount']),
      servicePrice: _toDoubleOrNull(json['service_price']),
      remainingAmount: _toDoubleOrNull(json['remaining_amount']),
      checkoutInitiated: json['checkout_initiated'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'user_email': userEmail,
        'shop': shop,
        'service_id': serviceId,
        'shop_name': shopName,
        'shop_address': shopAddress,
        'shop_img': shopImg,
        'slot': slot,
        'slot_time': slotTimeIso,
        'service_title': serviceTitle,
        'service_duration': serviceDuration,
        'add_on_services': addOnServices.map((e) => e.toJson()).toList(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'avg_rating': avgRating,
        'total_reviews': totalReviews,
        'is_reviewed': isReviewed,
        'shop_timezone': shopTimezone,
        // Checkout fields
        'deposit_status': depositStatus,
        'deposit_amount': depositAmount,
        'service_price': servicePrice,
        'remaining_amount': remainingAmount,
        'checkout_initiated': checkoutInitiated,
      };

  BookingItem copyWith({
    String? status,
    String? depositStatus,
    bool? checkoutInitiated,
  }) {
    return BookingItem(
      id: id,
      user: user,
      userEmail: userEmail,
      shop: shop,
      serviceId: serviceId,
      shopName: shopName,
      shopAddress: shopAddress,
      shopImg: shopImg,
      slot: slot,
      slotTimeIso: slotTimeIso,
      serviceTitle: serviceTitle,
      serviceDuration: serviceDuration,
      addOnServices: addOnServices,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      avgRating: avgRating,
      totalReviews: totalReviews,
      isReviewed: isReviewed,
      shopTimezone: shopTimezone,
      // Checkout fields
      depositStatus: depositStatus ?? this.depositStatus,
      depositAmount: depositAmount,
      servicePrice: servicePrice,
      remainingAmount: remainingAmount,
      checkoutInitiated: checkoutInitiated ?? this.checkoutInitiated,
    );
  }
}
