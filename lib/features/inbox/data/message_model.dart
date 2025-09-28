import 'dart:convert';
import 'package:intl/intl.dart';

List<MessageModel> messageListFromJson(String str) =>
    List<MessageModel>.from(json.decode(str).map((x) => MessageModel.fromJson(x)));

enum MessageStatus { sending, sent, failed }

class MessageModel {
  final int id;
  final int threadId;        // NEW
  final int sender;
  final String senderEmail;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  // optimistic client-only
  final String? localId;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.threadId,   // NEW (required)
    required this.sender,
    required this.senderEmail,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.localId,
    this.status = MessageStatus.sent,
  });

  String get timeLabel {
    final local = timestamp.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(local.year, local.month, local.day);
    if (msgDay == today) return DateFormat('h:mm a').format(local);
    if (msgDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat(now.year == local.year ? 'd MMM' : 'd MMM yyyy').format(local);
  }

  MessageModel copyWith({
    int? id,
    int? threadId,
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
      threadId: threadId ?? this.threadId,
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
    final rawThread = json['thread_id'] ?? json['thread'];
    return MessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? -1,
      threadId: rawThread is int ? rawThread : int.tryParse('$rawThread') ?? -1, // NEW
      sender: rawSender is int ? rawSender : int.tryParse('$rawSender') ?? -1,
      senderEmail: (json['sender_email'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      timestamp: DateTime.parse((json['timestamp'] ?? '').toString()),
      isRead: json['is_read'] == true || json['is_read']?.toString() == 'true',
      localId: null,
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'thread_id': threadId,        // NEW
        'sender_id': sender,
        'sender_email': senderEmail,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
      };
}
