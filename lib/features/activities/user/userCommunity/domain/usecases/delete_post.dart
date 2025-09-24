import '../repositories/social_repository.dart';

class DeletePost {
  final SocialRepository repo; // dependency
  DeletePost(this.repo); // ctor
  Future<void> call(String token, int postId) =>
      repo.deletePost(token, postId); // forward
}
