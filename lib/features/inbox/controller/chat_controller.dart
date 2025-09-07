import 'dart:async';
import 'dart:convert';
import 'package:fidden/features/inbox/controller/inbox_controller.dart';
import 'package:fidden/features/user/profile/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import '../../inbox/data/message_model.dart';

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
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first
      messages.assignAll(sorted);
    }
  }

  final int threadId;
  final int shopId;
  final String shopName;
  final bool isOwner;

  // UI observables
  final messages = <MessageModel>[].obs;
  final sending = false.obs;

  // socket pieces
  WebSocketChannel? _ch;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;

  bool _closing = false;
  bool _markReadSent = false;
  late final int myUserId;

  // track server message ids to avoid duplicates when server echoes
  final Set<int> _seenServerIds = <int>{};

  /// If your backend needs a join frame, set the event name here.
  /// If it doesn't need joining, set to null.
  static const String? _subscribeEvent =
      null; // 'join', 'subscribe_thread', or null

  @override
  void onInit() {
    super.onInit();
    final profile = Get.find<ProfileController>();
    myUserId = int.tryParse(profile.profileDetails.value.data?.id ?? '') ?? -1;
    _connect();
  }

  // ───────────────────────── CONNECT / RECONNECT ─────────────────────────

  void _connect() {
    final token = AuthService.accessToken ?? '';
    if (token.isEmpty) {
      print('WS ABORT: empty token');
      return;
    }

    final url = AppUrls.socketUrl(token);
    final headers = {
      // keep if your proxy/back-end enforces Origin; otherwise you can remove
      'Origin': 'https://fidden-service-provider-1.onrender.com',
    };

    // Request log
    print('──────── WS REQUEST ────────');
    print('GET $url');
    headers.forEach((k, v) => print('$k: $v'));
    print('────────────────────────────');

    _cleanupChannel(); // ensure no leftover channel/listener

    try {
      _ch = IOWebSocketChannel.connect(
        Uri.parse(url),
        pingInterval: const Duration(seconds: 20),
        headers: headers,
      );

      print('──────── WS CONNECTED ──────');
      print('channel ready');
      print('────────────────────────────');

      _sub = _ch!.stream.listen(
        _onSocketData,
        onError: (e, st) {
          print('WS onError => $e');
          if (!_closing) _scheduleReconnect();
        },
        onDone: () {
          print('WS onDone (closed by server/client).');
          if (!_closing) _scheduleReconnect();
        },
        cancelOnError: true,
      );

      // Join thread first (if required), then mark as read
      if (_subscribeEvent != null) {
        Future.microtask(_subscribeToThread);
      }
      Future.delayed(const Duration(milliseconds: 100), _sendMarkReadOnce);
    } catch (e) {
      print('──────── WS CONNECT FAIL ───');
      print(e);
      print('────────────────────────────');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_closing || (_reconnectTimer?.isActive ?? false)) return;
    // clean up before retrying
    _cleanupChannel();
    _reconnectTimer = Timer(const Duration(seconds: 2), _connect);
  }

  void _cleanupChannel() {
    _sub?.cancel();
    _sub = null;
    _ch?.sink.close();
    _ch = null;
  }

  // ───────────────────────── SEND HELPERS ─────────────────────────

  void _sendFrame(Map<String, dynamic> frame) {
    final s = jsonEncode(frame);
    print('WS ⇒ $s');
    _ch?.sink.add(s);
  }

  void _subscribeToThread() {
    _sendFrame({
      'type': _subscribeEvent, // 'subscribe' | 'join' | 'subscribe_thread'
      'thread_id': threadId,
    });
  }

  void _sendMarkReadOnce() {
    if (_markReadSent) return;
    _markReadSent = true;
    _sendFrame({'action': 'mark_read', 'thread_id': threadId});
  }

  // ───────────────────────── RECEIVE ─────────────────────────

  void _onSocketData(dynamic raw) {
    final s = raw is List<int>
        ? utf8.decode(raw, allowMalformed: true)
        : raw.toString();
    print('WS ⇐ $s');

    try {
      final data = jsonDecode(s) as Map<String, dynamic>;
      final type = (data['type'] ?? '').toString();

      if (type == 'chat_message' || type == 'message') {
        final payload = Map<String, dynamic>.from(
          (data['message'] ?? data['payload'] ?? const {}),
        );
        if (payload.isEmpty) return;

        final m = MessageModel.fromJson(payload);

        // De-dupe based on real server id
        if (m.id is int && m.id > 0) {
          if (_seenServerIds.contains(m.id)) return;
          _seenServerIds.add(m.id);

          // If this is *my* message and I inserted an optimistic copy, replace it
          if (_tryReplaceOptimistic(m)) return;
        }

        // reverse:true in ListView → newest must be at index 0
        messages.insert(0, m);
        _touchInbox(m);
      }

      // You could handle other server frames here (acks, pings, etc.)
    } catch (e, st) {
      print('WS parse error: $e\n$st');
    }
  }

  bool _tryReplaceOptimistic(MessageModel incoming) {
    final myActorId = isOwner ? shopId : myUserId;
    if (incoming.sender != myActorId) return false;

    final idx = messages.indexWhere(
      (x) =>
          x.id < 0 &&
          x.sender == myActorId &&
          x.content == incoming.content &&
          (incoming.timestamp.difference(x.timestamp).inSeconds).abs() <= 10,
    );
    if (idx == -1) return false;

    messages[idx] = incoming;
    _touchInbox(incoming);
    return true;
  }

  void _touchInbox(MessageModel m) {
    if (!Get.isRegistered<InboxController>()) return;
    Get.find<InboxController>().patchLastMessage(threadId, m);
  }

  // ───────────────────────── PUBLIC API ─────────────────────────

  /// Your ChatScreen also calls this once after first frame.
  void markThreadRead() => _sendMarkReadOnce();

  Future<void> send(String content) async {
    final text = content.trim();
    if (text.isEmpty) return;

    sending.value = true;
    try {
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

      // optimistic insert (negative id)
      final myActorId = isOwner ? shopId : myUserId;
      messages.insert(
        0,
        MessageModel(
          id: -DateTime.now().millisecondsSinceEpoch,
          sender: myActorId,
          senderEmail: '',
          content: text,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    } finally {
      sending.value = false;
    }
  }

  @override
  void onClose() {
    _closing = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cleanupChannel();
    super.onClose();
  }
}
