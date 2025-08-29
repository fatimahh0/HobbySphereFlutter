import '../entities/business_activity.dart';

abstract class BusinessActivityRepository {
  Future<List<BusinessActivity>> getActivitiesByBusiness({
    required int businessId,
    required String token,
  });

  Future<BusinessActivity> getById({
    required String token,
    required int id,
  });

  Future<void> delete({
    required String token,
    required int id,
  });
}
