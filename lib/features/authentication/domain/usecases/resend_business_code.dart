import '../repositories/registration_repository.dart';

class ResendBusinessCode {
  final RegistrationRepository repo;
  ResendBusinessCode(this.repo);
  Future<void> call(String contact) => repo.resendBusinessCode(contact);
}
