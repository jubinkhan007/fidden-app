import 'dart:convert';
import 'package:intl/intl.dart';

List<MessageModel> messageListFromJson(String str) => List<MessageModel>.from(
  json.decode(str).map((x) => MessageModel.fromJson(x)),
);

enum MessageStatus { sending, sent, failed }

class MessageModel {
  final int id;
  final int sender;
  final String senderEmail;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  // NEW
  final String? localId;               // identifies optimistic messages
  final MessageStatus status;          // sending/sent/failed

  MessageModel({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.localId,
    this.status = MessageStatus.sent,   // server messages default to 'sent'
  });


  /// Pretty time label for UI
  String get timeLabel {
    // 1. Convert the UTC timestamp to the user's local timezone immediately.
    final localTimestamp = timestamp.toLocal();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 2. Use the local timestamp's date for all comparisons.
    final msgDay = DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);

    if (msgDay == today) {
      // 3. Format the local time.
      return DateFormat('h:mm a').format(localTimestamp);
    }
    if (msgDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    final sameYear = now.year == localTimestamp.year;

    // 4. Format the local date.
    return DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy').format(localTimestamp);
  }

  /// ✅ Move copyWith into the model to avoid extension ambiguity
  MessageModel copyWith({
    int? id,
    int? sender,
    String? senderEmail,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? localId,
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderEmail: senderEmail ?? this.senderEmail,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      localId: localId ?? this.localId,
      status: status ?? this.status,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender_id'] ?? json['sender'];
    return MessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? -1,
      sender: rawSender is int ? rawSender : int.tryParse('$rawSender') ?? -1,
      senderEmail: (json['sender_email'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      timestamp: DateTime.parse((json['timestamp'] ?? '').toString()),
      isRead: json['is_read'] == true || json['is_read']?.toString() == 'true',
      // server messages: no localId, status=sent
      localId: null,
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': sender,
    'sender_email': senderEmail,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'is_read': isRead,
  };
}
