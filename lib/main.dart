// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // Flutter core
import 'package:shared_preferences/shared_preferences.dart'; // ✅ token storage
import 'package:hobby_sphere/core/network/api_config.dart'; // loads hostIp.json
import 'package:hobby_sphere/core/network/api_client.dart'; // global Dio client

import 'app.dart'; // your root App widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // allow async before runApp

  try {
    // 1) Load hostIp.json
    await ApiConfig.load();
    // 2) Apply baseUrl to Dio
    ApiClient().refreshBaseUrl();
  } catch (e) {
    // fallback to 10.0.2.2:8080/api
    debugPrint('ApiConfig load error: $e');
  }

  // ✅ Restore saved JWT
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token'); // read token
  if (savedToken != null && savedToken.isNotEmpty) {
    ApiClient().setToken(savedToken); // set Authorization header
  }

  // 3) Run your app
  runApp(const App());
}
