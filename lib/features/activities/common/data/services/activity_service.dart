// ===== Flutter 3.35.x =====
// services/activity_service.dart
// This file converts your RN code to Flutter using our ApiFetch helper.
// We keep the same endpoints, validation, and simple behavior.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HTTP method names

// base path for items (our global baseUrl already contains "/api")
const String _BASE = '/items'; // final URL = <server>/api/items

// create one fetch helper to reuse the same Dio client
final ApiFetch _fetch = ApiFetch(); // shared fetch instance

// -----------------------------------------------
// GET /api/items/upcoming
// same as: getAllActivities() in your RN service
Future<List<dynamic>> getAllActivities() async {
  // send GET to /items/upcoming
  final res = await _fetch.fetch(
    HttpMethod.get, // HTTP method: GET
    '$_BASE/upcoming', // endpoint path
  );

  // read the JSON payload from the response
  final data = res.data; // can be any type

  // validate it's a JSON array
  if (data is! List) {
    throw Exception('Invalid response format'); // same error message
  }

  // return the list as-is (dynamic list like RN)
  return data; // List<dynamic>
}

// -----------------------------------------------
// GET /api/items/interest-based/{userId}
// same as: getInterestBasedActivities(userId, token)
Future<List<dynamic>> getInterestBasedActivities({
  required int userId, // the user id path param
  String? token, // optional token; pass null if set globally
}) async {
  // build per-call headers only if a token is provided
  final headers = <String, String>{
    if (token != null) 'Authorization': 'Bearer $token', // bearer token
  };

  // call the endpoint
  final res = await _fetch.fetch(
    HttpMethod.get, // GET
    '$_BASE/interest-based/$userId', // path with user id
    headers: headers, // attach headers when present
  );

  // read payload
  final data = res.data; // any type

  // validate array result
  if (data is! List) {
    throw Exception('Invalid response format'); // same message as RN
  }

  // return list
  return data; // List<dynamic>
}

// -----------------------------------------------
// GET /api/items/guest/upcoming[?typeId=]
// same as: getGuestUpcomingActivities(typeId)
Future<List<dynamic>> getGuestUpcomingActivities({int? typeId}) async {
  // when using GET, we put query params inside "data" map
  final query = <String, dynamic>{
    if (typeId != null) 'typeId': typeId, // only add if provided
  };

  // call endpoint with optional query
  final res = await _fetch.fetch(
    HttpMethod.get, // GET
    '$_BASE/guest/upcoming', // path
    data: query, // becomes ?typeId=...
  );

  // read payload
  final data = res.data; // any type

  // validate array
  if (data is! List) {
    throw Exception('Invalid response format'); // same message
  }

  // return list
  return data; // List<dynamic>
}

// -----------------------------------------------
// GET /api/items/by-type/{typeId}
// same as: getActivitiesByType(typeId)
Future<List<dynamic>> getActivitiesByType(int typeId) async {
  // call endpoint
  final res = await _fetch.fetch(
    HttpMethod.get, // GET
    '$_BASE/by-type/$typeId', // path with type id
  );

  // read payload
  final data = res.data; // any type

  // validate array
  if (data is! List) {
    throw Exception('Invalid response format'); // same message
  }

  // return list
  return data; // List<dynamic>
}

// -----------------------------------------------
// GET /api/items/{activityId}/check-availability?participants=X
// same as: checkAvailability(activityId, participants, token)
Future<Map<String, dynamic>> checkAvailability({
  required int activityId, // item/activity id
  required int participants, // participants count
  String? token, // optional token if not set globally
}) async {
  // your RN code throws if token missing; we keep that behavior
  if (token == null || token.isEmpty) {
    throw Exception('User token required'); // same message
  }

  // per-call headers with Authorization
  final headers = <String, String>{
    'Authorization': 'Bearer $token', // bearer token
  };

  // query parameters (?participants=...)
  final query = <String, dynamic>{'participants': participants};

  // call endpoint
  final res = await _fetch.fetch(
    HttpMethod.get, // GET
    '$_BASE/$activityId/check-availability', // path
    data: query, // query params
    headers: headers, // auth header
  );

  // read payload
  final data = res.data; // any type

  // validate shape: must be a JSON object with boolean `available`
  if (data is! Map || data['available'] is! bool) {
    throw Exception('Invalid availability response'); // same message
  }

  // return as Map<String, dynamic>
  return Map<String, dynamic>.from(data); // {available: true/false, ...}
}

// -----------------------------------------------
// GET /api/items/{id}
// same as: getActivityById(id)
Future<Map<String, dynamic>> getActivityById(int id) async {
  // call endpoint
  final res = await _fetch.fetch(
    HttpMethod.get, // GET
    '$_BASE/$id', // path with id
  );

  // read payload
  final data = res.data; // any type

  // ensure it is an object
  if (data is! Map) {
    throw Exception('Invalid activity details'); // guard message
  }

  // return as typed map
  return Map<String, dynamic>.from(data); // item details object
}
