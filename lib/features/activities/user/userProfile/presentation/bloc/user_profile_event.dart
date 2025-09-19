// === BLoC events ===
abstract class UserProfileEvent {
  const UserProfileEvent();
} // base

class LoadUserProfile extends UserProfileEvent {
  // load
  final String token; // bearer
  final int userId; // id
  const LoadUserProfile(this.token, this.userId); // ctor
}

class ToggleVisibilityPressed extends UserProfileEvent {
  // toggle
  final String token; // bearer
  final bool newValue; // true/false
  const ToggleVisibilityPressed(this.token, this.newValue); // ctor
}

class UpdateStatusPressed extends UserProfileEvent {
  // set status
  final String token; // bearer
  final int userId; // id
  final String status; // "ACTIVE"/"INACTIVE"
  final String? password; // password for INACTIVE
  const UpdateStatusPressed(
    this.token,
    this.userId,
    this.status, {
    this.password,
  });
}
