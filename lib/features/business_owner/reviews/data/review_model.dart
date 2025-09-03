class Review {
  final String author;
  final String avatarUrl;
  final double rating;
  final String comment;
  final DateTime date;
  final String serviceName;
  String? reply;

  Review({
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.date,
    required this.serviceName,
    this.reply,
  });
}
