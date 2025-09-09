import '../entities/business_user.dart';
import '../repositories/business_users_repository.dart';

class GetBusinessUsers {
  final BusinessUsersRepository repo;
  GetBusinessUsers(this.repo);

  Future<List<BusinessUser>> call(String token) {
    return repo.getBusinessUsers(token);
  }
}
