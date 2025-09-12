// Flutter 3.35.x — main.dart (only the realtime additions shown)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/core/network/api_config.dart';
import 'package:hobby_sphere/core/network/api_client.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/core/realtime/ws_url.dart';
import 'package:hobby_sphere/core/realtime/realtime_service.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cfg = await ApiConfig.load();
  final apiClient = ApiClient(cfg);

  final sp = await SharedPreferences.getInstance();
  final savedToken = sp.getString('token');

  if (savedToken != null && savedToken.isNotEmpty) {
    apiClient.setToken(savedToken);
    g.Token = savedToken;
  }

  g.appDio = apiClient.dio;
  g.appServerRoot = cfg.serverRoot; // e.g. http://3.96.140.126:8080/api

  // Build **HTTP base WITHOUT /api** for websockets
  final httpBase = g.serverRootNoApi(); // e.g. http://3.96.140.126:8080

  // Connect realtime (only when we have a token)
  if ((savedToken ?? '').isNotEmpty) {
    g.realtime ??= RealtimeService();
    // Try a few common endpoints; the service will rotate paths automatically.
    g.realtime!.connect(
      httpBase: httpBase,
      token: savedToken!,
      candidatePaths: const ['/ws', '/ws/events', '/realtime', '/socket'],
    );
  }

  runApp(const App());
}
