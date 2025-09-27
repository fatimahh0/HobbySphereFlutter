// Flutter 3.35.x
// Simple in-memory cache with TTL (time-to-live).
// Goal: keep hot data in RAM for a short window → instant UI.

import 'dart:async'; // Future support

class SimpleCache<T> {
  T? _value; // cached value in RAM
  DateTime? _expiresAt; // when cached value becomes stale
  Future<T>? _inflight; // a single in-flight loader to avoid duplicate calls

  // Return cached value only if still fresh.
  T? getIfFresh() {
    if (_value == null) return null; // nothing cached
    if (_expiresAt == null) return null; // no expiry set
    if (DateTime.now().isBefore(_expiresAt!)) return _value; // still fresh
    return null; // expired
  }

  // Put a value with TTL seconds.
  void put(T value, {required int ttlSeconds}) {
    _value = value; // store value
    _expiresAt = DateTime.now().add(Duration(seconds: ttlSeconds)); // set ttl
  }

  // Get fresh cached value or run loader once and cache it.
  Future<T> getOrLoad(Future<T> Function() loader, {required int ttlSeconds}) {
    final fresh = getIfFresh(); // check freshness
    if (fresh != null) return Future.value(fresh); // immediate return
    if (_inflight != null) return _inflight!; // share ongoing load
    _inflight = loader()
        .then((v) {
          put(v, ttlSeconds: ttlSeconds); // cache loaded value
          return v; // forward value
        })
        .whenComplete(() {
          _inflight = null; // release guard after completion
        });
    return _inflight!; // return the shared future
  }

  // Return last value even if stale (useful for SWR instant paint).
  T? getStale() => _value; // may be null

  // Clear everything (use on logout).
  void clear() {
    _value = null; // drop value
    _expiresAt = null; // drop ttl
    _inflight = null; // drop inflight
  }
}
