// lib/features/activities/user/userCommunity/domain/usecases/get_my_posts.dart
import '../entities/post.dart';
import '../repositories/social_repository.dart';

class GetMyPosts {
  final SocialRepository repo;                 // dependency
  GetMyPosts(this.repo);                       // ctor
  Future<List<Post>> call(String token, int userId) =>
      repo.getPostsByUser(token, userId);      // forward
}

