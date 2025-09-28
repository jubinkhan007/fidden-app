// lib/features/inbox/screens/chat_screen.dart
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/inbox/widgets/chat_shimmer.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.threadId,
    required this.shopId,
    required this.shopName,
    required this.shopAvatarUrl, // New parameter
    required this.isOwner,
    this.seedMessages = const <MessageModel>[],
  });

  final int threadId;
  final int shopId;
  final String shopName;
  final String shopAvatarUrl; // New parameter
  final bool isOwner;
  final List<MessageModel> seedMessages;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController c;
  final _inputController = TextEditingController();
  final _scroll = ScrollController(); 

  late final int _myUserId;
  late final String _myEmail;


  // call after first page & after each paging
  Future<void> _autoFillIfShort({int maxLoops = 3}) async {
    for (var i = 0; i < maxLoops; i++) {
      await Future.delayed(const Duration(milliseconds: 16)); // wait a frame
      if (!_scroll.hasClients) break;

      final canScroll = _scroll.position.maxScrollExtent > 0;
      if (canScroll) break;                // viewport already filled
      if (!c.hasMore || c.isPaging.value) break;

      final before = _scroll.position.maxScrollExtent;
      await c.loadMore();
      // keep viewport stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        final delta = _scroll.position.maxScrollExtent - before;
        if (delta > 0) _scroll.jumpTo(_scroll.position.pixels + delta);
      });
    }
  }


  @override
  void initState() {
    super.initState();

    final profile = Get.find<ProfileController>();
    _myUserId = int.tryParse(profile.profileDetails.value.data?.id ?? '') ?? -1;
    _myEmail = profile.profileDetails.value.data?.email ?? '';

    c = Get.put(
      ChatController(
        threadId: widget.threadId,
        shopId: widget.shopId,
        shopName: widget.shopName,
        isOwner: widget.isOwner,
        seedMessages: widget.seedMessages,
      ),
      tag: 'chat_${widget.threadId}',
    );
    _scroll.addListener(_onScrollLoadMore);
// When first page lands, try to auto-fill.
    ever(c.isInitialLoading, (bool loading) {
      if (!loading) WidgetsBinding.instance.addPostFrameCallback((_) => _autoFillIfShort());
    });
    // Also run after each pagination completes.
    ever(c.isPaging, (bool paging) async {
      if (!paging) WidgetsBinding.instance.addPostFrameCallback((_) => _autoFillIfShort());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => c.markThreadRead());
  }


void _onScrollLoadMore() async {
    if (!mounted) return;
    const threshold = 120.0;

    // With reverse:true, older messages sit toward maxScrollExtent.
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - threshold) {
      // Keep viewport stable after load by compensating the delta.
      final beforeMax = _scroll.position.maxScrollExtent;
      await c.loadMore();
      // If older messages appended, max extent grows; keep the same visual spot:
      final afterMax = _scroll.position.maxScrollExtent;
      final delta = afterMax - beforeMax;
      if (delta > 0) {
        // Avoid jump by shifting current offset by delta.
        final target = _scroll.position.pixels + delta;
        if (target <= _scroll.position.maxScrollExtent) {
          _scroll.jumpTo(target);
        }
      }
    }
  }


  @override
  void dispose() {
    _scroll.dispose();
    _inputController.dispose();
    Get.delete<ChatController>(tag: 'chat_${widget.threadId}', force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final last = c.messages.isNotEmpty ? c.messages.first : null;
        Get.back(result: last);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // --- MODERN APP BAR ---
          elevation: 0.5,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.shopAvatarUrl),
                radius: 18,
                onBackgroundImageError: (_, __) {}, // handle error gracefully
              ),
              const SizedBox(width: 12),
              Text(
                widget.shopName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
         body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = c.messages;

              if (c.isInitialLoading.value) {
                return const ChatShimmer();
              }
              if (items.isEmpty) {
                return const Center(child: Text('Start the conversation!'));
              }

              // +1 to show a tiny loader “at top” when paging (remember reversed)
              final showTopLoader = c.isPaging.value;
              final total = items.length + (showTopLoader ? 1 : 0);

              return ListView.builder(
                controller: _scroll,          // NEW
                reverse: true,
                physics: const AlwaysScrollableScrollPhysics(), // <- allows pull even if short
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: total,
                itemBuilder: (_, i) {
                  // When reversed, index 0 is the newest bubble.
                  if (showTopLoader && i == items.length) {
                    // This renders at the “top” visually (older side)
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  final message = items[i];
                  final myActorId = widget.isOwner ? widget.shopId : _myUserId;
                  final isMe = (message.sender == myActorId) ||
                      (!widget.isOwner && _myEmail.isNotEmpty && message.senderEmail == _myEmail);

                  return _ChatMessageBubble(
                    message: message,
                    isMe: isMe,
                    onResend: () => c.resend(message),
                  );
                },
              );
            }),
          ),
          _MessageInputArea(
            controller: _inputController,
            chatController: c,
            onSend: () async {
              final text = _inputController.text.trim();
              if (text.isEmpty) return;
              await c.send(text);
              _inputController.clear();
              // Optional: scroll to bottom (newest) after sending
              if (_scroll.hasClients) {
                _scroll.animateTo(
                  0, // with reverse:true, 0 is the latest
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ],
      ),
    )
    );
  }
}

// --- NEW WIDGET: A BEAUTIFUL CHAT BUBBLE ---
class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({
    required this.message,
    required this.isMe,
    required this.onResend,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? theme.colorScheme.primary : const Color(0xFFF0F2F5);
    final textColor = isMe ? Colors.white : Colors.black87;

    // Tailed bubble effect
    final borderRadius = isMe
        ? const BorderRadius.only(
      topLeft: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomRight: Radius.circular(4),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(4),
      bottomLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomRight: Radius.circular(18),
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: borderRadius,
              ),
              child: Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 5),
            _buildStatusRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context) {
    if (message.status == MessageStatus.sent && isMe) {
      return Text(
        message.timeLabel,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.status != MessageStatus.sent)
          Text(
            message.timeLabel,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        if (message.status == MessageStatus.sending) ...[
          const SizedBox(width: 6),
          Icon(Icons.watch_later_outlined, color: Colors.grey.shade400, size: 12),
          const SizedBox(width: 4),
          Text(
            'Sending...',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ] else if (message.status == MessageStatus.failed) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onResend,
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Failed. Tap to retry.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }
}

// --- NEW WIDGET: THE MODERN INPUT AREA ---
class _MessageInputArea extends StatelessWidget {
  const _MessageInputArea({
    required this.controller,
    required this.chatController,
    required this.onSend,
  });

  final TextEditingController controller;
  final ChatController chatController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message',
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final isSending = chatController.sending.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isSending
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
                  : IconButton(
                key: const ValueKey('send_button'),
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}