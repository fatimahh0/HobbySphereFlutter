import '../../entities/auth_result.dart';
import '../../repositories/auth_repository.dart';

class LoginUserWithEmail {
  final AuthRepository repo; // dependency
  LoginUserWithEmail(this.repo); // inject repo
  Future<AuthResult> call(String email, String password) =>
      repo.loginUserWithEmail(email: email, password: password); // forward
}
