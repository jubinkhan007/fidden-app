import 'dart:async';
import 'package:fidden/core/ws/ws_service.dart';
import 'package:fidden/features/inbox/controller/inbox_controller.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';

import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';

// imports stay the same
import 'package:fidden/features/inbox/controller/inbox_controller.dart';
import 'package:fidden/features/inbox/data/thread_data_model.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';

// ...

class ChatController extends GetxController {
  ChatController({
    required this.threadId,
    required this.shopId,
    required this.shopName,
    required this.isOwner,
    List<MessageModel>? seedMessages,
  }) {
    if (seedMessages != null && seedMessages.isNotEmpty) {
      final sorted = [...seedMessages]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      messages.assignAll(sorted);
    }
  }

  final int threadId;
  final int shopId;
  final String shopName;
  final bool isOwner;

  final messages = <MessageModel>[].obs;
  final sending = false.obs;

  late WsService _ws;
  StreamSubscription? _msgSub;
  StreamSubscription? _ackSub;

  // NEW: resolved once at init
  int _myActorIdResolved = -1;
  int get _myActorId => _myActorIdResolved;

  void _computeMyActorId() {
    if (isOwner) {
      _myActorIdResolved = shopId;
      return;
    }

    // Prefer the thread user id (correct actor id for end-user)
    Thread? t;
    if (Get.isRegistered<InboxController>()) {
      final inbox = Get.find<InboxController>();
      for (final th in inbox.threads) {
        if (th.id == threadId) {
          t = th;
          break;
        }
      }
    }
    if (t != null) {
      _myActorIdResolved = t.user;
      return;
    }

    // Fallback to profile numeric id
    final profile = Get.find<ProfileController>();
    final raw = profile.profileDetails.value.data?.id;
    _myActorIdResolved = int.tryParse('${raw ?? ''}') ?? -1;
  }

  @override
  void onInit() {
    super.onInit();

    _computeMyActorId(); // <<< IMPORTANT

    _ws = Get.put(WsService(), permanent: true);
    _ws.ensureConnected();
    _ws.subscribeThread(threadId);

    _msgSub = _ws.messages$.listen((ev) {
      if (ev.threadId != threadId) return;

      final already = messages.any((m) => m.id == ev.message.id);
      if (!already) messages.insert(0, ev.message);

      _touchInbox(ev.message);

      // mark as read only if message is from the other actor
      if (ev.message.sender != _myActorId && ev.message.isRead == false) {
        _markTheseRead([ev.message.id]);
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

    // mark initial incoming as read
    Future.microtask(markThreadRead);
  }

  void markThreadRead() {
    final ids = messages
        .where((m) => m.isRead == false && m.sender != _myActorId)
        .map((m) => m.id)
        .toList();
    if (ids.isEmpty) return;

    _ws.sendMarkRead(threadId, ids);

    // optimistic flip
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (!m.isRead && m.sender != _myActorId) {
        messages[i] = m.copyWith(isRead: true);
      }
    }
    messages.refresh();
  }

  // ... send(), _markTheseRead(), _touchInbox(), onClose() stay unchanged

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

    sending.value = true;
    try {
      final body = {'content': text};
      // The HTTP request logic remains the same.
      if (isOwner) {
        await NetworkCaller().postRequest(
          AppUrls.replyInThread(threadId),
          body: body,
          token: AuthService.accessToken,
        );
      } else {
        await NetworkCaller().postRequest(
          AppUrls.sendToShop(shopId),
          body: body,
          token: AuthService.accessToken,
        );
      }

      // REMOVE the optimistic update block.
      // The WebSocket listener will now be responsible for adding the message.
    } finally {
      sending.value = false;
    }
  }

  void _touchInbox(MessageModel m) {
    if (!Get.isRegistered<InboxController>()) return;
    final inbox = Get.find<InboxController>();
    inbox.patchLastMessage(threadId, m);
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _ackSub?.cancel();
    super.onClose();
  }
}
