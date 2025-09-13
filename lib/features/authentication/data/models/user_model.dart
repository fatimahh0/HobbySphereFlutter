class UserModel {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: (m['id'] as num).toInt(),
    username: m['username'],
    firstName: m['firstName'],
    lastName: m['lastName'],
    email: m['email'],
    phoneNumber: m['phoneNumber'],
    profilePictureUrl: m['profilePictureUrl'],
  );
}
