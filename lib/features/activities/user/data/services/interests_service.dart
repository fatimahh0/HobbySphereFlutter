// ===== Flutter 3.35.x =====
// services/interests_service.dart
// Get all interests, and save selected user interests.
//
// Uses our ApiFetch (Dio wrapper). Simple comments on each line.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // HTTP helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST

class InterestsService {
  // one helper instance reusing the global Dio client
  final _fetch = ApiFetch(); // shared HTTP helper

  // base path for activity types (final URL = <server>/api/activity-types)
  static const _base = '/activity-types'; // activity types base

  // ------------------------------------------------------------
  // GET /api/activity-types/all
  // same as: getAllInterests()
  Future<List<dynamic>> getAllInterests() async {
    // send GET to /activity-types/all
    final res = await _fetch.fetch(
      HttpMethod.get, // HTTP method: GET
      '$_base/all', // endpoint path
    );

    // read JSON payload
    final data = res.data; // dynamic from Dio

    // validate it is an array
    if (data is! List) {
      throw Exception('Invalid interests response'); // guard
    }

    // return list of interests
    return data; // List<dynamic>
  }

  // ------------------------------------------------------------
  // POST /api/users/{userId}/interests
  // same as: saveUserInterests(userId, interestIds)
  Future<Map<String, dynamic>> saveUserInterests({
    required int userId, // target user id
    required List<int> interestIds, // array like [1,2,3]
  }) async {
    // call POST with the array as the body (backend expects raw list)
    final res = await _fetch.fetch(
      HttpMethod.post, // HTTP method: POST
      '/users/$userId/interests', // endpoint path
      data: interestIds, // body is the list itself
    );

    // read JSON payload
    final data = res.data; // dynamic from Dio

    // accept either object or array responses; here we expect an object
    if (data is! Map) {
      throw Exception('Invalid save interests response'); // guard
    }

    // return as typed map (e.g., { success: true, ... })
    return Map<String, dynamic>.from(data); // Map<String, dynamic>
  }
}
