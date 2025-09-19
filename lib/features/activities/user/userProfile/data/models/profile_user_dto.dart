// === DTO: exactly matches /api/users/{id} response ===


import '../../../../common/domain/entities/user_entity.dart';

class ProfileUserDto {
  final int id; // id
  final String firstName; // first name
  final String lastName; // last name
  final String? email; // email
  final String? phoneNumber; // phone
  final String? profileImageUrl; // image key name in profile API
  final bool publicProfile; // visibility flag
  final String? statusName; // nested status.name or simple text

  ProfileUserDto({
    required this.id, // ctor id
    required this.firstName, // ctor first
    required this.lastName, // ctor last
    this.email, // optional email
    this.phoneNumber, // optional phone
    this.profileImageUrl, // optional image
    required this.publicProfile, // ctor visibility
    this.statusName, // optional status text
  });

  factory ProfileUserDto.fromMap(Map<String, dynamic> m) {
    // try get status name from nested object or direct field
    final st = m['status'];
    final name = st is Map ? st['name'] as String? : m['status'] as String?;

    return ProfileUserDto(
      id: (m['id'] as num).toInt(), // parse int safely
      firstName: '${m['firstName'] ?? ''}', // to string
      lastName: '${m['lastName'] ?? ''}', // to string
      email: m['email'] as String?, // email or null
      phoneNumber: m['phoneNumber'] as String?, // phone or null
      profileImageUrl: m['profileImageUrl'] as String?, // image or null
      publicProfile:
          (m['publicProfile'] ?? m['isPublicProfile'] ?? false) ==
          true, // boolean
      statusName: name, // status text
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id, // map id
    username: null, // not provided here
    firstName: firstName, // map
    lastName: lastName, // map
    email: email, // map
    phoneNumber: phoneNumber, // map
    profileImageUrl: profileImageUrl, // map
    isPublicProfile: publicProfile, // map
    status: statusName, // map
  );
}
