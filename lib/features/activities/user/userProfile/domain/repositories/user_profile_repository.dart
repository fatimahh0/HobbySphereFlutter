// === Domain contract: what the feature needs ===
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart'; // entity

abstract class UserProfileRepository {
  Future<UserEntity> getProfile({
    required String token,
    required int userId,
  }); // fetch profile
  Future<void> setVisibility({
    required String token,
    required bool isPublic,
  }); // toggle visibility
  Future<void> setStatus({
    // set ACTIVE/INACTIVE
    required String token,
    required int userId,
    required String status,
    String? password, // required for INACTIVE
  });
}
