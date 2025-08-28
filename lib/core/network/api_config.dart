// Safe API config loader with fallback (no `late` crashes).

import 'dart:convert';
import 'package:flutter/services.dart';

class ApiConfig {
  // Nullable; we expose a safe getter with fallback instead of `late`
  static String? _baseUrl;

  /// Safe base URL getter (fallback is Android emulator localhost)
  static String get baseUrl => _baseUrl ?? 'http://3.96.140.126:8080/api';

  /// Server root (without trailing /api) - helpful for media URLs
  static String get serverRoot => baseUrl.endsWith('/api')
      ? baseUrl.substring(0, baseUrl.length - 4)
      : baseUrl;

  /// Loads assets/hostIp.json and sets _baseUrl = "<serverURI>/api"
  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/hostIp.json');
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final host = (map['serverURI'] as String).trim();
      final clean = host.replaceAll(RegExp(r'/$'), ''); // strip trailing slash
      _baseUrl = '$clean/api';
    } catch (_) {
      // If file missing/invalid, keep fallback so app never crashes
      _baseUrl ??= 'http://3.96.140.126:8080/api';
    }
  }
}
