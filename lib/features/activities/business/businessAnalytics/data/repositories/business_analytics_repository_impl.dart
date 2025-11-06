import '../../domain/entities/business_analytics.dart';
import '../../domain/repositories/business_analytics_repository.dart';
import '../models/business_analytics_model.dart';
import '../services/business_analytics_service.dart';

class BusinessAnalyticsRepositoryImpl implements BusinessAnalyticsRepository {
  final BusinessAnalyticsService service;
  BusinessAnalyticsRepositoryImpl(this.service);

  @override
  Future<BusinessAnalytics> getBusinessAnalytics(
    String token,
    int businessId,
  ) async {
    final json = await service.getBusinessAnalytics(
      token: token,
      id: businessId,
    );
    return BusinessAnalyticsModel.fromJson(json);
  }
}
