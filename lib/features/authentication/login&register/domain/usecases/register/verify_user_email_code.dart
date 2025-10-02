import '../../repositories/registration_repository.dart';

class VerifyUserEmailCode {
  final RegistrationRepository repo;
  VerifyUserEmailCode(this.repo);
  Future<int> call(String email, String code) =>
      repo.verifyUserEmailCode(email, code);
}
