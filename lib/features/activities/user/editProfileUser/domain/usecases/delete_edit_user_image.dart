import '../repositories/edit_user_repository.dart';

class DeleteEditUserImage {
  final EditUserRepository repo;
  DeleteEditUserImage(this.repo);

  Future<void> call(String token, int userId) =>
      repo.deleteProfileImage(token: token, userId: userId);
}
