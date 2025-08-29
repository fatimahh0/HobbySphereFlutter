// ===== Flutter 3.35.x =====
// services/review_service.dart
// Reviews API: by activity, add, all, by business, completion checks, modal flag, suggested activity.

import 'package:hobby_sphere/core/network/api_fetch.dart';   // HTTP helper (Dio)
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST

class ReviewService {
  // one reusable fetch helper (shares the global Dio client)
  final _fetch = ApiFetch();                                  // helper

  // base path for all review endpoints (final => <server>/api/reviews/...)
  static const _base = '/reviews';                             // base

  // ------------------------------------------------------------
  // GET /api/reviews/activity/{activityId}
  Future<List<dynamic>> getReviewsByActivityId({
    required int activityId,                                   // activity id
    required String token,                                     // JWT
  }) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    // call endpoint with Authorization header
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      '$_base/activity/$activityId',                           // path
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! List) throw Exception('Invalid reviews list'); // must be list
    return data;                                               // return list
  }

  // ------------------------------------------------------------
  // POST /api/reviews/addreviews
  Future<Map<String, dynamic>> addReview({
    required Map<String, dynamic> reviewData,                  // body payload
    required String token,                                     // JWT
  }) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    // send POST with JSON body
    final res = await _fetch.fetch(
      HttpMethod.post,                                         // POST
      '$_base/addreviews',                                     // path
      data: reviewData,                                        // JSON body
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! Map) throw Exception('Invalid add review response'); // must be object
    return Map<String, dynamic>.from(data);                    // return map
  }

  // ------------------------------------------------------------
  // GET /api/reviews
  Future<List<dynamic>> getAllReviews(String token) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      _base,                                                   // "/reviews"
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! List) throw Exception('Invalid reviews list'); // must be list
    return data;                                               // list
  }

  // ------------------------------------------------------------
  // GET /api/reviews/business/{businessId}
  Future<List<dynamic>> getReviewsByBusiness({
    required int businessId,                                   // business id
    required String token,                                     // JWT
  }) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      '$_base/business/$businessId',                           // path
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! List) throw Exception('Invalid reviews list'); // must be list
    return data;                                               // list
  }

  // ------------------------------------------------------------
  // GET /api/reviews/check-completed/{activityId}
  Future<Map<String, dynamic>> hasUserCompletedActivity({
    required int activityId,                                   // activity id
    required String token,                                     // JWT
  }) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      '$_base/check-completed/$activityId',                    // path
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! Map) throw Exception('Invalid check-completed response'); // must be object
    return Map<String, dynamic>.from(data);                    // return map
  }

  // ------------------------------------------------------------
  // GET /api/reviews/should-show-modal/{activityId}
  Future<Map<String, dynamic>> shouldShowReviewModal({
    required int activityId,                                   // activity id
    required String token,                                     // JWT
  }) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      '$_base/should-show-modal/$activityId',                  // path
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! Map) throw Exception('Invalid modal response'); // must be object
    return Map<String, dynamic>.from(data);                    // return map
  }

  // ------------------------------------------------------------
  // GET /api/reviews/suggest
  Future<Map<String, dynamic>> getSuggestedReviewActivity(String token) async {
    if (token.isEmpty) throw Exception('Token is required');   // guard
    final res = await _fetch.fetch(
      HttpMethod.get,                                          // GET
      '$_base/suggest',                                        // path
      headers: {'Authorization': 'Bearer $token'},             // auth
    );
    final data = res.data;                                     // payload
    if (data is! Map) throw Exception('Invalid suggested activity response'); // must be object
    return Map<String, dynamic>.from(data);                    // return map
  }
}
