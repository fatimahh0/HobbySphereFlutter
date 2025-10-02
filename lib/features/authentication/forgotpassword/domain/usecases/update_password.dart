
import 'package:hobby_sphere/features/authentication/forgotpassword/domain/reposotories/forgot_repository.dart';


class UpdatePassword {
  // repo ref
  final ForgotRepository repo; // repository
  UpdatePassword(this.repo); // constructor

  // run with email + newPassword + role
  Future<SimpleMsg> call(String email, String newPassword, {required bool isBusiness}) {
    // forward to repo
    return repo.updatePassword(email: email, newPassword: newPassword, isBusiness: isBusiness); // pass-through
  }
}
