// ===== Flutter 3.35.x =====
// lib/core/business/business_context.dart
//
// Small helper to keep a valid businessId everywhere.
// - store in memory
// - persist in SharedPreferences
// - fallback to server profile if missing

import 'package:shared_preferences/shared_preferences.dart'; // read/write local
import 'package:hobby_sphere/core/network/api_fetch.dart'; // HTTP wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class BusinessContext {
  static int? _inMemoryId; // cache id in memory (fast)

  static Future<void> set(int id) async {
    _inMemoryId = id; // save in memory
    if (id > 0) {
      // only persist valid ids
      final sp = await SharedPreferences.getInstance(); // open prefs
      await sp.setInt('businessId', id); // persist for next app start
    }
  }

  static Future<void> clear() async {
    _inMemoryId = null; // clear memory
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.remove('businessId'); // clear prefs
  }

  static Future<int> ensureId() async {
    // 1) memory
    if (_inMemoryId != null && _inMemoryId! > 0) return _inMemoryId!; // ok

    // 2) prefs
    final sp = await SharedPreferences.getInstance(); // open prefs
    final cached = sp.getInt('businessId'); // read saved id
    if (cached != null && cached > 0) {
      _inMemoryId = cached; // warm memory
      return cached; // ok
    }

    // 3) server (self profile → needs Authorization header already set)
    try {
      final res = await ApiFetch().fetch(
        HttpMethod.get, // GET
        '/business/profile', // adjust if your backend differs
      );
      final data = res.data; // dynamic json
      int id = 0; // default
      if (data is Map && data['id'] != null) {
        final v = data['id']; // read id
        if (v is int) id = v; // int case
        if (v is String) id = int.tryParse(v) ?? 0; // string case
      }
      if (id > 0) {
        // valid id
        await set(id); // save everywhere
        return id; // return
      }
    } catch (_) {
      // ignore and fall through
    }

    return 0; // unknown → caller should guard
  }
}
