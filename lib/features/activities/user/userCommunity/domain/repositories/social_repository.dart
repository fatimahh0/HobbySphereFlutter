import '../entities/post.dart';
import '../entities/comment.dart';

abstract class SocialRepository {
  // posts
  Future<List<Post>> getAllPosts(String token);
  Future<void> toggleLike(String token, int postId);
  Future<int> countLikes(String token, int postId);
  Future<void> createPost({
    required String token,
    required String content,
    String? hashtags,
    String? visibility,
    // accept file bytes or path in service translation layer
    List<int>? imageBytes,
    String? imageFilename,
    String? imageMime,
  });

  // comments
  Future<List<Comment>> getComments(String token, int postId);
  Future<void> addComment(String token, int postId, String content);
  Future<void> deleteComment(String token, int commentId);


  // notifications
  Future<int> getUnreadNotificationCount(String token);


   Future<List<Post>> getPostsByUser(String token, int userId); // new
  Future<void> deletePost(String token, int postId);           // new
}
