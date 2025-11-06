import '../entities/business_analytics.dart';

abstract class BusinessAnalyticsRepository {
  Future<BusinessAnalytics> getBusinessAnalytics(String token, int businessId);
}
