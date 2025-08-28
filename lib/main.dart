// ===== Flutter 3.35.x =====
// App entry: load ApiConfig -> set Dio baseUrl -> restore token -> run app.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // token storage (simple)
import 'package:hobby_sphere/core/network/api_config.dart'; // loads hostIp.json
import 'package:hobby_sphere/core/network/api_client.dart'; // global Dio client

import 'app.dart'; // your root App widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // allow async before runApp

  try {
    // 1) Load assets/hostIp.json (safe fallback inside)
    await ApiConfig.load();

    // 2) Apply the baseUrl to Dio AFTER load()
    ApiClient().refreshBaseUrl();
  } catch (e) {
    // If config fails, ApiConfig has a fallback; we just log here
    debugPrint('ApiConfig load error: $e');
  }

  // 3) Restore saved JWT and set Authorization header if present
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token');
  if (savedToken != null && savedToken.isNotEmpty) {
    ApiClient().setToken(savedToken);
  }

  runApp(const App());
}
