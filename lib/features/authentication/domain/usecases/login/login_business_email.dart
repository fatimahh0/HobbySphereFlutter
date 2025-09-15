import '../../entities/auth_result.dart';
import '../../repositories/auth_repository.dart';

class LoginBusinessWithEmail {
  final AuthRepository repo;
  LoginBusinessWithEmail(this.repo);
  Future<AuthResult> call(String email, String password) =>
      repo.loginBusinessWithEmail(email: email, password: password);
}
