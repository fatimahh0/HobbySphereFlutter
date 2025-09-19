// === Domain entity: single source of truth for a user ===
class UserEntity {
  final int id; // user id
  final String? username; // optional username
  final String firstName; // first name
  final String lastName; // last name
  final String? email; // optional email
  final String? phoneNumber; // optional phone
  final String? profileImageUrl; // optional relative image path
  final bool? isPublicProfile; // optional visibility flag
  final String? status; // optional status "ACTIVE"/"INACTIVE"

  const UserEntity({
    required this.id, // require id
    this.username, // can be null
    required this.firstName, // require first name
    required this.lastName, // require last name
    this.email, // optional email
    this.phoneNumber, // optional phone
    this.profileImageUrl, // optional image
    this.isPublicProfile, // optional visibility
    this.status, // optional status
  });

  // helpful: full name for UI
  String get fullName => '$firstName $lastName'; // concat
}
