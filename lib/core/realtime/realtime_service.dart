// Flutter 3.35.x
// realtime_service.dart — WebSocket client with:
// - Authorization header
// - Multiple path fallbacks
// - Exponential backoff
// - Safe JSON (handles bytes)
// - Dedupe by eventId
// - Optional version guard
// - Connection status notifier

import 'dart:async'; // Timer, Future
import 'dart:convert'; // jsonDecode, utf8.decode
import 'package:flutter/foundation.dart'; // ValueNotifier
import 'package:web_socket_channel/io.dart'; // IOWebSocketChannel

import 'event_models.dart'; // RealtimeEvent model
import 'realtime_bus.dart'; // RealtimeBus singleton
import 'retry.dart'; // ExponentialBackoff helper

class RealtimeService {
  IOWebSocketChannel? _ch; // current channel (null when closed)
  Timer? _ping; // heartbeat timer
  final _backoff = ExponentialBackoff(); // backoff calculator

  bool _connecting = false; // prevent double connect attempts
  bool _manual = false; // true when closed on purpose (no auto-retry)

  late String _httpBase; // http base (e.g., http://host:8080) — no /api
  late String _token; // JWT token string (already trimmed)
  List<String> _paths = const [
    '/ws',
    '/ws/events',
    '/realtime',
    '/socket',
  ]; // paths to try
  int _pathIndex = 0; // current path index

  final Set<String> _seen = <String>{}; // dedupe cache by eventId
  final Map<int, int> _lastVersion = <int, int>{}; // last version per resource

  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(
    false,
  ); // live flag

  void connect({
    required String httpBase, // backend root without /api
    required String token, // JWT token
    List<String>? candidatePaths, // optional overrides for paths
  }) {
    _manual = false; // allow auto-reconnect
    _httpBase = httpBase; // save base
    _token = token; // save token
    if (candidatePaths != null && candidatePaths.isNotEmpty) {
      _paths = candidatePaths; // override default paths
    }
    _pathIndex = 0; // start from first path
    _open(); // open socket
  }

  void reconnectWithToken(String token) {
    _token = token; // update JWT
    _close(); // close current channel
    _open(); // reopen with new token
  }

  void _open() {
    if (_connecting) return; // skip if already connecting
    _connecting = true; // lock
    final wsUrl = _buildWsUrl(_paths[_pathIndex]); // ws://... url
    if (!wsUrl.startsWith('ws://') && !wsUrl.startsWith('wss://')) {
      _connecting = false; // unlock
      _scheduleReconnect(); // try again later
      return; // stop
    }
    try {
      _ch = IOWebSocketChannel.connect(
        Uri.parse(wsUrl), // connect url
        headers: {'Authorization': 'Bearer $_token'}, // send Authorization
      );
      _ch!.stream.listen(
        _onRawMessage, // incoming frames
        onDone: _onDone, // socket closed
        onError: _onError, // error happened
        cancelOnError: true, // stop stream on error
      );
      _onOpen(); // mark connected
    } catch (_) {
      _connecting = false; // unlock
      _tryNextPathOrBackoff(); // try another path or backoff
    }
  }

  String _buildWsUrl(String path) {
    final u = Uri.parse(_httpBase); // parse http base
    final scheme = (u.scheme == 'https') ? 'wss' : 'ws'; // choose ws/wss
    final host = u.host; // host name/IP
    final port = u.hasPort ? ':${u.port}' : ''; // optional port
    final p = path.startsWith('/') ? path : '/$path'; // ensure leading /
    return '$scheme://$host$port$p'; // final ws url
  }

  void _onOpen() {
    _connecting = false; // unlock connecting
    _backoff.reset(); // reset backoff to base
    isConnected.value = true; // set live flag
    _startPing(); // start heartbeat
  }

  void _onRawMessage(dynamic raw) {
    try {
      final text = raw is String
          ? raw
          : utf8.decode(raw as List<int>); // bytes→string
      final map = jsonDecode(text) as Map<String, dynamic>; // string→map
      final ev = RealtimeEvent.fromJson(map); // map→event

      if (ev.eventId.isNotEmpty) {
        // has id?
        if (_seen.contains(ev.eventId)) {
          // already seen?
          return; // skip duplicate
        }
        _seen.add(ev.eventId); // mark seen
        if (_seen.length > 1024) _seen.clear(); // simple cap
      }

      if (ev.version != null) {
        // has version?
        final last = _lastVersion[ev.resourceId] ?? -1; // read last
        if (ev.version! < last) return; // drop older event
        _lastVersion[ev.resourceId] = ev.version!; // update last
      }

      RealtimeBus.I.emit(ev); // broadcast to app
    } catch (_) {
      // ignore malformed frames (keep socket alive)
    }
  }

  void _onDone() {
    _stopPing(); // stop heartbeats
    _clearChannel(); // drop channel ref
    isConnected.value = false; // mark offline
    if (_manual) return; // if manual close, stop here
    _tryNextPathOrBackoff(); // else retry
  }

  void _onError(Object _) {
    _stopPing(); // stop heartbeats
    _clearChannel(); // drop channel ref
    isConnected.value = false; // mark offline
    if (_manual) return; // if manual close, stop here
    _tryNextPathOrBackoff(); // else retry
  }

  void _tryNextPathOrBackoff() {
    if (_pathIndex < _paths.length - 1) {
      // more paths?
      _pathIndex++; // next path
      Future.delayed(const Duration(milliseconds: 300), _open); // quick retry
      return; // done
    }
    _pathIndex = 0; // reset to first
    _scheduleReconnect(); // backoff retry
  }

  void _scheduleReconnect() {
    final wait = _backoff.next(); // next delay
    Future.delayed(wait, _open); // schedule open
  }

  void _startPing() {
    _ping?.cancel(); // clear old timer
    _ping = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _ch?.sink.add('{"type":"ping"}'); // send simple ping
      } catch (_) {
        // ignore send errors
      }
    });
  }

  void _stopPing() => _ping?.cancel(); // stop the timer

  void _clearChannel() {
    _ch = null; // clear channel instance
  }

  void _close() {
    _stopPing(); // stop ping
    _manual = true; // disable auto-reconnect
    try {
      _ch?.sink.close(); // ask server to close
    } catch (_) {
      // ignore close error
    }
    _clearChannel(); // drop ref
  }

  void dispose() => _close(); // public dispose
}
