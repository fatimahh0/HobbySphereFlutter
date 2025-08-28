// ===== Flutter 3.35.x =====
// Business notifications service: list, mark-as-read, delete, counts.
// Uses your ApiFetch (Dio-based) so it feels like Axios.
// Every line has a short comment.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch()
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum (GET/PUT/DELETE)

class BusinessNotificationService {
  // Reuse one ApiFetch (it holds the shared Dio).
  final ApiFetch _fetch = ApiFetch(); // create shared fetch instance

  // Base path for this feature (global baseUrl already contains "/api").
  static const String _base = '/notifications'; // -> <server>/api/notifications

  // --- small parsing helpers -------------------------------------------------

  // Ensure we always return a Map<String, dynamic> or throw.
  Map<String, dynamic> _asMap(dynamic v) {
    // if already Map -> cast to Map<String, dynamic>
    if (v is Map) return Map<String, dynamic>.from(v);
    // any other type is invalid for "object" responses
    throw Exception('Invalid response shape: expected object');
  }

  // Ensure we always return a List<dynamic> or throw.
  List<dynamic> _asList(dynamic v) {
    // if already List -> return it
    if (v is List) return v;
    // any other type is invalid for "array" responses
    throw Exception('Invalid response shape: expected array');
  }

  // Normalize a count that can be: raw number, or { "count": number }.
  int _asCount(dynamic v) {
    // if a number -> to int
    if (v is num) return v.toInt();
    // if an object and has "count" number -> to int
    if (v is Map && v['count'] is num) return (v['count'] as num).toInt();
    // otherwise invalid
    throw Exception('Invalid response shape: expected count');
  }

  // --- endpoints -------------------------------------------------------------

  // GET /api/notifications/business
  // Get list of business notifications.
  Future<List<dynamic>> getBusinessNotifications(String token) async {
    // token must be present (JWT)
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // call GET with bearer token
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // validate and return array
    return _asList(res.data); // throws if not a list
  }

  // PUT /api/notifications/business/{id}/read
  // Mark one business notification as read.
  Future<Map<String, dynamic>> markBusinessNotificationAsRead({
    required String token, // JWT token
    required int id, // notification id
  }) async {
    // token guard
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // call PUT with empty JSON body
    final res = await _fetch.fetch(
      HttpMethod.put, // HTTP method
      '$_base/business/$id/read', // endpoint
      data: const <String, dynamic>{}, // empty body
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // validate and return object
    return _asMap(res.data); // throws if not a map
  }

  // DELETE /api/notifications/business/{id}
  // Delete one business notification.
  Future<Map<String, dynamic>> deleteBusinessNotification({
    required String token, // JWT token
    required int id, // notification id
  }) async {
    // token guard
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // call DELETE
    final res = await _fetch.fetch(
      HttpMethod.delete, // HTTP method
      '$_base/business/$id', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // validate and return object (backend usually returns { success: true } or similar)
    return _asMap(res.data); // throws if not a map
  }

  // GET /api/notifications/business/unread-count
  // Get number of unread notifications.
  Future<int> getBusinessUnreadNotificationCount(String token) async {
    // token guard
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // call GET
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business/unread-count', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // normalize and return count
    return _asCount(res.data); // supports "3" or { count: 3 }
  }

  // GET /api/notifications/business/count
  // Get total number of notifications.
  Future<int> getBusinessNotificationCount(String token) async {
    // token guard
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // call GET
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business/count', // endpoint
      headers: {'Authorization': 'Bearer $token'}, // auth header
    );

    // normalize and return count
    return _asCount(res.data); // supports "12" or { count: 12 }
  }
}
