import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/inbox/data/message_model.dart';

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

class WsService extends GetxService {
  WebSocketChannel? _ch;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _closing = false;

  // streams the app can listen to
  final _msgCtrl = StreamController<IncomingMessage>.broadcast();
  final _ackCtrl = StreamController<MarkReadAck>.broadcast();

  Stream<IncomingMessage> get messages$ => _msgCtrl.stream;
  Stream<MarkReadAck> get markReadAcks$ => _ackCtrl.stream;

  // keep which threads we subscribed to (if backend needs per-thread subscription)
  final _subscribedThreads = <int>{};

  Future<WsService> ensureConnected() async {
    if (_ch != null) return this;
    _connect();
    return this;
  }

  void _connect() {
    final token = AuthService.accessToken ?? '';
    if (token.isEmpty) {
      print('WS ABORT: empty token');
      return;
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
      _ch = IOWebSocketChannel.connect(
        Uri.parse(url),
        pingInterval: const Duration(seconds: 20),
        headers: headers,
      );
      print('──────── WS CONNECTED (GLOBAL) ─────');
      print('channel ready');
      print('─────────────────────────────────────');

      _sub = _ch!.stream.listen(
        _onSocketData,
        onError: (e, st) {
          print('WS onError (GLOBAL) => $e');
          if (!_closing) _scheduleReconnect();
        },
        onDone: () {
          print('WS onDone (GLOBAL).');
          if (!_closing) _scheduleReconnect();
        },
        cancelOnError: true,
      );

      // re-subscribe threads after reconnect
      if (_subscribedThreads.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 50), () {
          subscribeThreads(_subscribedThreads);
        });
      }
    } catch (e) {
      print('──────── WS CONNECT FAIL (GLOBAL) ──');
      print(e);
      print('─────────────────────────────────────');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_closing || (_reconnectTimer?.isActive ?? false)) return;
    _reconnectTimer = Timer(const Duration(seconds: 2), _connect);
  }

  void _send(Map<String, dynamic> frame) {
    final s = jsonEncode(frame);
    print('WS[G] ⇒ $s');
    _ch?.sink.add(s);
  }

  // PUBLIC API ---------------------------------------------------------------

  /// Subscribe to a single thread (use the exact event name your backend expects)
  void subscribeThread(int threadId) {
    _subscribedThreads.add(threadId);
    _send({'type': 'subscribe', 'thread_id': threadId, 'thread': threadId});
  }

  /// Subscribe to many threads at once
  void subscribeThreads(Iterable<int> threadIds) {
    for (final id in threadIds) {
      subscribeThread(id);
    }
  }

  /// Tell server these messages are read
  void sendMarkRead(int threadId, List<int> messageIds) {
    _send({
      'type': 'mark_read',
      'thread_id': threadId,
      'thread': threadId,
      'message_ids': messageIds,
    });
  }

  // PARSE --------------------------------------------------------------------

  void _onSocketData(dynamic raw) {
    final s = raw is List<int>
        ? utf8.decode(raw, allowMalformed: true)
        : raw.toString();
    print('WS[G] ⇐ $s');

    try {
      final data = jsonDecode(s) as Map<String, dynamic>;
      final type = (data['type'] ?? '').toString();

      // tolerant payload extraction
      final payload =
          (data['message'] ?? data['payload']) as Map<String, dynamic>?;

      switch (type) {
        case 'chat_message':
        case 'message':
          {
            if (payload == null) return;
            final m = MessageModel.fromJson(Map<String, dynamic>.from(payload));
            final tid = _extractThreadId(data, payload);
            if (tid == null) return;
            _msgCtrl.add(IncomingMessage(tid, m));
            break;
          }
        case 'mark_read':
        case 'mark_read_ack':
        case 'ack':
          {
            final tid = data['thread_id'] ?? data['thread'];
            final ids =
                (data['message_ids'] as List?)
                    ?.map((e) => int.tryParse('$e') ?? -1)
                    .where((e) => e > 0)
                    .toList() ??
                const <int>[];
            if (tid != null)
              _ackCtrl.add(MarkReadAck(int.tryParse('$tid') ?? tid, ids));
            break;
          }
        default:
          print('WS[G] ⇐ [UNHANDLED:$type] $data');
      }
    } catch (e, st) {
      print('WS[G] parse error: $e\n$st');
    }
  }

  int? _extractThreadId(
    Map<String, dynamic> data,
    Map<String, dynamic> payload,
  ) {
    final v =
        data['thread_id'] ??
        data['thread'] ??
        payload['thread_id'] ??
        payload['thread'];
    return v == null ? null : (v is int ? v : int.tryParse('$v'));
  }

  // LIFECYCLE ----------------------------------------------------------------

  @override
  void onClose() {
    _closing = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sub?.cancel();
    _sub = null;
    _ch?.sink.close();
    _ch = null;
    _msgCtrl.close();
    _ackCtrl.close();
    super.onClose();
  }
}
