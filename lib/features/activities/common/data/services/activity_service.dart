// ===== Flutter 3.35.x =====
// services/activity_service.dart
// Adds ownerProjectLinkId to all endpoints

import 'package:hobby_sphere/config/env.dart'; // <-- NEW
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

const String _BASE = '/items';
final ApiFetch _fetch = ApiFetch();

// ---- Owner/Tenant helpers ----
String get _oplIdStr {
  final raw = Env.ownerProjectLinkId.trim();
  assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
  return raw;
}

Map<String, dynamic> _withOwnerQuery([Map<String, dynamic>? q]) =>
    <String, dynamic>{...?q, 'ownerProjectLinkId': _oplIdStr};

// -----------------------------------------------
// GET /api/items/upcoming
Future<List<dynamic>> getAllActivities() async {
  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/upcoming',
    data: _withOwnerQuery(), // <-- inject as query
  );

  final data = res.data;
  if (data is! List) throw Exception('Invalid response format');
  return data;
}

// -----------------------------------------------
// GET /api/items/interest-based/{userId}
Future<List<dynamic>> getInterestBasedActivities({
  required int userId,
  String? token,
}) async {
  final headers = <String, String>{
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/interest-based/$userId',
    data: _withOwnerQuery(), // <-- inject
    headers: headers,
  );

  final data = res.data;
  if (data is! List) throw Exception('Invalid response format');
  return data;
}

// -----------------------------------------------
// GET /api/items/guest/upcoming[?typeId=]
Future<List<dynamic>> getGuestUpcomingActivities({int? typeId}) async {
  final query = _withOwnerQuery({if (typeId != null) 'typeId': typeId});

  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/guest/upcoming',
    data: query, // <-- inject
  );

  final data = res.data;
  if (data is! List) throw Exception('Invalid response format');
  return data;
}

// -----------------------------------------------
// GET /api/items/by-type/{typeId}
Future<List<dynamic>> getActivitiesByType(int typeId) async {
  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/by-type/$typeId',
    data: _withOwnerQuery(), // <-- inject
  );

  final data = res.data;
  if (data is! List) throw Exception('Invalid response format');
  return data;
}

// -----------------------------------------------
// GET /api/items/{activityId}/check-availability?participants=X
Future<Map<String, dynamic>> checkAvailability({
  required int activityId,
  required int participants,
  String? token,
}) async {
  if (token == null || token.isEmpty) {
    throw Exception('User token required');
  }

  final headers = <String, String>{'Authorization': 'Bearer $token'};
  final query = _withOwnerQuery({'participants': participants});

  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/$activityId/check-availability',
    data: query, // <-- inject
    headers: headers,
  );

  final data = res.data;
  if (data is! Map || data['available'] is! bool) {
    throw Exception('Invalid availability response');
  }
  return Map<String, dynamic>.from(data);
}

// -----------------------------------------------
// GET /api/items/{id}
Future<Map<String, dynamic>> getActivityById(int id) async {
  final res = await _fetch.fetch(
    HttpMethod.get,
    '$_BASE/$id',
    data: _withOwnerQuery(), // <-- inject
  );

  final data = res.data;
  if (data is! Map) throw Exception('Invalid activity details');
  return Map<String, dynamic>.from(data);
}
