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
  _computeMyActorId();
  _ws = Get.put(WsService(), permanent: true);
  _ws.ensureConnected();
  _ws.subscribeThread(threadId);

  _msgSub = _ws.messages$.listen((ev) {
    if (ev.threadId != threadId) return;

    // Try to replace optimistic first
    _replaceOptimisticIfMatch(ev.message);

    // For other-party messages, normal add + read
    if (ev.message.sender != _myActorId) {
      final already = messages.any((m) => m.id == ev.message.id);
      if (!already) messages.insert(0, ev.message);
      _touchInbox(ev.message);
      if (ev.message.isRead == false) _markTheseRead([ev.message.id]);
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

  // 1) Create optimistic message
  final now = DateTime.now();
  final tempLocalId = 'local_${now.microsecondsSinceEpoch}';
  final optimistic = MessageModel(
    id: -now.microsecondsSinceEpoch,      // temp negative id
    sender: _myActorId,
    senderEmail: _guessMyEmail(),         // optional helper
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

    // 2) Wait for the WebSocket echo. When it arrives, we replace the optimistic one.
    //    In case it doesn't come (rare), mark as sent after a short delay to avoid stuck "sending".
    Future.delayed(const Duration(seconds: 3), () {
      final idx = messages.indexWhere((m) => m.localId == tempLocalId);
      if (idx != -1 && messages[idx].status == MessageStatus.sending) {
        messages[idx] = messages[idx].copyWith(status: MessageStatus.sent);
      }
    });
  } catch (_) {
    // 3) Mark as failed (shows retry UI)
    final idx = messages.indexWhere((m) => m.localId == tempLocalId);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(status: MessageStatus.failed);
    }
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
  // Turn it back to "sending"
  final idx = messages.indexWhere((m) => m.localId == failed.localId);
  if (idx == -1) return;
  messages[idx] = failed.copyWith(status: MessageStatus.sending);

  try {
    final body = {'content': failed.content};
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
    // WS will replace/confirm; fallback timer:
    Future.delayed(const Duration(seconds: 3), () {
      final j = messages.indexWhere((m) => m.localId == failed.localId);
      if (j != -1 && messages[j].status == MessageStatus.sending) {
        messages[j] = messages[j].copyWith(status: MessageStatus.sent);
      }
    });
  } catch (_) {
    // Still failed; flip back
    final j = messages.indexWhere((m) => m.localId == failed.localId);
    if (j != -1) {
      messages[j] = messages[j].copyWith(status: MessageStatus.failed);
    }
  }
}


/// Replace optimistic message when server WS message arrives
void _replaceOptimisticIfMatch(MessageModel incoming) {
  // Only try to match my outgoing messages
  if (incoming.sender != _myActorId) return;

  // Find optimistic message with same content within 10s window
  final i = messages.indexWhere((m) =>
      m.status != MessageStatus.sent &&
      m.sender == _myActorId &&
      m.content == incoming.content &&
      (m.timestamp.difference(incoming.timestamp).inSeconds).abs() <= 10);

  if (i != -1) {
    // Replace optimistic with the server message (real id, status=sent)
    messages[i] = incoming.copyWith(status: MessageStatus.sent, localId: null);
  } else {
    // If not found, just insert if not duplicated by id
    final already = messages.any((m) => m.id == incoming.id);
    if (!already) messages.insert(0, incoming);
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
