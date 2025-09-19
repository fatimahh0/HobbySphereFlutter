// === Use case: toggle profile visibility ===
import '../repositories/user_profile_repository.dart'; // repo

class ToggleUserVisibility {
  final UserProfileRepository repo; // dependency
  ToggleUserVisibility(this.repo); // inject

  Future<void> call(String token, bool isPublic) => // call-style
      repo.setVisibility(token: token, isPublic: isPublic); // delegate
}
