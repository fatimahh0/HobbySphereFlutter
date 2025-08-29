import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUserWithPhone {
  final AuthRepository repo;
  LoginUserWithPhone(this.repo);
  Future<AuthResult> call(String phone, String password) =>
      repo.loginUserWithPhone(phoneNumber: phone, password: password);
}
