import '../../entities/auth_result.dart';
import '../../repositories/auth_repository.dart';

class LoginBusinessWithPhone {
  final AuthRepository repo;
  LoginBusinessWithPhone(this.repo);
  Future<AuthResult> call(String phone, String password) =>
      repo.loginBusinessWithPhone(phoneNumber: phone, password: password);
}
