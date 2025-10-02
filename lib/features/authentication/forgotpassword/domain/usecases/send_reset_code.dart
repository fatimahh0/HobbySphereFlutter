// Simple use case that calls repository to send a reset code.


import 'package:hobby_sphere/features/authentication/forgotpassword/domain/reposotories/forgot_repository.dart';

class SendResetCode {
  // hold repo ref
  final ForgotRepository repo; // repository
  SendResetCode(this.repo); // constructor

  // run with email + role
  Future<SimpleMsg> call(String email, {required bool isBusiness}) {
    // forward to repo
    return repo.sendResetCode(email: email, isBusiness: isBusiness); // pass-through
  }
}
