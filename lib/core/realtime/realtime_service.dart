// Flutter 3.35.x
// WebSocket client with: Authorization header, path fallbacks, backoff, safe logging.

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

import 'event_models.dart';
import 'realtime_bus.dart';
import 'retry.dart';

class RealtimeService {
  IOWebSocketChannel? _ch;
  Timer? _ping;
  final _backoff = ExponentialBackoff();

  // config
  late String _httpBase; // e.g. http://host:8080 (no /api)
  late String _token; // JWT
  List<String> _paths = const ['/ws', '/ws/events', '/realtime', '/socket'];
  int _pathIndex = 0; // which path we’re trying

  // state
  bool _connecting = false;

  /// Connect using your HTTP base (NO `/api`) and JWT.
  /// It will try several known websocket paths until one upgrades successfully.
  void connect({
    required String httpBase,
    required String token,
    List<String>? candidatePaths,
  }) {
    _httpBase = httpBase;
    _token = token;
    if (candidatePaths != null && candidatePaths.isNotEmpty) {
      _paths = candidatePaths;
    }
    _pathIndex = 0;
    _open();
  }

  /// If your JWT changes later.
  void reconnectWithToken(String token) {
    _token = token;
    _close();
    _open();
  }

  void _open() {
    if (_connecting) return;
    _connecting = true;

    final wsUrl = _buildWsUrl(_paths[_pathIndex]);
    if (!wsUrl.startsWith('ws://') && !wsUrl.startsWith('wss://')) {
      // ignore: avoid_print
      print(
        'RealtimeService: BAD URL "$wsUrl" (must start with ws:// or wss://)',
      );
      _connecting = false;
      _scheduleReconnect();
      return;
    }

    // ignore: avoid_print
    print('RealtimeService: connecting → $wsUrl (path ${_paths[_pathIndex]})');

    try {
      _ch = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Authorization': 'Bearer $_token'},
      );

      _ch!.stream.listen(
        _onRawMessage,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );

      _onOpen();
    } catch (e) {
      // ignore: avoid_print
      print('RealtimeService: connect threw → $e');
      _connecting = false;
      _tryNextPathOrBackoff();
    }
  }

  String _buildWsUrl(String path) {
    // build ws://host:port/<path> from _httpBase
    final u = Uri.parse(_httpBase);
    final scheme = (u.scheme == 'https') ? 'wss' : 'ws';
    final host = u.host;
    final port = u.hasPort ? ':${u.port}' : '';
    final p = path.startsWith('/') ? path : '/$path';
    return '$scheme://$host$port$p';
  }

  void _onOpen() {
    _connecting = false;
    _backoff.reset();
    _startPing();
  }

  void _onRawMessage(dynamic raw) {
    try {
      final map = jsonDecode(raw as String) as Map<String, dynamic>;
      final ev = RealtimeEvent.fromJson(map);
      RealtimeBus.I.emit(ev);
    } catch (_) {
      // ignore bad frames
    }
  }

  void _onDone() {
    _stopPing();
    // If the socket closed immediately with 404, try next path quickly
    _tryNextPathOrBackoff();
  }

  void _onError(Object e) {
    _stopPing();
    // ignore: avoid_print
    print('RealtimeService: socket error → $e');
    _tryNextPathOrBackoff();
  }

  void _tryNextPathOrBackoff() {
    // Try other paths first (typical 404/upgrade mismatch)
    if (_pathIndex < _paths.length - 1) {
      _pathIndex++;
      // ignore: avoid_print
      print(
        'RealtimeService: retry with alternate path "${_paths[_pathIndex]}"',
      );
      Future.delayed(const Duration(milliseconds: 300), _open);
      return;
    }

    // All paths failed → backoff and restart from first path
    _pathIndex = 0;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    final wait = _backoff.next();
    // ignore: avoid_print
    print('RealtimeService: reconnect in ${wait.inSeconds}s');
    Future.delayed(wait, _open);
  }

  void _startPing() {
    _ping?.cancel();
    _ping = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _ch?.sink.add('{"type":"ping"}');
      } catch (_) {}
    });
  }

  void _stopPing() => _ping?.cancel();

  void _close() {
    _stopPing();
    _ch?.sink.close();
    _ch = null;
  }

  void dispose() => _close();
}
