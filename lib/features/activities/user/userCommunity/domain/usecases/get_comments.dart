// lib/features/activities/user/userCommunity/domain/usecases/get_comments.dart
// Flutter 3.35.x — thin usecase wrapper

import '../entities/comment.dart'; // entity
import '../repositories/social_repository.dart'; // repo contract

class GetComments {
  final SocialRepository repo; // dependency
  GetComments(this.repo); // inject repo

  // call operator for easy usage
  Future<List<Comment>> call(String token, int postId) =>
      repo.getComments(token, postId); // forward to repo
}
