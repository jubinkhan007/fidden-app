import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
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
      final url = review.avatarUrl; // String?
      final isEmpty = url == null || url.trim().isEmpty;

      if (isEmpty) {
        // initials fallback
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
      // 1) Kill the default Card margin
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,

      // 2) Trim inner padding a bit at the bottom
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
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
                      (review.rating).toStringAsFixed(1),
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

            const SizedBox(height: 10),

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
              Obx(() {
                final loading = controller.isReplying(review.id);
                return Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF5B44EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.reply_outlined, size: 18),
                    label: Text(loading ? 'Sending…' : 'Reply'),
                    onPressed: loading
                        ? null
                        : () {
                            Get.dialog(
                              _ReplyDialog(
                                author: review.author,
                                onSend: (msg) => controller.sendReply(
                                  review: review,
                                  message: msg,
                                ),
                              ),
                              barrierDismissible: true,
                            );
                          },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ReplyDialog extends StatefulWidget {
  const _ReplyDialog({required this.author, required this.onSend});
  final String author;
  final ValueChanged<String> onSend;

  @override
  State<_ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<_ReplyDialog> {
  final controller = TextEditingController();
  bool sending = false;

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
              'Reply to ${widget.author}',
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
                    onPressed: sending ? null : () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: sending
                        ? null
                        : () async {
                            final msg = controller.text.trim();
                            if (msg.isEmpty) return;
                            setState(() => sending = true);
                            widget.onSend(msg);
                            if (mounted) Get.back(); // close on success
                          },
                    icon: sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(sending ? 'Sending…' : 'Send'),
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
