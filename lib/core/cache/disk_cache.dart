// Flutter 3.35.x
// Minimal disk cache using SharedPreferences for small JSON payloads.
// Goal: show something instantly on next launch (even before network).

import 'dart:convert'; // jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // local storage

class DiskCache {
  // Save any JSON-serializable object (Map/List) under a key.
  static Future<void> saveJson(String key, Object value) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    final jsonStr = jsonEncode(value); // to string
    await sp.setString('dc_$key', jsonStr); // write with prefix
  }

  // Read a Map<String,dynamic> JSON from disk.
  static Future<Map<String, dynamic>?> readJson(String key) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    final raw = sp.getString('dc_$key'); // read string
    if (raw == null) return null; // nothing stored
    try {
      return jsonDecode(raw) as Map<String, dynamic>; // parse map
    } catch (_) {
      return null; // invalid json
    }
  }

  // Read a List<dynamic> JSON from disk.
  static Future<List<dynamic>?> readJsonList(String key) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    final raw = sp.getString('dc_$key'); // read string
    if (raw == null) return null; // nothing stored
    try {
      return jsonDecode(raw) as List<dynamic>; // parse list
    } catch (_) {
      return null; // invalid json
    }
  }

  // Remove a single key (optional on logout).
  static Future<void> clearKey(String key) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.remove('dc_$key'); // delete entry
  }
}
