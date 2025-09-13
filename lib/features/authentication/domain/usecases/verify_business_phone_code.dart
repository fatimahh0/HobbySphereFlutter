import '../repositories/registration_repository.dart';

class VerifyBusinessPhoneCode {
  final RegistrationRepository repo;
  VerifyBusinessPhoneCode(this.repo);
  Future<int> call(String phone, String code) =>
      repo.verifyBusinessPhoneCode(phone, code);
}
