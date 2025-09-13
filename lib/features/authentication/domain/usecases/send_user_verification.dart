import '../repositories/registration_repository.dart';

class SendUserVerification {
  final RegistrationRepository repo;
  SendUserVerification(this.repo);
  Future<void> call({String? email, String? phone, required String password}) =>
      repo.sendUserVerification(email: email, phone: phone, password: password);
}
