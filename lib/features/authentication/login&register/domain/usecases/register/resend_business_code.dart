
import 'package:hobby_sphere/features/authentication/login&register/domain/repositories/registration_repository.dart';


class ResendBusinessCode {
  final RegistrationRepository repo;
  ResendBusinessCode(this.repo);
  Future<void> call(String contact) => repo.resendBusinessCode(contact);
}
