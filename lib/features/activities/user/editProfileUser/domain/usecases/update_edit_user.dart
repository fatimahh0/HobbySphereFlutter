import '../repositories/edit_user_repository.dart';

class UpdateEditUser {
  final EditUserRepository repo;
  UpdateEditUser(this.repo);

  Future<void> call({
    required String token,
    required int userId,
    required String firstName,
    required String lastName,
    String? username,
    String? email,
    String? phoneNumber,
    String? newPassword,
    String? imagePath,
    bool removeImage = false,
  }) {
    return repo.updateProfile(
      token: token,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      newPassword: newPassword,
      imagePath: imagePath,
      removeImage: removeImage,
    );
  }
}
