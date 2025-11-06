import '../entities/business_activity.dart';
import '../repositories/business_activity_repository.dart';

class GetBusinessActivities {
  final BusinessActivityRepository repo;
  GetBusinessActivities(this.repo);

  Future<List<BusinessActivity>> call({
    required int businessId,
    required String token,
  }) {
    return repo.getActivitiesByBusiness(businessId: businessId, token: token);
  }
}
