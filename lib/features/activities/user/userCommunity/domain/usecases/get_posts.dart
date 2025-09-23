import '../entities/post.dart';
import '../repositories/social_repository.dart';

class GetPosts {
  final SocialRepository repo;
  GetPosts(this.repo);
  Future<List<Post>> call(String token) => repo.getAllPosts(token);
}
