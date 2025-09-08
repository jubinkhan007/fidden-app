// lib/features/user/profile/data/notification_model.dart
import 'dart:convert';

List<NotificationModel> notificationFromJson(String str) =>
    List<NotificationModel>.from(
      json.decode(str).map((x) => NotificationModel.fromJson(x)),
    );

class NotificationModel {
  final int id;
  final String message;
  final String notificationType;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.notificationType,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        message: json["message"],
        notificationType: json["notification_type"],
        data: json["data"] ?? {},
        isRead: json["is_read"],
        createdAt: DateTime.parse(json["created_at"]),
      );
}
