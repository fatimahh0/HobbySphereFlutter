// lib/features/activities/user/userCommunity/data/repositories/social_repository_impl.dart
// Flutter 3.35.x
import '../../domain/repositories/social_repository.dart'; // contract
import '../../domain/entities/post.dart'; // entity
import '../../domain/entities/comment.dart'; // entity
import '../models/post_model.dart'; // mapper
import '../models/comment_model.dart'; // mapper
import '../services/social_service.dart'; // service
import 'package:dio/dio.dart'; // catch dio

class SocialRepositoryImpl implements SocialRepository {
  final SocialService service; // dependency
  SocialRepositoryImpl(this.service); // ctor

  @override
  Future<List<Post>> getAllPosts(String token) async {
    try {
      final raw = await service.getAllPosts(token: token); // call service
      final list = <Post>[]; // result list
      for (final it in raw) {
        // loop items
        if (it is Map<String, dynamic>) {
          // only json maps
          try {
            list.add(PostModel.fromJson(it)); // parse one
          } catch (_) {
            // skip malformed item safely
          }
        }
      }
      // sort newest first, safe even if dates are epoch(0)
      list.sort((a, b) => b.postDatetime.compareTo(a.postDatetime));
      return list; // done
    } on DioException catch (e) {
      // normalize 204 → empty list
      if ((e.response?.statusCode ?? 0) == 204) return <Post>[];
      rethrow; // propagate real errors
    }
  }

  @override
  Future<void> toggleLike(String token, int postId) {
    // forward to service
    return service.toggleLike(token: token, postId: postId);
  }

  @override
  Future<int> countLikes(String token, int postId) {
    // forward to service
    return service.countLikes(token: token, postId: postId);
  }

  @override
  Future<void> createPost({
    required String token,
    required String content,
    String? hashtags,
    String? visibility,
    List<int>? imageBytes,
    String? imageFilename,
    String? imageMime,
  }) {
    // forward to service (multipart)
    return service.createPost(
      token: token,
      content: content,
      hashtags: hashtags,
      visibility: visibility,
      imageBytes: imageBytes,
      imageFilename: imageFilename,
      imageMime: imageMime,
    );
  }

  @override
  Future<List<Comment>> getComments(String token, int postId) async {
    final raw = await service.getComments(token: token, postId: postId); // call
    return raw
        .whereType<Map<String, dynamic>>() // keep maps
        .map(CommentModel.fromJson) // parse
        .toList(growable: false); // list
  }

  @override
  Future<void> addComment(String token, int postId, String content) {
    // forward to service
    return service.addComment(token: token, postId: postId, content: content);
  }

  @override
  Future<void> deleteComment(String token, int commentId) {
    // forward to service
    return service.deleteComment(token: token, commentId: commentId);
  }

  @override
  Future<int> getUnreadNotificationCount(String token) {
    // forward to service
    return service.getUnreadNotificationCount(token: token);
  }

  @override
  Future<List<Post>> getPostsByUser(String token, int userId) async {
    try {
      final raw = await service.getPostsByUser(
        token: token,
        userId: userId,
      ); // call service
      final list = <Post>[];
      for (final it in raw) {
        if (it is Map<String, dynamic>) {
          try {
            list.add(PostModel.fromJson(it));
          } catch (_) {}
        }
      }
      list.sort(
        (a, b) => b.postDatetime.compareTo(a.postDatetime),
      ); // newest first
      return list;
    } on DioException catch (e) {
      if ((e.response?.statusCode ?? 0) == 204) return <Post>[]; // empty ok
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String token, int postId) {
    return service.deletePost(token: token, postId: postId); // pass-through
  }
}
