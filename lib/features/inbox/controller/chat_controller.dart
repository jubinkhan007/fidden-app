import 'dart:async';
import 'package:fidden/core/ws/ws_service.dart';
import 'package:fidden/features/inbox/controller/inbox_controller.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/inbox/services/paged_messages.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

// imports stay the same
import 'package:fidden/features/inbox/controller/inbox_controller.dart';
import 'package:fidden/features/inbox/data/thread_data_model.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';


class ChatController extends GetxController {
  ChatController({
    required this.threadId,
    required this.shopId,
    required this.shopName,
    required this.isOwner,
    List<MessageModel>? seedMessages,
  }) {
    if (seedMessages != null && seedMessages.isNotEmpty) {
      final sorted = [...seedMessages]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      messages.assignAll(sorted);
    }
  }

  final int threadId;
  final int shopId;
  final String shopName;
  final bool isOwner;

  final messages = <MessageModel>[].obs;   // DESC (newest first) in UI
  final sending = false.obs;

  late WsService _ws;
  StreamSubscription? _msgSub;
  StreamSubscription? _ackSub;

  int _myActorIdResolved = -1;
  int get _myActorId => _myActorIdResolved;

  String? _nextCursor;                // NEW: pagination
  final isPaging = false.obs;
  bool get hasMore => _nextCursor != null;


  void _computeMyActorId() {
    if (isOwner) { _myActorIdResolved = shopId; return; }
    Thread? t;
    if (Get.isRegistered<InboxController>()) {
      t = Get.find<InboxController>().threads.firstWhereOrNull((th) => th.id == threadId);
    }
    if (t != null) { _myActorIdResolved = t.user; return; }
    final profile = Get.find<ProfileController>();
    _myActorIdResolved = int.tryParse('${profile.profileDetails.value.data?.id ?? ''}') ?? -1;
  }

  @override
  void onInit() {
    super.onInit();
    _computeMyActorId();
    _ws = Get.put(WsService(), permanent: true);
    _ws.ensureConnected();
    _ws.subscribeThread(threadId);

    // Initial page load from API
    _loadFirstPage();

    _msgSub = _ws.messages$.listen((ev) {
      if (ev.threadId != threadId) return;
      _replaceOptimisticIfMatch(ev.message);
      if (ev.message.sender != _myActorId) {
        final already = messages.any((m) => m.id == ev.message.id);
        if (!already) messages.insert(0, ev.message);
        _touchInbox(ev.message);
        if (!ev.message.isRead) _markTheseRead([ev.message.id]);
      }
    });

    _ackSub = _ws.markReadAcks$.listen((ack) {
      if (ack.threadId != threadId) return;
      if (ack.messageIds.isEmpty) {
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          if (!m.isRead && m.sender != _myActorId) {
            messages[i] = m.copyWith(isRead: true);
          }
        }
      } else {
        final set = ack.messageIds.toSet();
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          if (!m.isRead && set.contains(m.id)) {
            messages[i] = m.copyWith(isRead: true);
          }
        }
      }
      messages.refresh();
    });

    // optimistic marking for whatever came first page
    // Future.microtask(markThreadRead);
  }
