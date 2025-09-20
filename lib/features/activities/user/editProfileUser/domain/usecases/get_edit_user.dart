import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';
import '../repositories/edit_user_repository.dart';

class GetEditUser {
  final EditUserRepository repo;
  GetEditUser(this.repo);

  Future<UserEntity> call(String token, int userId) =>
      repo.getById(token: token, userId: userId);
}
