// Flutter 3.35.x — entity used by all layers
// Simple model: only what UI needs (can expand later)

class UserProfile {
  // user id
  final int id;
  // first name
  final String firstName;
  // last name
  final String lastName;
  // optional email
  final String? email;
  // optional phone
  final String? phoneNumber;
  // optional profile image (relative from server)
  final String? profileImageUrl;
  // status text like "ACTIVE"
  final String status;
  // last login (optional)
  final DateTime? lastLogin;
  // is public profile
  final bool publicProfile;

  const UserProfile({
    required this.id, // id required
    required this.firstName, // first required
    required this.lastName, // last required
    this.email, // nullable
    this.phoneNumber, // nullable
    this.profileImageUrl, // nullable
    required this.status, // status text
    this.lastLogin, // nullable date
    required this.publicProfile, // visibility flag
  });

  // helper: full display name
  String get fullName => '$firstName $lastName'.trim();

  // helper: is profile public?
  bool get isPublic => publicProfile;
}
