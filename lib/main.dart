// main.dart — load ApiConfig → build ApiClient → restore token → expose globals → run app

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/api_client.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Load config (e.g., baseUrl/serverRoot from assets)
  final cfg = await ApiConfig.load();

  // 2) Build client with that config
  final apiClient = ApiClient(cfg);

  // 3) Attach saved token, if any
  final sp = await SharedPreferences.getInstance();
  final savedToken = sp.getString('token');
  if (savedToken != null && savedToken.isNotEmpty) {
    apiClient.setToken(savedToken);
  }

  // 4) Expose globals so ApiFetch() can reuse the configured Dio
  g.appDio = apiClient.dio;
  g.appServerRoot = cfg.serverRoot;

  // 5) Run
  runApp(const App());
}
