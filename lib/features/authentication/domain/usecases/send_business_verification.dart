import '../repositories/registration_repository.dart';

class SendBusinessVerification {
  final RegistrationRepository repo;
  SendBusinessVerification(this.repo);
  Future<int> call({String? email, String? phone, required String password}) =>
      repo.sendBusinessVerification(
        email: email,
        phone: phone,
        password: password,
      );
}
