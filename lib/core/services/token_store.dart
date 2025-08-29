// lib/core/auth/token_store.dart
// Simple token storage using SharedPreferences (persists across app restarts)

import 'package:shared_preferences/shared_preferences.dart'; // local storage

class TokenStore {
  // save token + role
  static Future<void> save({
    required String token, // the JWT string
    required String role, // "user" or "business"
  }) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.setString('token', token); // write token
    await sp.setString('role', role); // write role
  }

  // read token + role
  static Future<({String? token, String? role})> read() async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    final token = sp.getString('token'); // read token
    final role = sp.getString('role'); // read role
    return (token: token, role: role); // return both
  }

  // clear token + role
  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.remove('token'); // remove token
    await sp.remove('role'); // remove role
  }
}
