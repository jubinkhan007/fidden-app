// review_model.dart

class Review {
  final String id;
  final String author;
  final String? avatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final String serviceName;
  String? reply;

  Review({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    required this.serviceName,
    this.reply,
  });

  /// Build from the API shape you showed
  factory Review.fromApi(Map<String, dynamic> j) {
    // author fallback if user_name is null: "User #<user_id>"
    final dynamic userName = j['user_name'];
    final dynamic userId = j['user_id'];
    final author =
        (userName == null || (userName is String && userName.trim().isEmpty))
        ? 'User #${userId ?? '-'}'
        : userName.toString();

    return Review(
      id: j['id']?.toString() ?? '',
      author: author,
      avatarUrl: (j['user_img'] as String?)?.trim().isEmpty == true
          ? null
          : j['user_img'] as String?,
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      comment: (j['review'] ?? '').toString(),
      date:
          DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
      serviceName: (j['service_name'] ?? '').toString(),
      reply: _latestReplyMessage(j['reply']),
    );
  }

  static String? _latestReplyMessage(dynamic replyField) {
    // API returns an array of replies [{id, message, created_at}, ...]
    if (replyField is List && replyField.isNotEmpty) {
      final last = replyField.last;
      if (last is Map && last['message'] != null) {
        return last['message'].toString();
      }
    }
    return null;
  }
}
