import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/models/edit_user_dto.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/services/edit_user_service.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/repositories/edit_user_repository.dart';

class EditUserRepositoryImpl implements EditUserRepository {
  final EditUserService service;
  EditUserRepositoryImpl(this.service);

  @override
  Future<UserEntity> getById({
    required String token,
    required int userId,
  }) async {
    final map = await service.getUserMap(token: token, userId: userId);
    return EditUserDto.fromMap(map).toEntity();
  }

  @override
  Future<void> updateProfile({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    String? username,
    String? email, // kept for interface
    String? phoneNumber, // kept for interface
    String? newPassword,
    String? imagePath,
    bool removeImage = false,
  }) async {
    if (removeImage) {
      await service.deleteProfileImage(token: token, userId: userId);
    }

    // Ensure username
    String ensuredUsername = (username ?? '').trim();
    if (ensuredUsername.isEmpty) {
      final currentMap = await service.getUserMap(token: token, userId: userId);
      // Reuse your tolerant parser (handles nesting and key variants)
      final currentDto = EditUserDto.fromMap(currentMap);
      ensuredUsername = (currentDto.username ?? '').trim();
    }

    if (ensuredUsername.isEmpty) {
      // last-resort fallback
      final slugFirst = firstName.trim().isEmpty ? 'user' : firstName.trim();
      final slugLast = lastName.trim().isEmpty ? 'hs' : lastName.trim();
      ensuredUsername = '${slugFirst}_${slugLast}_$userId'.toLowerCase();
    }

    final fields = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'username': ensuredUsername,
      if (newPassword != null && newPassword.isNotEmpty)
        'newPassword': newPassword,
    };

    await service.putUserMultipartAuth(
      token: token,
      userId: userId,
      fields: fields,
      imagePath: imagePath,
    );
  }

  @override
  Future<void> deleteProfileImage({
    required String token,
    required int userId,
  }) {
    return service.deleteProfileImage(token: token, userId: userId);
  }

  @override
  Future<void> deleteAccount({
    required String token,
    required int userId,
    required String password,
  }) {
    return service.deleteAccount(
      token: token,
      userId: userId,
      password: password,
    );
  }
}
