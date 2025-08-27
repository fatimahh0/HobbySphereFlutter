// ===== Flutter 3.35.x =====
// services/social_service.dart
// Social APIs: posts, likes, comments, notifications, and FCM token management.

import 'package:dio/dio.dart'; // FormData, Multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // universal fetch
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET / POST / PUT / DELETE

class SocialService {
  final _fetch = ApiFetch(); // shared client
  static const _base = ''; // base prefix (global baseUrl already has /api)

  // ------------------------------------------------------------
  // POSTS
  // ------------------------------------------------------------

  // POST /api/posts
  Future<Map<String, dynamic>> createPost({
    required String token,
    required String content,
    String? hashtags,
    String? visibility,
    Map<String, dynamic>? image, // { uri, name, type }
  }) async {
    final form = FormData();

    form.fields.add(MapEntry('content', content));
    if (hashtags != null && hashtags.isNotEmpty) {
      form.fields.add(MapEntry('hashtags', hashtags));
    }
    if (visibility != null && visibility.isNotEmpty) {
      form.fields.add(MapEntry('visibility', visibility));
    }

    if (image != null) {
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image['uri'], // file path
            filename: image['name'] ?? 'image.jpg', // file name
            contentType: DioMediaType.parse(
              image['type'] ?? 'image/jpeg',
            ), // MIME
          ),
        ),
      );
    }

    final res = await _fetch.fetch(
      HttpMethod.post,
      '/posts',
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid create post response');
    return Map<String, dynamic>.from(data);
  }

  // GET /api/posts
  Future<List<dynamic>> getAllPosts(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/posts',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid posts response');
    return data;
  }

  // DELETE /api/posts/{postId}
  Future<Map<String, dynamic>> deletePost(String token, int postId) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/posts/$postId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // GET /api/posts/user/{userId}
  Future<List<dynamic>> getPostsByUser(String token, int userId) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/posts/user/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid posts by user response');
    return data;
  }

  // DELETE /api/posts/{postId}/user/{userId}
  Future<Map<String, dynamic>> deletePostByUser(
    String token,
    int postId,
    int userId,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/posts/$postId/user/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // LIKES
  // ------------------------------------------------------------

  // POST /api/posts/{postId}/like
  Future<Map<String, dynamic>> toggleLike(String token, int postId) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '/posts/$postId/like',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // GET /api/posts/{postId}/likes
  Future<int> countLikes(String token, int postId) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/posts/$postId/likes',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is int) return data;
    if (data is Map && data['count'] is int) return data['count'] as int;
    throw Exception('Invalid likes response');
  }

  // ------------------------------------------------------------
  // COMMENTS
  // ------------------------------------------------------------

  // POST /api/comments/{postId}
  Future<Map<String, dynamic>> addComment(
    String token,
    int postId,
    String content,
  ) async {
    final form = FormData();
    form.fields.add(MapEntry('content', content));

    final res = await _fetch.fetch(
      HttpMethod.post,
      '/comments/$postId',
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid add comment response');
    return Map<String, dynamic>.from(data);
  }

  // GET /api/comments/{postId}
  Future<List<dynamic>> getComments(String token, int postId) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/comments/$postId',
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = res.data;
    if (data is! List) {
      // backend might 404 if no comments
      return [];
    }
    return data;
  }

  // DELETE /api/comments/{commentId}
  Future<Map<String, dynamic>> deleteComment(
    String token,
    int commentId,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/comments/$commentId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // NOTIFICATIONS
  // ------------------------------------------------------------

  // GET /api/notifications
  Future<List<dynamic>> getNotifications(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/notifications',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! List) throw Exception('Invalid notifications response');
    return data;
  }

  // PUT /api/notifications/{id}/read
  Future<Map<String, dynamic>> markNotificationAsRead(
    String token,
    int id,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '/notifications/$id/read',
      data: {},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // DELETE /api/notifications/{id}
  Future<Map<String, dynamic>> deleteNotification(String token, int id) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/notifications/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // GET /api/notifications/unread-count
  Future<int> getUnreadNotificationCount(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/notifications/unread-count',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is int) return data;
    if (data is Map && data['count'] is int) return data['count'] as int;
    throw Exception('Invalid unread-count response');
  }

  // ------------------------------------------------------------
  // FCM TOKENS
  // ------------------------------------------------------------

  // PUT /api/notifications/user/fcm-token
  Future<Map<String, dynamic>> saveUserFcmToken(
    String token,
    String fcmToken,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '/notifications/user/fcm-token',
      data: {'fcmToken': fcmToken},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/notifications/business/fcm-token
  Future<Map<String, dynamic>> saveBusinessFcmToken(
    String token,
    String fcmToken,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '/notifications/business/fcm-token',
      data: {'fcmToken': fcmToken},
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }
}
