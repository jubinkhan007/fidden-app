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

  // Existing: build from API
  factory Review.fromApi(Map<String, dynamic> j) {
    final dynamic userName = j['user_name'];
    final dynamic userId = j['user_id'];
    final author = (userName == null || (userName is String && userName.trim().isEmpty))
        ? 'User #${userId ?? '-'}'
        : userName.toString();

    return Review(
      id: j['id']?.toString() ?? '',
      author: author,
      avatarUrl: (j['user_img']?.toString().trim().isEmpty ?? true)
          ? null
          : j['user_img'].toString(),
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      comment: (j['review'] ?? '').toString(),
      date: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now(),
      serviceName: (j['service_name'] ?? '').toString(),
      reply: _latestReplyMessage(j['reply']),
    );
  }

  // NEW: build from cache JSON
  factory Review.fromCacheJson(Map<String, dynamic> j) => Review(
    id: (j['id'] ?? '').toString(),
    author: (j['author'] ?? '').toString(),
    avatarUrl: (j['avatarUrl'] as String?)?.isEmpty == true ? null : j['avatarUrl'] as String?,
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    comment: (j['comment'] ?? '').toString(),
    date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
    serviceName: (j['serviceName'] ?? '').toString(),
    reply: (j['reply'] as String?),
  );

  // NEW: to cache JSON
  Map<String, dynamic> toCacheJson() => {
    'id': id,
    'author': author,
    'avatarUrl': avatarUrl,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
    'serviceName': serviceName,
    'reply': reply,
  };

  static String? _latestReplyMessage(dynamic replyField) {
    if (replyField is List && replyField.isNotEmpty) {
      final last = replyField.last;
      if (last is Map && last['message'] != null) {
        return last['message'].toString();
      }
    }
    return null;
  }
}
