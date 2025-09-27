// Flutter 3.35.x
// Tiny "Instant" cache layer: RAM + Disk + optional image precache.
//
// Usage patterns:
// - Splash: await Instant.preload('user.home', ctx: context);
// - Widget:  final map = Instant.getFresh('user.home') ?? await Instant.readStale('user.home');
// - Widget:  final types = Instant.read<List>('user.home', path: 'types') ?? const [];
// - Bloc hit will refresh and you can write back:
//             Instant.write('user.home', {'types': freshTypes}, merge: true);
//
// Strategy: SWR (stale-while-revalidate).
//   * RAM if fresh -> render immediately
//   * else Disk (stale) -> render fallback
//   * then refresh in background -> RAM+Disk update

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef InstantLoader =
    Future<Map<String, dynamic>> Function(BuildContext? ctx);

class _Entry {
  final Map<String, dynamic> data; // cached map
  final DateTime ts; // stored at
  final int ttl; // seconds
  _Entry(this.data, this.ts, this.ttl);

  bool get stillFresh => DateTime.now().difference(ts).inSeconds < ttl;
}

class _Reg {
  final String name; // logical key
  final String diskKey; // SharedPreferences key
  final int ttl; // RAM TTL seconds
  final InstantLoader loader;
  final List<String>
  thumbs; // optional static thumbs (not used here but kept for compat)
  _Reg({
    required this.name,
    required this.diskKey,
    required this.ttl,
    required this.loader,
    this.thumbs = const [],
  });
}

class Instant {
  // ------- registry -------
  static final Map<String, _Reg> _regs = {}; // name -> registration

  // ------- RAM cache -------
  static final Map<String, _Entry> _mem = {}; // name -> entry

  /// Register a loader for a logical name.
  static void register({
    required String name,
    required String diskKey,
    required int ttlSeconds,
    required InstantLoader loader,
    List<String> thumbs = const [],
  }) {
    _regs[name] = _Reg(
      name: name,
      diskKey: diskKey,
      ttl: ttlSeconds,
      loader: loader,
      thumbs: thumbs,
    );
  }

  /// Preload now → run loader → save RAM + Disk → precache thumbnails.
  static Future<void> preload(String name, {BuildContext? ctx}) async {
    final reg = _regs[name];
    if (reg == null) return;
    try {
      final data = await reg.loader(ctx); // fetch map
      _mem[name] = _Entry(data, DateTime.now(), reg.ttl);

      final sp = await SharedPreferences.getInstance();
      await sp.setString(reg.diskKey, jsonEncode(data));

      // Precache thumbs:
      // 1) Prefer thumbs returned by data['thumbs']
      // 2) Fall back to reg.thumbs (static)
      final dynamicFromData = data['thumbs'];
      final List<String> thumbsFromData = (dynamicFromData is List)
          ? dynamicFromData.whereType<String>().toList()
          : const <String>[];

      final toCache = thumbsFromData.isNotEmpty ? thumbsFromData : reg.thumbs;

      if (ctx != null && toCache.isNotEmpty) {
        for (final url in toCache) {
          if (url.isEmpty) continue;
          try {
            await precacheImage(NetworkImage(url), ctx);
          } catch (_) {
            // ignore broken images
          }
        }
      }
    } catch (_) {
      // ignore errors (SWR will kick in later)
    }
  }

  /// Read RAM only (null if not present or stale).
  static Map<String, dynamic>? getFresh(String name) {
    final e = _mem[name];
    if (e == null) return null;
    if (!e.stillFresh) return null;
    return e.data;
  }

  /// Read Disk snapshot (stale OK). Good for cold-start fallback while waiting for refresh.
  static Future<Map<String, dynamic>?> readStale(String name) async {
    final reg = _regs[name];
    if (reg == null) return null;
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(reg.diskKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      // Also promote to RAM (as stale) so multiple reads don’t hit disk.
      _mem[name] = _Entry(map, DateTime.fromMillisecondsSinceEpoch(0), 0);
      return map;
    } catch (_) {
      return null;
    }
  }

  /// Force refresh (run loader again) and update RAM+Disk.
  static Future<void> refresh(String name, {BuildContext? ctx}) async {
    await preload(name, ctx: ctx);
  }

  /// Clear all RAM entries (e.g., on logout).
  static void clear() => _mem.clear();

  // ----------------- Convenience helpers used by widgets -----------------

  /// Structured read with type hint and optional "path" inside the cached map.
  /// Example:
  ///   final types = Instant.read<List>('user.home', path: 'types') ?? const [];
  static T? read<T>(String name, {String? path}) {
    final src = getFresh(name);
    if (src == null) return null;
    final value = (path == null || path.isEmpty) ? src : src[path];
    return (value is T) ? value : null;
  }

  /// Write/merge a partial map back to the cache (RAM + Disk), keeping same TTL window.
  /// Useful when a BLoC produced fresher bits (e.g., replacing 'types').
  static Future<void> write(
    String name,
    Map<String, dynamic> patch, {
    bool merge = true,
  }) async {
    final reg = _regs[name];
    if (reg == null) return;

    // Start from RAM if available, else from Disk, else empty.
    Map<String, dynamic> base;
    final e = _mem[name];
    if (e != null) {
      base = Map<String, dynamic>.from(e.data);
    } else {
      base = (await readStale(name)) ?? <String, dynamic>{};
    }

    final next = merge ? {...base, ...patch} : patch;

    // Update RAM (preserve timestamp / ttl if exists)
    final ts = e?.ts ?? DateTime.now();
    final ttl = e?.ttl ?? reg.ttl;
    _mem[name] = _Entry(next, ts, ttl);

    // Update Disk
    final sp = await SharedPreferences.getInstance();
    await sp.setString(reg.diskKey, jsonEncode(next));
  }
}
