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
      int.tryParse(_profileController.profileDetails.value.data?.id ?? '') ?? -1;

  // Search
  List<Thread> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return threads;
    return threads.where((t) {
      final otherName = getOtherPartyName(t).toLowerCase();
      final lastText = getLastMessageText(t).toLowerCase();
      return otherName.contains(q) || lastText.contains(q);
    }).toList();
  }

  // NEW: prefer in-memory latest message if chat has loaded, else API last_message
  MessageModel? _getLast(Thread t) {
    if (t.messages.isNotEmpty) {
      final copy = [...t.messages]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return copy.first;
    }
    return t.lastMessage;
  }

  MessageModel? last(Thread t) => _getLast(t);

  bool isLastFromMe(Thread t) {
    final m = _getLast(t);
    if (m == null) return false;
    final currentUserRole = AuthService.role?.toLowerCase();
    final myActorId = (currentUserRole == 'user') ? t.user : t.shop;
    return m.sender == myActorId;
  }

  bool isLastUnreadForMe(Thread t) {
    final m = _getLast(t);
    if (m == null) return false;
    return !m.isRead && m.sender != _myUserId;
  }

  String getLastMessagePreview(Thread t) {
    final m = _getLast(t);
    if (m == null) return 'No messages yet.';
    return isLastFromMe(t) ? 'You: ${m.content}' : m.content;
  }

  /// Called by Chat to reflect latest message immediately
  void patchLastMessage(int threadId, MessageModel msg) {
    final idx = threads.indexWhere((t) => t.id == threadId);
    if (idx < 0) return;
    final thread = threads[idx];

    // keep a tiny rolling list for local sort
    final existing = thread.messages.any((m) => m.id == msg.id);
    if (!existing) {
      thread.messages.add(msg);
      if (thread.messages.length > 20) {
        // don't let it grow unbounded in list view
        thread.messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        thread.messages.removeRange(20, thread.messages.length);
      }
    }

    // update API-provided last_message too
    threads[idx] = Thread(
      id: thread.id,
      shop: thread.shop,
      shopName: thread.shopName,
      user: thread.user,
      userEmail: thread.userEmail,
      createdAt: thread.createdAt,
      shopImg: thread.shopImg,
      userName: thread.userName,
      userImg: thread.userImg,
      lastMessage: msg,                   // ← keeps preview fresh
      messages: thread.messages,
    );

    _sortByLatest();
    threads.refresh();
  }

  void markThreadAsRead(int threadId) {
  final idx = threads.indexWhere((t) => t.id == threadId);
  if (idx == -1) return;

  final t = threads[idx];

  // figure out "me" in this thread
  final currentUserRole = AuthService.role?.toLowerCase();
  final myActorId = (currentUserRole == 'user') ? t.user : t.shop;

  bool changed = false;

  // 1) flip any locally-cached messages (rolling list kept for preview/sort)
  for (var i = 0; i < t.messages.length; i++) {
    final m = t.messages[i];
    if (!m.isRead && m.sender != myActorId) {
      t.messages[i] = m.copyWith(isRead: true);
      changed = true;
    }
  }

  // 2) also flip API-provided lastMessage, if it belongs to the other party
  final lm = t.lastMessage;
  Thread updated = t;
  if (lm != null && !lm.isRead && lm.sender != myActorId) {
    updated = Thread(
      id: t.id,
      shop: t.shop,
      shopName: t.shopName,
      user: t.user,
      userEmail: t.userEmail,
      createdAt: t.createdAt,
      shopImg: t.shopImg,
      userName: t.userName,
      userImg: t.userImg,
      lastMessage: lm.copyWith(isRead: true),
      messages: t.messages,
    );
    threads[idx] = updated;
    changed = true;
  }

  if (changed) {
    // keep ordering correct (latest read/unread change might affect badges)
    _sortByLatest();
    threads.refresh();
  }
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

        // subscribe to all current threads
        for (final t in threads) {
          _ws.subscribeThread(t.id);
        }

        _msgSub ??= _ws.messages$.listen(_onRealtimeMessage);
        _ackSub ??= _ws.markReadAcks$.listen(_onMarkReadAck);
      } else {
        AppSnackBar.showError(response.errorMessage ?? "Failed to load messages.");
      }
    } catch (e) {
      AppSnackBar.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _onRealtimeMessage(IncomingMessage ev) async {
    final tidx = threads.indexWhere((t) => t.id == ev.threadId);
    if (tidx == -1) {
      await fetchConversations(); // new thread appeared
    } else {
      // update rolling list & last_message
      patchLastMessage(ev.threadId, ev.message);
    }

    final isOnChatScreen = Get.currentRoute.contains('ChatScreen');
    if (!isOnChatScreen) {
      await NotificationService.I.showMessage(
        title: ev.message.senderEmail.isNotEmpty ? ev.message.senderEmail : 'New message',
        body: ev.message.content,
        payload: {'type': 'chat', 'thread_id': ev.threadId, 'message_id': ev.message.id},
        uniqueId: '${ev.message.id}',
      );
    }
  }

  void _onMarkReadAck(MarkReadAck ack) {
    final idx = threads.indexWhere((t) => t.id == ack.threadId);
    if (idx == -1) return;
    final t = threads[idx];

    // flip in rolling messages
    final targetIds = ack.messageIds.isEmpty
        ? t.messages.where((m) => !m.isRead && m.sender != _myUserId).map((m) => m.id).toSet()
        : ack.messageIds.toSet();

    for (var i = 0; i < t.messages.length; i++) {
      final m = t.messages[i];
      if (!m.isRead && targetIds.contains(m.id)) {
        t.messages[i] = m.copyWith(isRead: true);
      }
    }

    // also adjust lastMessage if it's one of them
    final lm = t.lastMessage;
    if (lm != null && targetIds.contains(lm.id)) {
      threads[idx] = Thread(
        id: t.id,
        shop: t.shop,
        shopName: t.shopName,
        user: t.user,
        userEmail: t.userEmail,
        createdAt: t.createdAt,
        shopImg: t.shopImg,
        userName: t.userName,
        userImg: t.userImg,
        lastMessage: lm.copyWith(isRead: true),
        messages: t.messages,
      );
    }

    threads.refresh();
  }

  void onSearch(String value) => query.value = value;

  String getOtherPartyName(Thread thread) {
    final currentUserRole = AuthService.role?.toLowerCase();
    return (currentUserRole == 'user') ? thread.shopName : (thread.userName ?? thread.userEmail);
  }

  String getOtherPartyAvatar(Thread thread) =>
      'https://i.pravatar.cc/150?u=${thread.id}';

  String getLastMessageText(Thread thread) => _getLast(thread)?.content ?? 'No messages yet.';

  String getLastMessageTime(Thread thread) {
    final m = _getLast(thread);
    return m?.timeLabel ?? '';
  }

  // Approximate unread count (list API doesn’t return an aggregate)
  int getUnreadCount(Thread thread) {
    // prefer local messages if present
    if (thread.messages.isNotEmpty) {
      final currentUserRole = AuthService.role?.toLowerCase();
      final myActorId = (currentUserRole == 'user') ? thread.user : thread.shop;
      return thread.messages.where((msg) => !msg.isRead && msg.sender != myActorId).length;
    }
    // fallback to 1/0 based on last_message
    final lm = thread.lastMessage;
    if (lm == null) return 0;
    return (!lm.isRead && lm.sender != _myUserId) ? 1 : 0;
  }

  void archive(String id) {
    Get.snackbar('Archive', 'Archive feature not available.');
  }

  void delete(String id) {
    Get.snackbar('Delete', 'Delete feature not available.');
  }

  void _sortByLatest() {
    threads.sort((a, b) {
      final la = _getLast(a)?.timestamp ?? a.createdAt;
      final lb = _getLast(b)?.timestamp ?? b.createdAt;
      return lb.compareTo(la);
    });
  }
}