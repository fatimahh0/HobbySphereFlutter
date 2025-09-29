// Flutter 3.35.x
// retry.dart — Small exponential backoff helper for reconnect delays.

class ExponentialBackoff {
  final Duration base; // base delay (e.g., 1 second)
  final Duration max; // max delay (e.g., 30 seconds)
  int _attempt = 0; // attempt counter

  ExponentialBackoff({
    this.base = const Duration(seconds: 1), // default base 1s
    this.max = const Duration(seconds: 30), // default cap 30s
  });

  Duration next() {
    final secs = base.inSeconds * (1 << _attempt); // 1,2,4,8,16,32...
    _attempt = (_attempt + 1).clamp(0, 10); // cap attempts at 10
    final d = Duration(seconds: secs); // convert to duration
    return d > max ? max : d; // cap at max duration
  }

  void reset() => _attempt = 0; // reset after a successful connect
}
