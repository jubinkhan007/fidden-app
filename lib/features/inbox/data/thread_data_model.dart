import 'dart:convert';
import 'message_model.dart';

List<Thread> threadFromJson(String str) =>
    List<Thread>.from(json.decode(str).map((x) => Thread.fromJson(x)));

class Thread {
  final int id;
  final int shop;
  final String shopName;
  final String? shopImg; // <- from API
  final int user;
  final String userEmail;
  final String? userName; // <- from API
  final String? userImg; // <- from API
  final List<MessageModel> messages;
  final DateTime createdAt;

  Thread({
    required this.id,
    required this.shop,
    required this.shopName,
    required this.user,
    required this.userEmail,
    required this.messages,
    required this.createdAt,
    this.shopImg,
    this.userName,
    this.userImg,
  });

  factory Thread.fromJson(Map<String, dynamic> json) => Thread(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? -1,
    shop: json['shop'] is int
        ? json['shop']
        : int.tryParse('${json['shop']}') ?? -1,
    shopName: (json['shop_name'] ?? '').toString(),
    shopImg: json['shop_img'] as String?,
    user: json['user'] is int
        ? json['user']
        : int.tryParse('${json['user']}') ?? -1,
    userEmail: (json['user_email'] ?? '').toString(),
    userName: json['user_name'] as String?,
    userImg: json['user_img'] as String?,
    messages: (json['messages'] as List? ?? const [])
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse((json['created_at'] ?? '').toString()),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop': shop,
    'shop_name': shopName,
    'shop_img': shopImg,
    'user': user,
    'user_email': userEmail,
    'user_name': userName,
    'user_img': userImg,
    'messages': messages.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
  };
}
