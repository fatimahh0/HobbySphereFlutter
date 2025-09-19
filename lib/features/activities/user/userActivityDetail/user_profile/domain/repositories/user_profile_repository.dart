// Contract for data access — presentation depends on this, not on services

import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  // load user by id using token
  Future<UserProfile> getProfile({required String token, required int userId});

  // toggle visibility (server uses token to find user)
  Future<void> setVisibility({required String token, required bool isPublic});

  // update status (INACTIVE requires password)
  Future<void> setStatus({
    required String token,
    required int userId,
    required String status, // e.g. "ACTIVE" or "INACTIVE"
    String? password, // required if INACTIVE
  });
}
