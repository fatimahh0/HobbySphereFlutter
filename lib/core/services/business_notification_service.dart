// ===== Flutter 3.35.x =====
// services/business_notification_service.dart
// Business notifications: list, mark-as-read, delete, unread/count.
//
// Uses our ApiFetch (Dio-based) so it feels like Axios.
// Every line has a short comment.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch()
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / PUT / DELETE

class BusinessNotificationService {
  // create one helper that reuses the global Dio client
  final _fetch = ApiFetch(); // shared instance

  // base path for notifications (global baseUrl already contains "/api")
  static const _base = '/notifications'; // -> <server>/api/notifications

  // ------------------------------------------------------------
  // GET /api/notifications/business
  // returns the list of notifications for the business user
  Future<List<dynamic>> getBusinessNotifications(String token) async {
    if (token.isEmpty)
      throw Exception('Missing business token'); // guard if no token

    // send GET with Authorization header
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business', // endpoint path
      headers: {'Authorization': 'Bearer $token'}, // bearer token
    );

    final data = res.data; // read payload
    if (data is! List)
      throw Exception('Invalid notifications list'); // validate list
    return data; // return array
  }

  // ------------------------------------------------------------
  // PUT /api/notifications/business/{id}/read
  // marks a single business notification as read
  Future<Map<String, dynamic>> markBusinessNotificationAsRead({
    required String token, // JWT token
    required int id, // notification id
  }) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // send PUT with empty body
    final res = await _fetch.fetch(
      HttpMethod.put, // HTTP method
      '$_base/business/$id/read', // endpoint path
      data: {}, // empty JSON body
      headers: {'Authorization': 'Bearer $token'}, // bearer token
    );

    final data = res.data; // read payload
    if (data is! Map)
      throw Exception('Invalid mark-read response'); // validate object
    return Map<String, dynamic>.from(data); // return map
  }

  // ------------------------------------------------------------
  // DELETE /api/notifications/business/{id}
  // deletes a single business notification
  Future<Map<String, dynamic>> deleteBusinessNotification({
    required String token, // JWT token
    required int id, // notification id
  }) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // send DELETE (no body)
    final res = await _fetch.fetch(
      HttpMethod.delete, // HTTP method
      '$_base/business/$id', // endpoint path
      headers: {'Authorization': 'Bearer $token'}, // bearer token
    );

    final data = res.data; // read payload
    if (data is! Map)
      throw Exception('Invalid delete response'); // validate object
    return Map<String, dynamic>.from(data); // return map
  }

  // ------------------------------------------------------------
  // GET /api/notifications/business/unread-count
  // returns the number of unread business notifications
  Future<int> getBusinessUnreadNotificationCount(String token) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // send GET
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business/unread-count', // endpoint path
      headers: {'Authorization': 'Bearer $token'}, // bearer token
    );

    final data = res.data; // read payload
    // backend might return: { count: 3 } OR just 3
    if (data is int) return data; // direct number
    if (data is Map && data['count'] is int)
      return data['count'] as int; // object form
    throw Exception('Invalid unread-count response'); // invalid format
  }

  // ------------------------------------------------------------
  // GET /api/notifications/business/count
  // returns the total number of business notifications
  Future<int> getBusinessNotificationCount(String token) async {
    if (token.isEmpty) throw Exception('Missing business token'); // guard

    // send GET
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method
      '$_base/business/count', // endpoint path
      headers: {'Authorization': 'Bearer $token'}, // bearer token
    );

    final data = res.data; // read payload
    // backend might return: { count: 12 } OR just 12
    if (data is int) return data; // direct number
    if (data is Map && data['count'] is int)
      return data['count'] as int; // object form
    throw Exception('Invalid count response'); // invalid format
  }
}
