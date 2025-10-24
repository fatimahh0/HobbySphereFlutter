// lib/features/activities/user/userCommunity/data/services/social_service.dart
// Flutter 3.35.x — SocialService with tenant (ownerProjectLinkId) injection

import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class SocialService {
  final _fetch = ApiFetch();

  // roots (ApiFetch should prepend /api base)
  static const _api = '/posts';
  static const _comments = '/comments';
  static const _notif = '/notifications';

  // ---- Owner/Tenant helpers (same spirit as AuthService) ----
  dynamic get _oplId {
    final raw = (Env.ownerProjectLinkId).trim();
    assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
    return int.tryParse(raw) ?? raw;
  }

  Map<String, dynamic> _withOwner(Map<String, dynamic> body) => {
    ...body,
    'ownerProjectLinkId': _oplId,
  };

  // Append owner to a GET/DELETE path as query param
  String _withOwnerQuery(String path) {
    final sep = path.contains('?') ? '&' : '?';
    return '$path${sep}ownerProjectLinkId=$_oplId';
  }

  // Ensure FormData contains owner id (for multipart)
  FormData _addOwnerToForm(FormData form) {
    form.fields.add(MapEntry('ownerProjectLinkId', _oplId.toString()));
    return form;
  }

  // make sure Authorization header starts with "Bearer "
  String _bearer(String token) => token.trim().startsWith('Bearer ')
      ? token.trim()
      : 'Bearer ${token.trim()}';

  // -------------------- POSTS --------------------

  Future<List<dynamic>> getAllPosts({required String token}) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        _withOwnerQuery(_api), // /posts?ownerProjectLinkId=...
        headers: {'Authorization': _bearer(token)},
      );
      final data = res.data;
      if (data is List) return data;
      if (data is Map) {
        final maybe =
            data['data'] ?? data['items'] ?? data['content'] ?? data['posts'];
        if (maybe is List) return maybe;
      }
      return <dynamic>[];
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code == 204 || code == 404) return <dynamic>[];
      rethrow;
    }
  }

  Future<void> createPost({
    required String token,
    required String content,
    String? hashtags,
    String? visibility,
    List<int>? imageBytes,
    String? imageFilename,
    String? imageMime,
  }) async {
    final form = FormData.fromMap({
      'content': content,
      if (hashtags?.isNotEmpty == true) 'hashtags': hashtags,
      if (visibility?.isNotEmpty == true) 'visibility': visibility,
      if (imageBytes != null && imageBytes.isNotEmpty)
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: imageFilename ?? 'upload.jpg',
          contentType: imageMime != null ? DioMediaType.parse(imageMime) : null,
        ),
    });

    await _fetch.fetch(
      HttpMethod.post,
      _api, // body will carry owner
      headers: {'Authorization': _bearer(token)},
      data: _addOwnerToForm(form),
    );
  }

  Future<void> toggleLike({required String token, required int postId}) async {
    try {
      // send tiny form so backend reads owner in body
      final form = FormData.fromMap({'noop': '1'});
      await _fetch.fetch(
        HttpMethod.post,
        '$_api/$postId/like',
        headers: {'Authorization': _bearer(token)},
        data: _addOwnerToForm(form),
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      final body = e.response?.data;
      final isFormat = e.error is FormatException;
      if (code == 200 || isFormat || body is String) return;
      rethrow;
    }
  }

  Future<int> countLikes({required String token, required int postId}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _withOwnerQuery('$_api/$postId/likes'),
      headers: {'Authorization': _bearer(token)},
    );
    final v = res.data;
    return v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  }

  // -------------------- COMMENTS --------------------

  Future<List<dynamic>> getComments({
    required String token,
    required int postId,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _withOwnerQuery('$_comments/$postId'),
      headers: {'Authorization': _bearer(token)},
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return <dynamic>[];
  }

  Future<void> addComment({
    required String token,
    required int postId,
    required String content,
  }) async {
    final form = FormData.fromMap({'content': content});
    await _fetch.fetch(
      HttpMethod.post,
      '$_comments/$postId',
      headers: {'Authorization': _bearer(token)},
      data: _addOwnerToForm(form),
    );
  }

  Future<void> deleteComment({
    required String token,
    required int commentId,
  }) async {
    await _fetch.fetch(
      HttpMethod.delete,
      _withOwnerQuery('$_comments/$commentId'),
      headers: {'Authorization': _bearer(token)},
    );
  }

  // -------------------- NOTIFICATIONS --------------------

  Future<int> getUnreadNotificationCount({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _withOwnerQuery('$_notif/unread-count'),
      headers: {'Authorization': _bearer(token)},
    );
    final v = res.data;
    return v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  }

  // -------------------- EXTRA (already in your snippet) --------------------

  Future<List<dynamic>> getPostsByUser({
    required String token,
    required int userId,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      _withOwnerQuery('$_api/user/$userId'),
      headers: {'Authorization': _bearer(token)},
    );
    final data = res.data;
    if (data is List) return data;
    if (data is Map) {
      final maybe =
          data['data'] ?? data['items'] ?? data['content'] ?? data['posts'];
      if (maybe is List) return maybe;
    }
    return <dynamic>[];
  }

  Future<void> deletePost({required String token, required int postId}) async {
    try {
      await _fetch.fetch(
        HttpMethod.delete,
        _withOwnerQuery('$_api/$postId'),
        headers: {'Authorization': _bearer(token)},
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      final body = e.response?.data;
      final isFormat = e.error is FormatException;
      if (code == 200 || code == 204 || isFormat || body is String) return;
      rethrow;
    }
  }
}
