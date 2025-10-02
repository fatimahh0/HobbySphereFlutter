import '../../repositories/registration_repository.dart';

class ResendUserCode {
  final RegistrationRepository repo;
  ResendUserCode(this.repo);
  Future<void> call(String contact) => repo.resendUserCode(contact);
}
