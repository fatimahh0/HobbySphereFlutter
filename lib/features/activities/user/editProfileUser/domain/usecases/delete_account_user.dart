import '../repositories/edit_user_repository.dart';

class DeleteAccountUser {
  final EditUserRepository repo;
  DeleteAccountUser(this.repo);

  Future<void> call(String token, int userId, String password) =>
      repo.deleteAccount(token: token, userId: userId, password: password);
}
