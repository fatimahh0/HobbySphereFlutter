// Flutter 3.35.x
// Exponential backoff calculator to reconnect WebSocket safely.

class ExponentialBackoff {
  final Duration base; // base delay (e.g. 1s)
  final Duration max; // max delay (e.g. 30s)
  int _attempt = 0; // attempt counter

  ExponentialBackoff({
    this.base = const Duration(seconds: 1), // default 1s
    this.max = const Duration(seconds: 30), // default 30s
  });

  Duration next() {
    final secs = base.inSeconds * (1 << _attempt); // 1,2,4,8,16,32...
    _attempt = (_attempt + 1).clamp(0, 10); // cap attempts
    final d = Duration(seconds: secs); // to Duration
    return d > max ? max : d; // cap to max
  }

  void reset() => _attempt = 0; // reset after success
}
