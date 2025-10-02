

import 'package:hobby_sphere/features/authentication/forgotpassword/domain/reposotories/forgot_repository.dart';

class VerifyResetCode {
  // repo ref
  final ForgotRepository repo; // repository
  VerifyResetCode(this.repo); // constructor

  // run with email + code + role
  Future<SimpleMsg> call(String email, String code, {required bool isBusiness}) {
    // forward to repo
    return repo.verifyResetCode(email: email, code: code, isBusiness: isBusiness); // pass-through
  }
}
