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
}

class BookingItem {
  final int id;
  final int user;
  final String userEmail;
  final int shop;
  final String shopName;
  final String shopAddress;
  final String shopImg;
  final int slot;
  final DateTime slotTime;
  final String serviceTitle;
  final String serviceDuration; // minutes as string from API
  final String status;          // "active" / "completed" / "cancelled" etc.
  final DateTime createdAt;
  final DateTime updatedAt;
  final double avgRating;
  final int totalReviews;

  BookingItem({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.shop,
    required this.shopName,
    required this.shopAddress,
    required this.shopImg,
    required this.slot,
    required this.slotTime,
    required this.serviceTitle,
    required this.serviceDuration,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.avgRating,
    required this.totalReviews,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    // defensive parsing
    double _toDouble(v) => v is num ? v.toDouble() : double.tryParse("$v") ?? 0.0;
    int _toInt(v) => v is num ? v.toInt() : int.tryParse("$v") ?? 0;

    return BookingItem(
      id: _toInt(json['id']),
      user: _toInt(json['user']),
      userEmail: json['user_email'] ?? '',
      shop: _toInt(json['shop']),
      shopName: json['shop_name'] ?? '',
      shopAddress: json['shop_address'] ?? '',
      shopImg: json['shop_img'] ?? '',
      slot: _toInt(json['slot']),
      slotTime: DateTime.tryParse(json['slot_time'] ?? '') ?? DateTime.now(),
      serviceTitle: json['service_title'] ?? '',
      serviceDuration: json['service_duration'] ?? '',
      status: (json['status'] ?? '').toString().toLowerCase(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      avgRating: _toDouble(json['avg_rating']),
      totalReviews: _toInt(json['total_reviews']),
    );
  }
}
