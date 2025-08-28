// ===== Flutter 3.35.x =====
// Currency API: get current currency.
// Uses ApiFetch (Dio wrapper). Clean and simple.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like fetch()
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class CurrencyService {
  // Reuse global ApiFetch (shared Dio)
  final _fetch = ApiFetch(); // HTTP client
  static const _base = '/currencies'; // -> <server>/api/currencies

  // GET /api/currencies/current
  Future<Map<String, dynamic>> getCurrentCurrency(String token) async {
    // Call GET with bearer token
    final res = await _fetch.fetch(
      HttpMethod.get, // method
      '$_base/current', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // Validate and return map
    final data = res.data; // payload
    if (data is! Map) throw Exception('Invalid currency response'); // guard
    return Map<String, dynamic>.from(data); // e.g. { "currencyType": "CAD" }
  }

  // Convenience: return just the code (e.g., "CAD") regardless of backend shape
  Future<String> getCurrentCurrencyCode(String token) async {
    // Fetch map once
    final map = await getCurrentCurrency(token); // map payload
    // Try common keys (currencyType / code / value)
    return (map['currencyType'] ?? map['code'] ?? map['value'] ?? 'CAD')
        .toString(); // normalize
  }
}
