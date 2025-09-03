import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/chat_controller.dart';
import '../data/message_model.dart';

class ChatScreen extends StatelessWidget {
  final String conversationId;
  final String recipientName;
  final String? recipientAvatarUrl;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.recipientAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChatController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: (recipientAvatarUrl?.trim().isNotEmpty ?? false)
                  ? NetworkImage(recipientAvatarUrl!)
                  : null,
              child: (recipientAvatarUrl?.trim().isNotEmpty ?? false)
                  ? null
                  : Text(
                      recipientName.isNotEmpty
                          ? recipientName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipientName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Obx(
                  () => Text(
                    c.isTyping.value ? 'typing…' : 'online',
                    style: TextStyle(
                      fontSize: 12,
                      color: c.isTyping.value
                          ? const Color(0xFF10B981)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const _ChatSkeleton();
              }

              final list = c.messages.reversed.toList(); // newest at bottom
              if (list.isEmpty) {
                return const _EmptyChat();
              }

              return _MessageList(
                messages: list,
                currentUserId: c.currentUserId,
                controller: c,
              );
            }),
          ),

          // Typing indicator
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: c.isTyping.value
                  ? const _TypingIndicator()
                  : const SizedBox(height: 0),
            ),
          ),

          // Composer
          _Composer(controller: c, onSend: c.sendMessage),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.controller,
  });
  final List<Message> messages;
  final String currentUserId;
  final ChatController controller;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  bool showToBottom = false;

  @override
  void initState() {
    super.initState();
    widget.controller.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // reversed list: offset > ~250 means away from bottom
    final away = widget.controller.scrollController.offset > 250;
    if (away != showToBottom) {
      setState(() => showToBottom = away);
    }
  }

  @override
  Widget build(BuildContext context) {
    final msgs = widget.messages;
    final df = DateFormat.yMMMMd();

    String? lastDate;

    return Stack(
      children: [
        ListView.builder(
          controller: widget.controller.scrollController,
          reverse: true, // newest at bottom
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          itemCount: msgs.length,
          itemBuilder: (_, i) {
            final m = msgs[i];
            final isMe = m.senderId == widget.currentUserId;

            // Date divider
            final dateKey = df.format(m.timestamp);
            Widget? divider;
            if (lastDate != dateKey) {
              lastDate = dateKey;
              divider = _DateDivider(label: dateKey);
            }

            return Column(
              children: [
                if (divider != null) ...[
                  const SizedBox(height: 10),
                  divider,
                  const SizedBox(height: 10),
                ],
                _MessageBubble(message: m, isMe: isMe),
                const SizedBox(height: 6),
              ],
            );
          },
        ),

        if (showToBottom)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              heroTag: 'toBottom',
              elevation: 2,
              backgroundColor: Colors.white,
              onPressed: () => widget.controller.scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.arrow_downward, color: Color(0xFF6B7280)),
            ),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({required this.message, required this.isMe});
  final Message message;
  final bool isMe;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool showTime = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final time = DateFormat('h:mm a').format(m.timestamp);
    final maxW = MediaQuery.of(context).size.width * .72;

    final bg = widget.isMe
        ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF845BFF)])
        : const LinearGradient(colors: [Color(0xFFE5E7EB), Color(0xFFF1F5F9)]);
    final fg = widget.isMe ? Colors.white : const Color(0xFF111827);

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => setState(() => showTime = !showTime),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: widget.isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(6),
                bottomRight: widget.isMe
                    ? const Radius.circular(6)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(m.text, style: TextStyle(color: fg, height: 1.25)),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: showTime ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: fg.withOpacity(.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final ChatController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final canSend = controller.messageTextController.text.trim().isNotEmpty.obs;

    controller.messageTextController.addListener(() {
      canSend.value = controller.messageTextController.text.trim().isNotEmpty;
    });

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Attach',
              icon: const Icon(Icons.attach_file_outlined),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller.messageTextController,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.mic_none_outlined,
                        color: Color(0xFF6B7280),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => CircleAvatar(
                radius: 24,
                backgroundColor: canSend.value
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFCBD5E1),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: canSend.value ? onSend : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          SizedBox(width: 16),
          _BubbleDot(),
          SizedBox(width: 4),
          _BubbleDot(delay: 120),
          SizedBox(width: 4),
          _BubbleDot(delay: 240),
        ],
      ),
    );
  }
}

class _BubbleDot extends StatefulWidget {
  const _BubbleDot({this.delay = 0});
  final int delay;
  @override
  State<_BubbleDot> createState() => _BubbleDotState();
}

class _BubbleDotState extends State<_BubbleDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true);
  late final Animation<double> _anim = Tween(
    begin: .2,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(milliseconds: widget.delay),
      () => _ac.forward(from: 0),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF9CA3AF),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
      ],
    );
  }
}

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = 180, double h = 14}) => Container(
      width: w,
      height: h,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) => Align(
        alignment: i.isEven ? Alignment.centerRight : Alignment.centerLeft,
        child: bar(w: i.isEven ? 200 : 160),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.forum_outlined, size: 48, color: Color(0xFF9AA3B2)),
            SizedBox(height: 12),
            Text('Say hello 👋', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text(
              'Start the conversation to build trust with your customer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8494)),
            ),
          ],
        ),
      ),
    );
  }
}
