// === Repository impl: service <-> domain ===
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart'; // entity
import '../../domain/repositories/user_profile_repository.dart'; // contract
import '../models/profile_user_dto.dart'; // dto
import '../services/user_profile_service.dart' as svc; // service (aliased)

class UserProfileRepositoryImpl implements UserProfileRepository {
  final svc.UserProfileService service; // dependency

  UserProfileRepositoryImpl(this.service); // inject

  @override
  Future<UserEntity> getProfile({
    required String token,
    required int userId,
  }) async {
    final map = await service.fetchProfileMap(
      token: token,
      userId: userId,
    ); // call API
    final dto = ProfileUserDto.fromMap(map); // parse DTO
    return dto.toEntity(); // map to domain
  }

  @override
  Future<void> setVisibility({required String token, required bool isPublic}) =>
      service.updateVisibility(token: token, isPublic: isPublic); // forward

  @override
  Future<void> setStatus({
    required String token,
    required int userId,
    required String status,
    String? password,
  }) => service.updateStatus(
    // forward
    token: token,
    userId: userId,
    status: status,
    password: password,
  );
}
