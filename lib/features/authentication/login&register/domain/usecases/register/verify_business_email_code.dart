import '../../repositories/registration_repository.dart';

class VerifyBusinessEmailCode {
  final RegistrationRepository repo;
  VerifyBusinessEmailCode(this.repo);
  Future<int> call(String email, String code) =>
      repo.verifyBusinessEmailCode(email, code);
}
