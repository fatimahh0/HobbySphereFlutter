import 'package:dio/dio.dart'; // HTTP client
import 'package:hobby_sphere/features/activities/user/social/domain/entities/friend_request.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/services/token_store.dart';

// A tiny low-level service that hits /api/users and /api/friends endpoints.
class FriendsService {
  final Dio _dio; // injected Dio so it is testable

  FriendsService(String baseUrl)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)); // build Dio with base url

  // add Authorization header to each call
  Future<Options> _auth() async {
    final t = await TokenStore.read(); // read token + role
    return Options(
      headers: {'Authorization': 'Bearer ${t.token ?? ''}'},
    ); // bearer
  }

  // GET /api/users/all → List<UserMin>
  Future<List<UserMin>> getAllUsers() async {
    final res = await _dio.get(
      '/api/users/all',
      options: await _auth(),
    ); // call
    final list = (res.data as List).cast<dynamic>(); // ensure list
    return list
        .map((e) => UserMin.fromMap(e as Map<String, dynamic>))
        .toList(); // map to UserMin
  }

  // GET /api/users/{id}/suggestions
  Future<List<UserMin>> getSuggestedUsers(int meId) async {
    final res = await _dio.get(
      '/api/users/$meId/suggestions',
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => UserMin.fromMap(e as Map<String, dynamic>)).toList();
  }

  // POST /api/friends/add/{friendId}
  Future<void> sendFriend(int friendId) async {
    await _dio.post(
      '/api/friends/add/$friendId',
      options: await _auth(),
    ); // no body
  }

  // DELETE /api/friends/cancel/{friendId}
  Future<void> cancelFriend(int friendId) async {
    await _dio.delete('/api/friends/cancel/$friendId', options: await _auth());
  }

  // GET /api/friends/pending → incoming requests
  Future<List<FriendRequestItem>> getPending() async {
    final res = await _dio.get('/api/friends/pending', options: await _auth());
    final list = (res.data as List).cast<dynamic>();
    return list
        .map(
          (e) => FriendRequestItem.fromMap(
            e as Map<String, dynamic>,
            incoming: true,
          ),
        )
        .toList();
  }

  // GET /api/friends/sent → outgoing requests
  Future<List<FriendRequestItem>> getSent() async {
    final res = await _dio.get('/api/friends/sent', options: await _auth());
    final list = (res.data as List).cast<dynamic>();
    return list
        .map(
          (e) => FriendRequestItem.fromMap(
            e as Map<String, dynamic>,
            incoming: false,
          ),
        )
        .toList();
  }

  // GET /api/friends/my → accepted friends → List<Users> (we convert to UserMin)
  Future<List<UserMin>> getFriends() async {
    final res = await _dio.get('/api/friends/my', options: await _auth());
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => UserMin.fromMap(e as Map<String, dynamic>)).toList();
  }

  // POST /api/friends/accept/{requestId}
  Future<void> accept(int requestId) async {
    await _dio.post('/api/friends/accept/$requestId', options: await _auth());
  }

  // POST /api/friends/reject/{requestId}
  Future<void> reject(int requestId) async {
    await _dio.post('/api/friends/reject/$requestId', options: await _auth());
  }

  // DELETE /api/friends/unfriend/{userId}
  Future<void> unfriend(int userId) async {
    await _dio.delete('/api/friends/unfriend/$userId', options: await _auth());
  }

  // POST /api/friends/block/{userId}
  Future<void> block(int userId) async {
    await _dio.post('/api/friends/block/$userId', options: await _auth());
  }

  // DELETE /api/friends/unblock/{userId}
  Future<void> unblock(int userId) async {
    await _dio.delete('/api/friends/unblock/$userId', options: await _auth());
  }

  Future<void> cancelSentRequest(int requestId) async {
    await _dio.delete(
      // DELETE call
      '/api/friends/cancel/$requestId', // requestId path
      options: await _auth(), // with auth
    );
  }
}
