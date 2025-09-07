import 'dart:convert';
import 'package:intl/intl.dart'; // <-- add this

List<MessageModel> messageListFromJson(String str) => List<MessageModel>.from(
  json.decode(str).map((x) => MessageModel.fromJson(x)),
);

class MessageModel {
  final int id;
  final int sender; // from sender_id
  final String senderEmail;
  final String content;
  final DateTime timestamp;
  bool isRead;

  MessageModel({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  //  Add this computed getter used by ChatScreen
  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (msgDay == today) {
      return DateFormat('h:mm a').format(timestamp); // e.g., 5:30 PM
    }
    if (msgDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    final sameYear = now.year == timestamp.year;
    return DateFormat(sameYear ? 'd MMM' : 'd MMM yyyy').format(timestamp);
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
