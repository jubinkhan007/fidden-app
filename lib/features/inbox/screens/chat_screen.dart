// lib/features/chat/presentation/chat_screen.dart
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../inbox/data/message_model.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.threadId,
    required this.shopId,
    required this.shopName,
    required this.isOwner,
    this.seedMessages = const <MessageModel>[],
  });

  final int threadId;
  final int shopId;
  final String shopName;
  final bool isOwner;
  final List<MessageModel> seedMessages;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController c;
  final _input = TextEditingController();

  late final int _myUserId; // <- add
  late final String _myEmail;

  @override
  void initState() {
    super.initState();

    // who am I?
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

    WidgetsBinding.instance.addPostFrameCallback((_) => c.markThreadRead());
  }

  @override
  void dispose() {
    _input.dispose();
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
        appBar: AppBar(title: Text(widget.shopName)),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final items = c.messages;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[i];
                    final myActorId = widget.isOwner
                        ? widget.shopId
                        : _myUserId;
                    final isMe =
                        (m.sender == myActorId) ||
                        (!widget.isOwner &&
                            _myEmail.isNotEmpty &&
                            m.senderEmail == _myEmail); // <- key line

                    final showTail = isMe && (m.status != MessageStatus.sent);
final statusText = m.status == MessageStatus.sending
    ? 'Sending…'
    : (m.status == MessageStatus.failed ? 'Failed to send' : null);

return Align(
  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            m.content,
            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
          ),
        ),
        const SizedBox(height: 4),

        // time + status row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              m.timeLabel,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            if (statusText != null) ...[
              const SizedBox(width: 8),
              if (m.status == MessageStatus.sending)
                Text(
                  statusText,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                )
              else if (m.status == MessageStatus.failed)
                GestureDetector(
                  onTap: () => Get.find<ChatController>(tag: 'chat_${widget.threadId}')
                      .resend(m),
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 12, color: Colors.red.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to resend',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ],
    ),
  ),
);
                  },
                );
              }),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => IconButton(
                        onPressed: c.sending.value
                            ? null
                            : () async {
                                final text = _input.text.trim();
                                if (text.isEmpty) return;
                                await c.send(text);
                                _input.clear();
                              },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
