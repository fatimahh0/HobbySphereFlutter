// lib/features/activities/user/userCommunity/data/services/social_service.dart
// Flutter 3.35.x — SocialService (no static host, all relative, plain & robust)

import 'package:dio/dio.dart'; // HTTP & FormData
import 'package:hobby_sphere/core/network/api_fetch.dart'; // your wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // method enum

class SocialService {
  final _fetch = ApiFetch(); // one shared client

  // ✅ always under /api (relative paths; baseUrl handled by ApiFetch)
  static const _api = '/posts'; // posts root
  static const _comments = '/comments'; // comments root
  static const _notif = '/notifications'; // notifications root

  // make sure Authorization header starts with "Bearer "
  String _bearer(String token) => token.trim().startsWith('Bearer ')
      ? token.trim()
      : 'Bearer ${token.trim()}';

  // -------------------- POSTS --------------------

  Future<List<dynamic>> getAllPosts({required String token}) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.get, // GET
        _api, // /api/posts
        headers: {'Authorization': _bearer(token)}, // bearer
      );
      final data = res.data; // payload
      if (data is List) return data; // raw list
      if (data is Map) {
        // wrapped list?
        final maybe =
            data['data'] ?? data['items'] ?? data['content'] ?? data['posts'];
        if (maybe is List) return maybe;
      }
      return <dynamic>[]; // fallback
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0; // http code
      if (code == 204 || code == 404) return <dynamic>[]; // empty is fine
      rethrow; // other errors
    }
  }

  Future<void> createPost({
    required String token, // jwt
    required String content, // text
    String? hashtags, // optional
    String? visibility, // PUBLIC/FRIENDS_ONLY
    List<int>? imageBytes, // optional
    String? imageFilename, // optional
    String? imageMime, // e.g. image/jpeg
  }) async {
    // multipart form (works well with Spring)
    final form = FormData.fromMap({
      'content': content, // required
      if (hashtags?.isNotEmpty == true) 'hashtags': hashtags,
      if (visibility?.isNotEmpty == true) 'visibility': visibility,
      if (imageBytes != null && imageBytes.isNotEmpty)
        'image': MultipartFile.fromBytes(
          // optional image
          imageBytes,
          filename: imageFilename ?? 'upload.jpg',
          contentType: imageMime != null ? DioMediaType.parse(imageMime) : null,
        ),
    });

    await _fetch.fetch(
      HttpMethod.post, // POST
      _api, // /api/posts
      headers: {'Authorization': _bearer(token)}, // bearer
      data: form, // multipart body
    );
  }

  Future<void> toggleLike({required String token, required int postId}) async {
    try {
      await _fetch.fetch(
        HttpMethod.post, // POST
        '$_api/$postId/like', // /api/posts/{id}/like
        headers: {'Authorization': _bearer(token)}, // bearer
      );
    } on DioException catch (e) {
      // if server returned 200 but wrapper tripped on plain text, treat as success
      final code = e.response?.statusCode ?? 0;
      final body = e.response?.data;
      final isFormat = e.error is FormatException;
      if (code == 200 || isFormat || body is String) return;
      rethrow;
    }
  }

  Future<int> countLikes({required String token, required int postId}) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_api/$postId/likes', // /api/posts/{id}/likes
      headers: {'Authorization': _bearer(token)}, // bearer
    );
    final v = res.data; // payload
    return v is num ? v.toInt() : int.tryParse('$v') ?? 0; // normalize
  }

  // -------------------- COMMENTS --------------------

  Future<List<dynamic>> getComments({
    required String token, // jwt
    required int postId, // post id
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_comments/$postId', // /api/comments/{postId}
      headers: {'Authorization': _bearer(token)}, // bearer
    );
    final data = res.data; // payload
    if (data is List) return data; // raw list
    if (data is Map && data['data'] is List) return data['data']; // wrapped
    return <dynamic>[]; // fallback
  }

  // ✅ send as FORM (multipart) so Spring @RequestParam("content") is found
  Future<void> addComment({
    required String token, // jwt
    required int postId, // post id
    required String content, // comment text
  }) async {
    final form = FormData.fromMap({'content': content}); // one field form
    await _fetch.fetch(
      HttpMethod.post, // POST
      '$_comments/$postId', // /api/comments/{postId}
      headers: {'Authorization': _bearer(token)}, // bearer
      data: form, // multipart/form-data
    );
  }

  Future<void> deleteComment({
    required String token, // jwt
    required int commentId, // comment id
  }) async {
    await _fetch.fetch(
      HttpMethod.delete, // DELETE
      '$_comments/$commentId', // /api/comments/{id}
      headers: {'Authorization': _bearer(token)}, // bearer
    );
  }

  // -------------------- NOTIFICATIONS --------------------

  Future<int> getUnreadNotificationCount({required String token}) async {
    final res = await _fetch.fetch(
      HttpMethod.get, // GET
      '$_notif/unread-count', // /api/notifications/unread-count
      headers: {'Authorization': _bearer(token)}, // bearer
    );
    final v = res.data; // payload
    return v is num ? v.toInt() : int.tryParse('$v') ?? 0; // normalize
  }
}
