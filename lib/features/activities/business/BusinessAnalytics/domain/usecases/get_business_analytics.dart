import '../entities/business_analytics.dart';
import '../repositories/business_analytics_repository.dart';

class GetBusinessAnalytics {
  final BusinessAnalyticsRepository repository;
  GetBusinessAnalytics(this.repository);

  Future<BusinessAnalytics> call(String token, int businessId) {
    return repository.getBusinessAnalytics(token, businessId);
  }
}
