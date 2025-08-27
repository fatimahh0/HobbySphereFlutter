// ===== Flutter 3.35.x =====
// services/currency_service.dart
// Currency API: get current currency of the system/user.
//
// Uses ApiFetch (Dio wrapper). Clean and simple.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET

class CurrencyService {
  final _fetch = ApiFetch(); // shared HTTP client
  static const _base =
      '/currencies'; // base path (Dio baseUrl already ends with /api)

  // ------------------------------------------------------------
  // GET /api/currencies/current
  Future<Map<String, dynamic>> getCurrentCurrency(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/current', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    final data = res.data; // JSON payload
    if (data is! Map) throw Exception('Invalid currency response'); // guard
    return Map<String, dynamic>.from(data); // return map
  }
}
