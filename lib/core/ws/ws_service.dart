// lib/core/ws/ws_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/inbox/data/message_model.dart';
import 'package:fidden/core/notifications/notification_service.dart';

/// Events your controllers listen to
class IncomingMessage {
  final int threadId;
  final MessageModel message;
  IncomingMessage(this.threadId, this.message);
}

class MarkReadAck {
  final int threadId;
  final List<int> messageIds;
  MarkReadAck(this.threadId, this.messageIds);
}

class WsService extends GetxService with WidgetsBindingObserver {
  IOWebSocketChannel? _ch;
  StreamSubscription? _sub;
  StreamSubscription? _connSub;

  // reconnect bookkeeping
  bool _connecting = false;
  bool _manuallyClosed = false;
  Timer? _retryTimer;
  int _backoffSec = 2; // exponential backoff up to 60s

  // subscriptions: thread IDs we’ve joined
  final Set<int> _subscribedThreads = <int>{};

  // queue frames while disconnected
  final List<Map<String, dynamic>> _outbox = <Map<String, dynamic>>[];

  // streams exposed to the app
  final _msgCtrl = StreamController<IncomingMessage>.broadcast();
  final _ackCtrl = StreamController<MarkReadAck>.broadcast();

  Stream<IncomingMessage> get messages$ => _msgCtrl.stream;
  Stream<MarkReadAck> get markReadAcks$ => _ackCtrl.stream;

  // For deduping notification banners (if server sends both notification+chat)
  final Set<String> _seenNotifyIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // react to connectivity
    _connSub = Connectivity().onConnectivityChanged.listen((result) {
      final online = result != ConnectivityResult.none;
      if (online) {
        // kick a reconnect soon
        _scheduleReconnect(soon: true);
      } else {
        _teardownChannel(); // close quickly when offline
      }
    });
  }

  Future<void> ensureConnected() async {
    if (_ch != null || _connecting) return;
    _connect();
  }

  // Public API ---------------------------------------------------------------

  void subscribeThread(int threadId) {
    if (threadId <= 0) return;
    if (_subscribedThreads.add(threadId)) {
      _send({'type': 'subscribe', 'thread_id': threadId, 'thread': threadId});
    }
  }

  void subscribeThreads(Iterable<int> ids) {
    for (final id in ids) {
      subscribeThread(id);
    }
  }

  void sendMarkRead(int threadId, List<int> messageIds) {
    _send({'action': 'mark_read', 'thread_id': threadId});
  }

  // Core wiring --------------------------------------------------------------

  void _connect() async {
    if (_connecting) return;
    _connecting = true;
    _manuallyClosed = false;

    final token = AuthService.accessToken ?? '';
    if (token.isEmpty) {
      _connecting = false;
      return; // no token yet
    }

    final url = AppUrls.socketUrl(token);
    final headers = {
      'Origin': 'https://fidden-service-provider-1.onrender.com',
    };

    print('──────── WS REQUEST (GLOBAL) ────────');
    print('GET $url');
    headers.forEach((k, v) => print('$k: $v'));
    print('─────────────────────────────────────');

    try {
      // If we were already connected, clean up first
      _teardownChannel();

      _ch = IOWebSocketChannel.connect(
        Uri.parse(url),
        pingInterval: const Duration(seconds: 20),
        headers: headers,
      );

      print('──────── WS CONNECTED (GLOBAL) ─────');
      print('channel ready');
      print('─────────────────────────────────────');

      // Reset backoff after a successful connection
      _backoffSec = 2;

      _sub = _ch!.stream.listen(
        _onData,
        onError: (e, st) {
          print('WS onError (GLOBAL) => $e');
          _scheduleReconnect();
        },
        onDone: () {
          print('WS onDone (GLOBAL).');
          if (!_manuallyClosed) _scheduleReconnect();
        },
        cancelOnError: true,
      );

      // Flush pending subscribes and frames
      if (_subscribedThreads.isNotEmpty) {
        for (final id in _subscribedThreads) {
          _send({'type': 'subscribe', 'thread_id': id, 'thread': id});
        }
      }
      _flushOutbox();
    } catch (e) {
      print('WS CONNECT FAIL (GLOBAL) => $e');
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _scheduleReconnect({bool soon = false}) {
    if (_manuallyClosed) return;
    _retryTimer?.cancel();
    final delay = Duration(seconds: soon ? 1 : _backoffSec.clamp(1, 60));
    print('WS will retry in ${delay.inSeconds}s …');
    _retryTimer = Timer(delay, _connect);
    if (!soon && _backoffSec < 60) _backoffSec *= 2;
  }

  void _teardownChannel() {
    _sub?.cancel();
    _sub = null;
    try {
      _ch?.sink.close();
    } catch (_) {}
    _ch = null;
  }

  void _send(Map<String, dynamic> frame) {
    final s = jsonEncode(frame);
    if (_ch == null) {
      _outbox.add(frame);
    } else {
      try {
        print('WS[G] ⇒ $s');
        _ch!.sink.add(s);
      } catch (_) {
        _outbox.add(frame);
      }
    }
  }

  void _flushOutbox() {
    if (_ch == null || _outbox.isEmpty) return;
    final copy = List<Map<String, dynamic>>.from(_outbox);
    _outbox.clear();
    for (final f in copy) {
      _send(f);
    }
  }

  void _onData(dynamic raw) async {
    final s = raw is List<int>
        ? utf8.decode(raw, allowMalformed: true)
        : raw.toString();
    print('WS[G] ⇐ $s');

    Map<String, dynamic> data;
    try {
      data = jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = (data['type'] ?? '').toString();

    // 1) Server-side “notification” frames (you logged UNHANDLED earlier)
    if (type == 'notification') {
      final notif = Map<String, dynamic>.from(data['notification'] ?? const {});
      final nType = notif['notification_type']?.toString();
      final msg = notif['message']?.toString() ?? 'New notification';
      final createdAt = notif['created_at']?.toString();
      final id = '${notif['id'] ?? createdAt ?? msg}';

      // Only show once if server also sends chat_message afterwards
      if (nType == 'chat' && id.isNotEmpty && !_seenNotifyIds.contains(id)) {
        _seenNotifyIds.add(id);

        final payload = Map<String, dynamic>.from(notif['data'] ?? const {});
        await NotificationService.I.showMessage(
          title: 'New message',
          body: msg,
          payload: {'type': 'notification', ...payload},
          uniqueId: id,
        );
      }
      return;
    }

    // 2) Real chat message frames
    if (type == 'chat_message' || type == 'message') {
      final payload = Map<String, dynamic>.from(
        (data['message'] ?? data['payload'] ?? const {}),
      );
      if (payload.isEmpty) return;

      final threadId = int.tryParse('${payload['thread_id'] ?? 0}') ?? 0;
      final m = MessageModel.fromJson(payload);

      // De-dupe “notification” we may have just shown above
      _seenNotifyIds.add('${m.id}');

      _msgCtrl.add(IncomingMessage(threadId, m));
      return;
    }
    // Default: just log
    print('WS[G] ⇐ [UNHANDLED:$type] $data');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      print("App resumed, ensuring WebSocket is connected.");
      ensureConnected();
    } else if (state == AppLifecycleState.paused) {
      // App is in the background
      print("App paused, closing WebSocket connection.");
      _teardownChannel(); // <-- ADD THIS LINE
    }
  }

  @override
  void onClose() {
    _manuallyClosed = true;
    _retryTimer?.cancel();
    _retryTimer = null;
    _connSub?.cancel();
    _connSub = null;
    _teardownChannel();
    _msgCtrl.close();
    _ackCtrl.close();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
