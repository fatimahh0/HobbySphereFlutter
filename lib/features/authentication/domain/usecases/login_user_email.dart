import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUserWithEmail {
  final AuthRepository repo;
  LoginUserWithEmail(this.repo);
  Future<AuthResult> call(String email, String password) =>
      repo.loginUserWithEmail(email: email, password: password);
}
