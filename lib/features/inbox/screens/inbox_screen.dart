import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/inbox/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/inbox_controller.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(InboxController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Inbox'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (c.isLoading.value && c.threads.isEmpty) {
          return const _InboxSkeleton();
        }

        final items = c.filtered;
        return RefreshIndicator(
          onRefresh: c.fetchConversations,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _SearchBar(
                    hint: 'Search by name or message…',
                    onChanged: c.onSearch,
                    onClear: () => c.onSearch(''),
                  ),
                ),
              ),
              // Empty state
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyInbox(),
                )
              else
                SliverList.separated(
                  itemBuilder: (_, i) {
                    final thread = items[i];
                    return _SwipeableTile(
                      id: thread.id.toString(),
                      name: c.getOtherPartyName(thread),
                      avatarUrl: c.getOtherPartyAvatar(thread),
                      lastMessage: c.getLastMessagePreview(
                        thread,
                      ), // <- "You: ..." when I’m sender
                      time: c.getLastMessageTime(thread),
                      unreadCount: c.getUnreadCount(thread),
                      isUnreadForMe: c.isLastUnreadForMe(thread), // <- add this
                      onArchive: () => c.archive(thread.id.toString()),
                      onDelete: () => c.delete(thread.id.toString()),
                      onTap: () async {
                        final isOwner =
                            (AuthService.role?.toLowerCase() == 'owner');
                        final last = await Get.to(
                          () => ChatScreen(
                            threadId: thread.id,
                            shopId: thread.shop,
                            shopName: c.getOtherPartyName(thread),
                            isOwner: isOwner,
                            seedMessages: thread.messages,
                          ),
                        );

                        // Mark the entire thread as read in the inbox controller's memory
                        c.markThreadAsRead(thread.id); // <-- ADD THIS LINE

                        if (last is MessageModel) {
                          // This will update the last message preview and re-sort the list
                          c.patchLastMessage(thread.id, last);
                        }
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: items.length,
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            ],
          ),
        );
      }),
    );
  }
}

/// Search bar with clear
class _SearchBar extends StatefulWidget {
  const _SearchBar({
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF7A8494)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF7A8494)),
              onPressed: () {
                _controller.clear();
                widget.onClear();
              },
            ),
        ],
      ),
    );
  }
}

/// Dismissible + modern card
class _SwipeableTile extends StatelessWidget {
  const _SwipeableTile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onArchive,
    required this.onDelete,
    required this.onTap,
    required this.isUnreadForMe,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onArchive;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isUnreadForMe;

  @override
  Widget build(BuildContext context) {
    final previewStyle = TextStyle(
      color: isUnreadForMe ? Colors.black : const Color(0xFF535C69),
      fontSize: 14,
      fontWeight: isUnreadForMe ? FontWeight.w700 : FontWeight.w400,
    );

    return Dismissible(
      key: ValueKey(id),
      background: _SlideBg(
        color: const Color(0xFFECFDF5),
        icon: Icons.archive_outlined,
        text: 'Archive',
        alignLeft: true,
      ),
      secondaryBackground: _SlideBg(
        color: const Color(0xFFFFEBEE),
        icon: Icons.delete_outline,
        text: 'Delete',
        alignLeft: false,
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          onArchive();
        } else {
          onDelete();
        }
        return false; // keep item for demo; set true to actually dismiss
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDEEF1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _Avatar(url: avatarUrl, unread: unreadCount > 0),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF151A22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xFF8A94A6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: previewStyle, // use it
                      ),
                      const SizedBox(height: 8),
                      if (unreadCount > 0)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$unreadCount new',
                                style: const TextStyle(
                                  color: Color(0xFF4338CA),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideBg extends StatelessWidget {
  const _SlideBg({
    required this.color,
    required this.icon,
    required this.text,
    required this.alignLeft,
  });

  final Color color;
  final IconData icon;
  final String text;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: color,
      child: Row(
        mainAxisAlignment: alignLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!alignLeft) const SizedBox(),
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.unread});
  final String url;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipOval(
          child: Image.network(
            url,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              color: const Color(0xFFE6E8EC),
              alignment: Alignment.center,
              child: const Icon(Icons.person, color: Color(0xFF7A8494)),
            ),
          ),
        ),
        if (unread)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Loading skeleton
class _InboxSkeleton extends StatelessWidget {
  const _InboxSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar({double w = double.infinity, double h = 14}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF1),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEEF1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDEEF1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(w: 140, h: 16),
                  const SizedBox(height: 8),
                  bar(h: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.mail_outline, size: 48, color: Color(0xFF9AA3B2)),
            SizedBox(height: 12),
            Text(
              'No messages yet',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'When customers message you, they’ll show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A8494)),
            ),
          ],
        ),
      ),
    );
  }
}
