import 'package:fidden/features/inbox/data/message_model.dart';

class PagedMessages {
  final String? next;
  final String? previous;
  final List<MessageModel> results;

  PagedMessages({this.next, this.previous, required this.results});

  factory PagedMessages.fromJson(Map<String, dynamic> json) {
    final list = (json['results'] as List? ?? const [])
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedMessages(
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: list,
    );
  }
}