final isInitialLoading = false.obs;
    Future<void> _loadFirstPage() async {
    isInitialLoading.value = true;     // NEW
    try {
      final url = '${AppUrls.threads}$threadId/';
      final resp = await NetworkCaller().getRequest(url, token: AuthService.accessToken);
      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final page = PagedMessages.fromJson(Map<String, dynamic>.from(resp.responseData));
        _nextCursor = page.next;
        messages.assignAll(page.results);  // DESC
        if (messages.isNotEmpty) _touchInbox(messages.first);
        markThreadRead();
      }
    } catch (_) {
      // swallow
    } finally {
      isInitialLoading.value = false;  // NEW
    }
  }

  Future<void> loadMore() async {
    if (_nextCursor == null || isPaging.value) return;
    isPaging.value = true;
    try {
      final resp = await NetworkCaller().getRequest(_nextCursor!, token: AuthService.accessToken);
      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        final page = PagedMessages.fromJson(Map<String, dynamic>.from(resp.responseData));
        _nextCursor = page.next;
        // Append older messages to the end (list is DESC)
        final incoming = page.results;
        // avoid dupes
        for (final m in incoming) {
          if (!messages.any((x) => x.id == m.id)) messages.add(m);
        }
        messages.refresh();
      }
    } finally {
      isPaging.value = false;
    }
  }

  void markThreadRead() {
    final ids = messages
        .where((m) => !m.isRead && m.sender != _myActorId)
        .map((m) => m.id)
        .toList();
    if (ids.isEmpty) return;
    _ws.sendMarkRead(threadId, ids);
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (!m.isRead && m.sender != _myActorId) {
        messages[i] = m.copyWith(isRead: true);
      }
    }
    messages.refresh();
  }

  void _markTheseRead(List<int> ids) {
    if (ids.isEmpty) return;
    _ws.sendMarkRead(threadId, ids);
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (!m.isRead && ids.contains(m.id)) {
        messages[i] = m.copyWith(isRead: true);
      }
    }
    messages.refresh();
  }

  Future<void> send(String content) async {
    final text = content.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final tempLocalId = 'local_${now.microsecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: -now.microsecondsSinceEpoch,
      threadId: threadId,                  // NEW
      sender: _myActorId,
      senderEmail: _guessMyEmail(),
      content: text,
      timestamp: now,
      isRead: true,
      localId: tempLocalId,
      status: MessageStatus.sending,
    );
    messages.insert(0, optimistic);

    try {
      sending.value = true;
      final body = {'content': text};
      if (isOwner) {
        await NetworkCaller().postRequest(AppUrls.replyInThread(threadId), body: body, token: AuthService.accessToken);
      } else {
        await NetworkCaller().postRequest(AppUrls.sendToShop(shopId), body: body, token: AuthService.accessToken);
      }
      Future.delayed(const Duration(seconds: 3), () {
        final idx = messages.indexWhere((m) => m.localId == tempLocalId);
        if (idx != -1 && messages[idx].status == MessageStatus.sending) {
          messages[idx] = messages[idx].copyWith(status: MessageStatus.sent);
        }
      });
    } catch (_) {
      final idx = messages.indexWhere((m) => m.localId == tempLocalId);
      if (idx != -1) messages[idx] = messages[idx].copyWith(status: MessageStatus.failed);
    } finally {
      sending.value = false;
    }
  }

  String _guessMyEmail() {
    if (!Get.isRegistered<ProfileController>()) return '';
    return Get.find<ProfileController>().profileDetails.value.data?.email ?? '';
  }

  Future<void> resend(MessageModel failed) async {
    if (failed.status != MessageStatus.failed) return;
    final idx = messages.indexWhere((m) => m.localId == failed.localId);
    if (idx == -1) return;
    messages[idx] = failed.copyWith(status: MessageStatus.sending);

    try {
      final body = {'content': failed.content};
      if (isOwner) {
        await NetworkCaller().postRequest(AppUrls.replyInThread(threadId), body: body, token: AuthService.accessToken);
      } else {
        await NetworkCaller().postRequest(AppUrls.sendToShop(shopId), body: body, token: AuthService.accessToken);
      }
      Future.delayed(const Duration(seconds: 3), () {
        final j = messages.indexWhere((m) => m.localId == failed.localId);
        if (j != -1 && messages[j].status == MessageStatus.sending) {
          messages[j] = messages[j].copyWith(status: MessageStatus.sent);
        }
      });
    } catch (_) {
      final j = messages.indexWhere((m) => m.localId == failed.localId);
      if (j != -1) messages[j] = messages[j].copyWith(status: MessageStatus.failed);
    }
  }

  /// Replace optimistic with server echo
  void _replaceOptimisticIfMatch(MessageModel incoming) {
    if (incoming.sender != _myActorId) return;
    final i = messages.indexWhere((m) =>
        m.status != MessageStatus.sent &&
        m.sender == _myActorId &&
        m.content == incoming.content &&
        (m.timestamp.difference(incoming.timestamp).inSeconds).abs() <= 10);
    if (i != -1) {
      messages[i] = incoming.copyWith(status: MessageStatus.sent, localId: null);
    } else {
      if (!messages.any((m) => m.id == incoming.id)) messages.insert(0, incoming);
    }
    _touchInbox(incoming);
  }

  void _touchInbox(MessageModel m) {
    if (!Get.isRegistered<InboxController>()) return;
    Get.find<InboxController>().patchLastMessage(threadId, m);
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _ackSub?.cancel();
    super.onClose();
  }
}