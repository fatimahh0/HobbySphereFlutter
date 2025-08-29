// ===== Flutter 3.35.x =====
// lib/core/network/api_config.dart
// Non-static config loader. Creates an instance you inject.

import 'dart:convert';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/services.dart'; // rootBundle
import 'dart:io' show Platform;

class ApiConfig {
  final String baseUrl; // ex: http://192.168.1.5:8080/api
  final String serverRoot;

  ApiConfig._(this.baseUrl, this.serverRoot);

  // factory method: load from assets (hostIp.json)
  static Future<ApiConfig> load() async {
    try {
      final raw = await rootBundle.loadString('lib/config/hostIp.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rawHost = (map['serverURI'] ?? map['serverUrl'] ?? '')
          .toString()
          .trim();

      if (rawHost.isEmpty) {
        throw Exception("serverURI missing in hostIp.json");
      }

      final root = _normalizeServerRoot(rawHost);
      final base = '$root/api';
      return ApiConfig._(base, root);
    } catch (e) {
      throw Exception('Failed to load ApiConfig: $e');
    }
  }

  // normalize helpers
  static String _normalizeServerRoot(String input) {
    var s = input.trim();

    if (s.endsWith('/api')) s = s.substring(0, s.length - 4);
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }

    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          s = s
              .replaceFirst('http://localhost', 'http://10.0.2.2')
              .replaceFirst('https://localhost', 'http://10.0.2.2');
        }
      } catch (_) {}
    }
    return s;
  }
}
