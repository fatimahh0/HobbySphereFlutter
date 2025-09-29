// 🌐 Low-level friends HTTP service (Dio).
import 'package:dio/dio.dart'; // dio
import '../../domain/entities/user_min.dart'; // map
import '../../domain/entities/friend_request.dart'; // map
import 'package:hobby_sphere/services/token_store.dart'; // token

class FriendsService {
  final Dio _dio; // client
  FriendsService(String baseUrl)
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)); // ctor

  Future<Options> _auth() async {
    final t = await TokenStore.read(); // token
    return Options(
      headers: {'Authorization': 'Bearer ${t.token ?? ''}'},
    ); // bearer
  }

  Future<List<UserMin>> getAllUsers() async {
    final res = await _dio.get('/api/users/all', options: await _auth()); // GET
    final list = (res.data as List).cast<dynamic>(); // list
    return list
        .map((e) => UserMin.fromMap(e as Map<String, dynamic>))
        .toList(); // map
  }

  Future<List<UserMin>> getSuggestedUsers(int meId) async {
    final res = await _dio.get(
      '/api/users/$meId/suggestions',
      options: await _auth(),
    ); // GET
    final list = (res.data as List).cast<dynamic>(); // list
    return list
        .map((e) => UserMin.fromMap(e as Map<String, dynamic>))
        .toList(); // map
  }

  Future<void> sendFriend(int friendId) async {
    await _dio.post(
      '/api/friends/add/$friendId',
      options: await _auth(),
    ); // POST
  }

  Future<void> cancelFriend(int friendId) async {
    await _dio.delete(
      '/api/friends/cancel/$friendId',
      options: await _auth(),
    ); // DELETE (by userId - optional)
  }

  Future<void> cancelSentRequest(int requestId) async {
    await _dio.delete(
      '/api/friends/cancel/$requestId',
      options: await _auth(),
    ); // DELETE (by requestId - used by Sent tab)
  }

  Future<List<FriendRequestItem>> getPending() async {
    final res = await _dio.get(
      '/api/friends/pending',
      options: await _auth(),
    ); // GET
    final list = (res.data as List).cast<dynamic>(); // list
    return list
        .map(
          (e) => FriendRequestItem.fromMap(
            e as Map<String, dynamic>,
            incoming: true,
          ),
        )
        .toList(); // map incoming
  }

  Future<List<FriendRequestItem>> getSent() async {
    final res = await _dio.get(
      '/api/friends/sent',
      options: await _auth(),
    ); // GET
    final list = (res.data as List).cast<dynamic>(); // list
    return list
        .map(
          (e) => FriendRequestItem.fromMap(
            e as Map<String, dynamic>,
            incoming: false,
          ),
        )
        .toList(); // map outgoing
  }

  Future<List<UserMin>> getFriends() async {
    final res = await _dio.get(
      '/api/friends/my',
      options: await _auth(),
    ); // GET
    final list = (res.data as List).cast<dynamic>(); // list
    return list
        .map((e) => UserMin.fromMap(e as Map<String, dynamic>))
        .toList(); // map
  }

  Future<void> accept(int requestId) async {
    await _dio.post(
      '/api/friends/accept/$requestId',
      options: await _auth(),
    ); // POST
  }

  Future<void> reject(int requestId) async {
    await _dio.post(
      '/api/friends/reject/$requestId',
      options: await _auth(),
    ); // POST
  }

  Future<void> unfriend(int userId) async {
    await _dio.delete(
      '/api/friends/unfriend/$userId',
      options: await _auth(),
    ); // DELETE
  }

  Future<void> block(int userId) async {
    await _dio.post(
      '/api/friends/block/$userId',
      options: await _auth(),
    ); // POST
  }

  Future<void> unblock(int userId) async {
    await _dio.delete(
      '/api/friends/unblock/$userId',
      options: await _auth(),
    ); // DELETE
  }
}
