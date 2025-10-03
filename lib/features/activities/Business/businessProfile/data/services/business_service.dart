// Flutter 3.35.x
// BusinessService — HTTP methods to backend.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // fetch wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HTTP verbs

class BusinessService {
  final _fetch = ApiFetch(); // http client instance
  static const _base = '/businesses'; // base path under /api

  // Ensure "Bearer " prefix for token
  String _auth(String token) =>
      token.startsWith('Bearer ') ? token : 'Bearer $token';

  /// GET /api/businesses/{id}
  Future<Map<String, dynamic>> getBusinessById(String token, int id) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/$id', // path
      headers: {'Authorization': _auth(token)}, // auth
    );
    return (res.data as Map).cast<String, dynamic>(); // cast map
  }

  /// PUT /api/businesses/{id}/visibility
  Future<void> updateVisibility(String token, int id, bool isPublic) async {
    await _fetch.fetch(
      HttpMethod.put, // PUT
      '$_base/$id/visibility', // path
      headers: {'Authorization': _auth(token)}, // auth
      data: {'isPublicProfile': isPublic}, // body
    );
  }

  /// PUT /api/businesses/{id}/status
  /// When status == INACTIVE, backend requires { password }.
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) async {
    final body = <String, dynamic>{'status': status}; // base body
    if (password != null) body['password'] = password; // optional pw

    await _fetch.fetch(
      HttpMethod.put, // PUT
      '$_base/$id/status', // path
      headers: {'Authorization': _auth(token)}, // auth
      data: body, // body
    );
  }

  /// DELETE /api/businesses/{id}
  Future<void> deleteBusiness(String token, int id, String password) async {
    await _fetch.fetch(
      HttpMethod.delete, // DELETE
      '$_base/$id', // path
      headers: {'Authorization': _auth(token)}, // auth
      data: {'password': password}, // body
    );
  }

  /// GET /api/businesses/{id}/stripe-status
  /// Expects { "stripeConnected": true/false }
  Future<bool> checkStripeStatus(String token, int id) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_base/$id/stripe-status', // path
      headers: {'Authorization': _auth(token)}, // auth
    );
    final data = res.data; // response
    if (data is Map && data['stripeConnected'] is bool) {
      return data['stripeConnected'] as bool; // return bool
    }
    return false; // default
  }

  /// POST /api/businesses/stripe/connect
  /// Body: { "businessId": <id> }
  /// Response: { "url": "https://connect.stripe.com/...", "accountId": "..." }
  Future<String> createStripeConnectLink(String token, int businessId) async {
    final res = await _fetch.fetch(
      HttpMethod.post, // POST
      '$_base/stripe/connect', // path
      headers: {'Authorization': _auth(token)}, // auth
      data: {'businessId': businessId}, // send id
    );
    final map = (res.data as Map).cast<String, dynamic>(); // cast
    final url = (map['url'] ?? '').toString(); // read url
    if (url.isEmpty) {
      throw Exception('Stripe onboarding link is empty.'); // guard
    }
    return url; // return link
  }
}
