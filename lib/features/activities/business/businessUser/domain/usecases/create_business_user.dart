import '../entities/business_user.dart';
import '../repositories/business_users_repository.dart';

class CreateBusinessUser {
  final BusinessUsersRepository repo;
  CreateBusinessUser(this.repo);

  Future<BusinessUser> call(
    String token, {
    required String firstname,
    required String lastname,
    String? email,
    String? phoneNumber,
  }) {
    return repo.createBusinessUser(
      token,
      firstname: firstname,
      lastname: lastname,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}
