import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../models/business_model.dart';
import '../services/business_service.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessService service;
  BusinessRepositoryImpl(this.service);

  @override
  Future<Business> getBusinessById(String token, int id) async {
    final json = await service.getBusinessById(token, id);
    return BusinessModel.fromJson(json);
  }

  @override
  Future<void> updateVisibility(String token, int id, bool isPublic) =>
      service.updateVisibility(token, id, isPublic);

  @override
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) => service.updateStatus(token, id, status, password: password);

  @override
  Future<void> deleteBusiness(String token, int id, String password) =>
      service.deleteBusiness(token, id, password);

  @override
  Future<bool> checkStripeStatus(String token, int id) =>
      service.checkStripeStatus(token, id);
}
