import '../entities/business_activity.dart';
import '../repositories/business_activity_repository.dart';

class GetBusinessActivityById {
  final BusinessActivityRepository repo;
  GetBusinessActivityById(this.repo);

  Future<BusinessActivity> call({
    required String token,
    required int id,
  }) {
    return repo.getById(token: token, id: id);
  }
}
