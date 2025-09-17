import '../entities/user_activity_detail_entity.dart';
import '../repositories/user_activity_detail_repository.dart';

class GetUserActivityDetail {
  final UserActivityDetailRepository repo;
  const GetUserActivityDetail(this.repo);
  Future<UserActivityDetailEntity> call(int id) => repo.getById(id);
}
