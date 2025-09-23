import '../repositories/social_repository.dart';

class ToggleLike {
  final SocialRepository repo;
  ToggleLike(this.repo);
  Future<void> call(String token, int postId) => repo.toggleLike(token, postId);
}
