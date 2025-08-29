// ===== Flutter 3.35.x =====
// main.dart — load config → build ApiClient(cfg) → restore token → expose globals → run app.

import 'package:flutter/material.dart'; // UI base
import 'package:shared_preferences/shared_preferences.dart'; // simple key/value

import 'package:hobby_sphere/core/network/api_config.dart'; // NON-static loader (returns ApiConfig)
import 'package:hobby_sphere/core/network/api_client.dart'; // ApiClient(ApiConfig cfg)
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // appDio + appServerRoot
import 'app/app.dart'; // your root widget

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // allow async before runApp

  // 1) Load server settings from assets/hostIp.json (returns an ApiConfig instance)
  final cfg = await ApiConfig.load(); // ex: baseUrl=http://192.168.1.5:8080/api

  // 2) Build ONE ApiClient using that config (constructor NEEDS cfg)
  final apiClient = ApiClient(cfg); // ✅ FIX: pass cfg (no empty constructor)

  // 3) Restore JWT if saved, then attach Authorization header
  final sp = await SharedPreferences.getInstance(); // open local storage
  final savedToken = sp.getString('token'); // read token (if any)
  if (savedToken != null && savedToken.isNotEmpty) {
    // token exists?
    apiClient.setToken(savedToken); // add "Bearer <token>" to all requests
  }

  // 4) Share the configured Dio + serverRoot globally (so old code like ApiFetch() works zero-arg)
  g.appDio = apiClient.dio; // now ApiFetch() can use g.appDio
  g.appServerRoot = cfg.serverRoot; // your _fullUrl(...) can prefix images

  // 5) Start the app (you can keep App() with no parameters)
  runApp(const App()); // no change needed to app.dart
}
