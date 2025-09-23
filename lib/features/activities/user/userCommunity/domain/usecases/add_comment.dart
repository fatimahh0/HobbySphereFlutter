// lib/features/activities/user/userCommunity/domain/usecases/add_comment.dart
// Flutter 3.35.x — thin usecase wrapper

import '../repositories/social_repository.dart'; // repo contract

class AddComment {
  final SocialRepository repo; // dependency
  AddComment(this.repo); // inject repo

  // call operator for easy usage
  Future<void> call(String token, int postId, String content) =>
      repo.addComment(token, postId, content); // forward to repo
}
