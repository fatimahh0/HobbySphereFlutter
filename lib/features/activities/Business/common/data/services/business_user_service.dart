// ===== Flutter 3.35.x =====
// services/business_user_service.dart
// Manage business users: create and list my users.
//
// Uses our ApiFetch (Dio-based) so it feels like Axios.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // POST / GET

class BusinessUserService {
  final _fetch = ApiFetch(); // reuse the global Dio client
  static const _base =
      '/business-users'; // base path (our baseUrl already has /api)

  // ------------------------------------------------------------
  // POST /api/business-users/create
  // Create a new business user (requires auth token)
  Future<Map<String, dynamic>> createBusinessUser({
    required String token, // JWT token
    required Map<String, dynamic> data, // request body { name, email, ... }
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/create', // endpoint
      data: data, // JSON body
      headers: {'Authorization': 'Bearer $token'},
    );

    final response = res.data;
    if (response is! Map) throw Exception('Invalid create user response');
    return Map<String, dynamic>.from(response);
  }

  // ------------------------------------------------------------
  // GET /api/business-users/my-users
  // Get all business users of the logged-in business
  Future<List<dynamic>> getMyBusinessUsers(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/my-users', // endpoint
      headers: {'Authorization': 'Bearer $token'},
    );

    final response = res.data;
    if (response is! List) throw Exception('Invalid users list response');
    return response;
  }
}
