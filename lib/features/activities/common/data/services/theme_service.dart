// ===== Flutter 3.35.x =====
// services/theme_service.dart
// Mobile Theme API: fetch active theme for mobile app.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // Dio wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET

class ThemeService {
  final _fetch = ApiFetch(); // shared Dio client
  static const _base = '/themes'; // base path (/api already in baseUrl)

  // ------------------------------------------------------------
  // GET /api/themes/active/mobile
  Future<Map<String, dynamic>> getActiveMobileTheme() async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/active/mobile', // endpoint
      headers: {'Content-Type': 'application/json'}, // explicit JSON header
    );

    final data = res.data; // payload
    if (data is! Map) {
      throw Exception('Invalid theme response'); // must be JSON object
    }

    return Map<String, dynamic>.from(data); // return as Map
  }
}
