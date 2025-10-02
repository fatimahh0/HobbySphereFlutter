class UserProfile {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final bool? isPublicProfile;

  UserProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
    this.isPublicProfile,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    id: (m['id'] as num).toInt(),
    username: m['username'] ?? '',
    firstName: m['firstName'] ?? '',
    lastName: m['lastName'] ?? '',
    email: m['email'],
    phoneNumber: m['phoneNumber'],
    profilePictureUrl: m['profilePictureUrl'],
    isPublicProfile: m['isPublicProfile'] as bool?,
  );
}
