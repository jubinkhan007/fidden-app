import 'package:fidden/features/business_owner/profile/controller/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/review_model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReviewController>();
    final replyController = TextEditingController();

    Widget _avatar() {
      final url = review.avatarUrl;
      if ((url).toString().trim().isEmpty) {
        return CircleAvatar(
          backgroundColor: const Color(0xFFE2E8F0),
          child: Text(
            (review.author.isNotEmpty ? review.author[0] : '?').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
        );
      }
      return CircleAvatar(backgroundImage: NetworkImage(url));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Service: ${review.serviceName}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.yMMMd().format(review.date),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      (review.rating ?? 0).toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ExpandableText(review.comment),
            const SizedBox(height: 12),
            if ((review.reply ?? '').trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your reply',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review.reply!,
                      style: const TextStyle(color: Color(0xFF334155)),
                    ),
                  ],
                ),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.reply_outlined),
                  label: const Text('Reply'),
                  onPressed: () {
                    Get.dialog(
                      _ReplyDialog(
                        author: review.author,
                        controller: replyController,
                        onSend: () {
                          if (replyController.text.trim().isEmpty) return;
                          controller.addReply(
                            review,
                            replyController.text.trim(),
                          );
                          Get.back();
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReplyDialog extends StatelessWidget {
  const _ReplyDialog({
    required this.author,
    required this.controller,
    required this.onSend,
  });
  final String author;
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reply to $author',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Write your reply…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSend,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText(this.text);
  final String text;
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim();
    final short = text.length <= 180;
    final display = expanded || short ? text : '${text.substring(0, 180)}…';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(display, style: const TextStyle(color: Color(0xFF111827))),
        if (!short)
          TextButton(
            onPressed: () => setState(() => expanded = !expanded),
            child: Text(expanded ? 'Show less' : 'Read more'),
          ),
      ],
    );
  }
}
