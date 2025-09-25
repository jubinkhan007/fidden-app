// lib/features/inbox/controller/inbox_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/notifications/notification_service.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/core/ws/ws_service.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/inbox/data/thread_data_model.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InboxController extends GetxController {
  final threads = <Thread>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;

  final ProfileController _profileController = Get.find<ProfileController>();

  // socket service + subs
  late final WsService _ws;
  StreamSubscription<IncomingMessage>? _msgSub;
  StreamSubscription<MarkReadAck>? _ackSub;

  @override
  void onInit() {
    super.onInit();
    _ws = Get.put(WsService(), permanent: true);
    _ws.ensureConnected();
    fetchConversations();
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _ackSub?.cancel();
    super.onClose();
  }

  int get _myUserId =>
      int.tryParse(_profileController.profileDetails.value.data?.id ?? '') ??
      -1;

  // Search
  List<Thread> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return threads;
    return threads.where((c) {
      final otherPartyName = getOtherPartyName(c).toLowerCase();
      final lastMessage = getLastMessageText(c).toLowerCase();
      return otherPartyName.contains(q) || lastMessage.contains(q);
    }).toList();
  }

  MessageModel? last(Thread t) => _getLastMessage(t);

  bool isLastFromMe(Thread t) {
    final m = last(t);
    if (m == null) return false;

    final currentUserRole = AuthService.role?.toLowerCase();
    final myActorId = (currentUserRole == 'user') ? t.user : t.shop;

    return m.sender == myActorId;
  }

  bool isLastUnreadForMe(Thread t) {
    final m = last(t);
    if (m == null) return false;
    return m.isRead == false && m.sender != _myUserId;
  }

  String getLastMessagePreview(Thread t) {
    final m = last(t);
    if (m == null) return 'No messages yet.';
    return isLastFromMe(t) ? 'You: ${m.content}' : m.content;
  }

  /// Called by Chat to reflect latest message immediately
  void patchLastMessage(int threadId, MessageModel msg) {
    // Use the correct variable name: 'threads' instead of 'conversations'
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx < 0) return;

    final thread = threads[idx];

    // Add the new message if it's not already in the list
    final exists = thread.messages.any((m) => m.id == msg.id);
    if (!exists) {
      thread.messages.add(msg);
    }

    // Trigger a UI update for the list
    _sortByLatest();
    threads.refresh();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final response = await NetworkCaller().getRequest(
        AppUrls.threads,
        token: AuthService.accessToken,
      );

      if (response.isSuccess && response.responseData is List) {
        threads.value = threadFromJson(jsonEncode(response.responseData));

        _sortByLatest();

        // subscribe to all current threads (use WsService.subscribeThread)
        for (final t in threads) {
          _ws.subscribeThread(t.id);
        }

        // start realtime listeners only once
        _msgSub ??= _ws.messages$.listen(_onRealtimeMessage);
        _ackSub ??= _ws.markReadAcks$.listen(_onMarkReadAck);
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? "Failed to load messages.",
        );
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _onRealtimeMessage(IncomingMessage ev) async {
    // Update in-memory thread list
    final tidx = threads.indexWhere((t) => t.id == ev.threadId);
    if (tidx == -1) {
      // We don't have this thread in memory; either refetch or create a stub.
      // Safer: refetch to keep full info in sync.
      await fetchConversations();
    } else {
      final t = threads[tidx];

      // avoid duplicates
      final exists = t.messages.any((m) => m.id == ev.message.id);
      if (!exists) {
        t.messages.add(ev.message);
        _sortByLatest();
        threads.refresh();
      }
    }

    // If chat screen for this thread is not open/visible, show a banner
    final isOnChatScreen = Get.currentRoute.contains('ChatScreen');
    if (!isOnChatScreen) {
      await NotificationService.I.showMessage(
        title: ev.message.senderEmail.isNotEmpty
            ? ev.message.senderEmail
            : 'New message',
        body: ev.message.content,
        payload: {
          'type': 'chat',
          'thread_id': ev.threadId,
          'message_id': ev.message.id,
        },
        uniqueId: '${ev.message.id}',
      );
    }
  }

  void _onMarkReadAck(MarkReadAck ack) {
    final idx = threads.indexWhere((t) => t.id == ack.threadId);
    if (idx == -1) return;
    final t = threads[idx];

    if (ack.messageIds.isEmpty) {
      // mark all from other party as read
      for (var i = 0; i < t.messages.length; i++) {
        final m = t.messages[i];
        if (!m.isRead && m.sender != _myUserId) {
          t.messages[i] = MessageModel(
            id: m.id,
            sender: m.sender,
            senderEmail: m.senderEmail,
            content: m.content,
            timestamp: m.timestamp,
            isRead: true,
          );
        }
      }
    } else {
      final set = ack.messageIds.toSet();
      for (var i = 0; i < t.messages.length; i++) {
        final m = t.messages[i];
        if (!m.isRead && set.contains(m.id)) {
          t.messages[i] = MessageModel(
            id: m.id,
            sender: m.sender,
            senderEmail: m.senderEmail,
            content: m.content,
            timestamp: m.timestamp,
            isRead: true,
          );
        }
      }
    }
    threads.refresh();
  }

  void onSearch(String value) => query.value = value;

  // UI helpers
  String getOtherPartyName(Thread thread) {
    final currentUserRole = AuthService.role?.toLowerCase();
    if (currentUserRole == 'user') {
      return thread.shopName;
    }
    return thread.userEmail;
  }

  String getOtherPartyAvatar(Thread thread) {
    return 'https://i.pravatar.cc/150?u=${thread.id}';
  }

  MessageModel? _getLastMessage(Thread thread) {
    if (thread.messages.isEmpty) return null;
    thread.messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return thread.messages.first;
  }

  void markThreadAsRead(int threadId) {
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx == -1) return;

    final thread = threads[idx];
    bool wasUpdated = false;

    // Iterate through messages and mark them as read
    for (var i = 0; i < thread.messages.length; i++) {
      final message = thread.messages[i];
      // Only update unread messages from the other party
      if (!message.isRead && message.sender != _myUserId) {
        thread.messages[i] = message.copyWith(isRead: true);
        wasUpdated = true;
      }
    }

    // Refresh the UI only if a change was made
    if (wasUpdated) {
      threads.refresh();
    }
  }

  String getLastMessageText(Thread thread) {
    return _getLastMessage(thread)?.content ?? 'No messages yet.';
  }

  String getLastMessageTime(Thread thread) {
    final lastMsg = _getLastMessage(thread);
    if (lastMsg == null) return '';
    final localTimestamp = lastMsg.timestamp.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(localTimestamp.year, localTimestamp.month, localTimestamp.day);


    if (today == msgDate) {
      return DateFormat('h:mm a').format(localTimestamp);
    } else if (today.difference(msgDate).inDays == 1 && now.difference(msgDate).inHours < 48) {
      return 'Yesterday';
    }
    return DateFormat('d MMM').format(localTimestamp);
  }

  int getUnreadCount(Thread thread) {
    final currentUserRole = AuthService.role?.toLowerCase();

    // Determine your correct ID for this conversation (user or shop)
    final myActorId = (currentUserRole == 'user') ? thread.user : thread.shop;

    return thread.messages
        .where((msg) => !msg.isRead && msg.sender != myActorId)
        .length;
  }

  void archive(String id) {
    Get.snackbar('Archive', 'Archive feature not available.');
  }

  void delete(String id) {
    Get.snackbar('Delete', 'Delete feature not available.');
  }

  void _sortByLatest() {
    threads.sort((a, b) {
      final la =
          _getLastMessage(a)?.timestamp ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final lb =
          _getLastMessage(b)?.timestamp ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return lb.compareTo(la);
    });
  }
}
