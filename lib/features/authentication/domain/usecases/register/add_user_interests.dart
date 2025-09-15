import '../../repositories/registration_repository.dart';

class AddUserInterests {
  final RegistrationRepository repo;
  AddUserInterests(this.repo);
  Future<void> call(int userId, List<int> ids) =>
      repo.addUserInterests(userId, ids);
}
