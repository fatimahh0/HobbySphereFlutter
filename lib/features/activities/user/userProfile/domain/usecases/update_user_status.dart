// === Use case: set ACTIVE/INACTIVE ===
import '../repositories/user_profile_repository.dart'; // repo

class UpdateUserStatus {
  final UserProfileRepository repo; // dependency
  UpdateUserStatus(this.repo); // inject

  Future<void> call({
    // call-style
    required String token,
    required int userId,
    required String status, // "ACTIVE"/"INACTIVE"
    String? password, // required if INACTIVE
  }) => repo.setStatus(
    token: token,
    userId: userId,
    status: status,
    password: password,
  ); // delegate
}
