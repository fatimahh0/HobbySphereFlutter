// 🌐 Low-level friends HTTP service (Dio) with ownerProjectLinkId injection.
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart'; // <- for OWNER_PROJECT_LINK_ID
import '../../domain/entities/user_min.dart';
import '../../domain/entities/friend_request.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/token_store.dart';

class FriendsService {
  final Dio _dio;

  FriendsService(String baseUrl) : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // ---- Owner/Tenant helpers ----
  dynamic get _oplId {
    final raw = (Env.ownerProjectLinkId).trim();
    assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
    return int.tryParse(raw) ?? raw;
  }

  // Append ownerProjectLinkId to any path (keeps existing query params)
  String _withOwnerQuery(String path) {
    final uri = Uri.parse(path);
    final qp = Map<String, String>.from(uri.queryParameters)
      ..['ownerProjectLinkId'] = _oplId.toString();
    return uri.replace(queryParameters: qp).toString();
  }

  // Minimal body for POST endpoints that otherwise have no body
  FormData _ownerForm() =>
      FormData.fromMap({'ownerProjectLinkId': _oplId.toString()});

  Future<Options> _auth() async {
    final t = await TokenStore.read();
    final bearer = (t.token ?? '').trim();
    final header = bearer.startsWith('Bearer ') ? bearer : 'Bearer $bearer';
    return Options(headers: {'Authorization': header});
  }

  // ------------------- USERS -------------------

  Future<List<UserMin>> getAllUsers() async {
    final res = await _dio.get(
      _withOwnerQuery('/users/all'),
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => UserMin.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<UserMin>> getSuggestedUsers(int meId) async {
    final res = await _dio.get(
      _withOwnerQuery('/users/$meId/suggestions'),
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => UserMin.fromMap(e as Map<String, dynamic>)).toList();
  }

  // ------------------- FRIEND REQUESTS -------------------

  Future<void> sendFriend(int friendId) async {
    await _dio.post(
      '/friends/add/$friendId',
      data: _ownerForm(),
      options: await _auth(),
    );
  }

  Future<void> cancelFriend(int friendId) async {
    await _dio.delete(
      _withOwnerQuery('/friends/cancel/$friendId'),
      options: await _auth(),
    );
  }

  Future<void> cancelSentRequest(int requestId) async {
    await _dio.delete(
      _withOwnerQuery('/friends/cancel/$requestId'),
      options: await _auth(),
    );
  }

  Future<List<FriendRequestItem>> getPending() async {
    final res = await _dio.get(
      _withOwnerQuery('/friends/pending'),
      options: await _auth(),
    );
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

  Future<List<FriendRequestItem>> getSent() async {
    final res = await _dio.get(
      _withOwnerQuery('/friends/sent'),
      options: await _auth(),
    );
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

  Future<List<UserMin>> getFriends() async {
    final res = await _dio.get(
      _withOwnerQuery('/friends/my'),
      options: await _auth(),
    );
    final list = (res.data as List).cast<dynamic>();
    return list.map((e) => UserMin.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> accept(int requestId) async {
    await _dio.post(
      '/friends/accept/$requestId',
      data: _ownerForm(),
      options: await _auth(),
    );
  }

  Future<void> reject(int requestId) async {
    await _dio.post(
      '/friends/reject/$requestId',
      data: _ownerForm(),
      options: await _auth(),
    );
  }

  Future<void> unfriend(int userId) async {
    await _dio.delete(
      _withOwnerQuery('/friends/unfriend/$userId'),
      options: await _auth(),
    );
  }

  Future<void> block(int userId) async {
    await _dio.post(
      '/friends/block/$userId',
      data: _ownerForm(),
      options: await _auth(),
    );
  }

  Future<void> unblock(int userId) async {
    await _dio.delete(
      _withOwnerQuery('/friends/unblock/$userId'),
      options: await _auth(),
    );
  }
}
