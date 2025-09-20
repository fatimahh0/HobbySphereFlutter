import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';

class EditUserDto {
  final int id;
  final String? username;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool? publicProfile;
  final String? status;

  EditUserDto({
    required this.id,
    this.username,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.publicProfile,
    this.status,
  });

  // Small helpers to read safely from mixed server shapes
  static String? _str(Map m, String key) {
    final v = m[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static String? _fromMany(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null) {
        final s = v.toString();
        if (s.isNotEmpty) return s;
      }
    }
    return null;
  }

  factory EditUserDto.fromMap(Map<String, dynamic> m) {
    // Some endpoints return the user under "user": {...}
    final root = (m['user'] is Map)
        ? (m['user'] as Map).cast<String, dynamic>()
        : m;

    final idVal = root['id'] ?? m['id'];
    final statusVal = root['status'] ?? m['status'];

    return EditUserDto(
      id: (idVal as num).toInt(),
      // username can be `username`, `userName`, or nested under user
      username: _fromMany(root, ['username', 'userName']),
      firstName: _str(root, 'firstName') ?? '',
      lastName: _str(root, 'lastName') ?? '',
      email: _fromMany(root, ['email']),
      phoneNumber: _fromMany(root, ['phoneNumber']),
      // image key varies across endpoints: profileImageUrl / profilePictureUrl / profilePicture
      profileImageUrl: _fromMany(root, [
        'profileImageUrl',
        'profilePictureUrl',
        'profilePicture',
      ]),
      // visibility key varies: isPublicProfile / publicProfile
      publicProfile:
          (root['isPublicProfile'] ?? root['publicProfile']) as bool?,
      // status can be a Map {name: "..."} or a plain string
      status: statusVal is Map
          ? _str(statusVal, 'name')
          : statusVal?.toString(),
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    profileImageUrl: profileImageUrl,
    isPublicProfile: publicProfile,
    status: status,
  );
}
