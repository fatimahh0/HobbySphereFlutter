// ===== Flutter 3.35.x =====
// services/friends_service.dart
// Friends API: send/accept/reject/cancel/block/unblock/unfriend,
// lists (pending, sent, my), count, and friendship status.

import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch (Dio)
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST / DELETE

class FriendsService {
  // create one helper that reuses the global Dio client
  final _fetch = ApiFetch(); // shared HTTP helper

  // base path (global baseUrl already contains "/api")
  static const _base = '/friends'; // -> <server>/api/friends

  // ------------------------------------------------------------
  // POST /api/friends/add/{friendId}
  Future<Map<String, dynamic>> sendFriendRequest({
    required String token, // JWT token
    required int friendId, // target user id
  }) async {
    // call POST with Authorization header (no body)
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/add/$friendId',
      headers: {'Authorization': 'Bearer $token'},
    );
    // ensure object response
    final data = res.data;
    if (data is! Map) throw Exception('Invalid send request response');
    return Map<String, dynamic>.from(data); // return as map
  }

  // ------------------------------------------------------------
  // POST /api/friends/accept/{requestId}
  Future<Map<String, dynamic>> acceptFriendRequest({
    required String token,
    required int requestId, // request id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/accept/$requestId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid accept response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // POST /api/friends/reject/{requestId}
  Future<Map<String, dynamic>> rejectFriendRequest({
    required String token,
    required int requestId,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/reject/$requestId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid reject response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/friends/cancel/{friendId}
  Future<Map<String, dynamic>> cancelFriendRequest({
    required String token,
    required int friendId, // target user id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/cancel/$friendId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid cancel response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // POST /api/friends/block/{userId}
  Future<Map<String, dynamic>> blockUser({
    required String token,
    required int userId, // user to block
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/block/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid block response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/friends/unblock/{userId}
  Future<Map<String, dynamic>> unblockUser({
    required String token,
    required int userId, // user to unblock
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/unblock/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid unblock response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/friends/unfriend/{userId}
  Future<Map<String, dynamic>> unfriendUser({
    required String token,
    required int userId, // friend to remove
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/unfriend/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid unfriend response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // GET /api/friends/pending
  Future<List<dynamic>> getPendingRequests(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/pending',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid pending list');
    return data;
  }

  // ------------------------------------------------------------
  // GET /api/friends/pending/count
  Future<int> getPendingRequestCount(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/pending/count',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    // some backends return {count: N}, others just N
    if (data is int) return data; // plain number
    if (data is Map && data['count'] is int)
      return data['count'] as int; // object
    throw Exception('Invalid pending count response'); // guard
  }

  // ------------------------------------------------------------
  // GET /api/friends/my
  Future<List<dynamic>> getMyFriends(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/my',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid friends list');
    return data;
  }

  // ------------------------------------------------------------
  // GET /api/friends/sent
  Future<List<dynamic>> getSentRequests(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/sent',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid sent list');
    return data;
  }

  // ------------------------------------------------------------
  // GET /api/friends/status/{userId}
  Future<Map<String, dynamic>> getFriendshipStatus({
    required String token,
    required int userId, // other user id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/status/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid status response');
    return Map<String, dynamic>.from(data);
  }
}
