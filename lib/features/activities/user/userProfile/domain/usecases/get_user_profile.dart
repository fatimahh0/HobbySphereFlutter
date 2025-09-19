// === Use case: get user profile ===
import '../repositories/user_profile_repository.dart'; // repo
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart'; // entity

class GetUserProfile {
  final UserProfileRepository repo; // dependency
  GetUserProfile(this.repo); // inject
  Future<UserEntity> call(String token, int id) => // call-style
      repo.getProfile(token: token, userId: id); // delegate
}
