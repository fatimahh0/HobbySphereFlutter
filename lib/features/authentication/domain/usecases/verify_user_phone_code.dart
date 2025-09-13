import '../repositories/registration_repository.dart';

class VerifyUserPhoneCode {
  final RegistrationRepository repo;
  VerifyUserPhoneCode(this.repo);
  Future<int> call(String phone, String code) =>
      repo.verifyUserPhoneCode(phone, code);
}
