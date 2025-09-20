import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';

abstract class EditUserRepository {
  Future<UserEntity> getById({required String token, required int userId});

  Future<void> updateProfile({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    String? username,
    String? email, // either email OR phoneNumber
    String? phoneNumber, // (server should accept one of them)
    String? newPassword, // optional
    String? imagePath, // local file to upload
    bool removeImage = false,
  });

  Future<void> deleteProfileImage({required String token, required int userId});

  Future<void> deleteAccount({
    required String token,
    required int userId,
    required String password,
  });
}
