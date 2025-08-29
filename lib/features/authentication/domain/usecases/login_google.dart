import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle {
  final AuthRepository repo;
  LoginWithGoogle(this.repo);
  Future<AuthResult> call(String idToken) =>
      repo.loginWithGoogle(idToken: idToken);
}
