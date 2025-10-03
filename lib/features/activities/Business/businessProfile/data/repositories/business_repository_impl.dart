// Flutter 3.35.x
// Business repository implementation.

import '../../domain/entities/business.dart'; // entity
import '../../domain/repositories/business_repository.dart'; // contract
import '../models/business_model.dart'; // model
import '../services/business_service.dart'; // service

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessService service; // http service
  BusinessRepositoryImpl(this.service); // ctor

  @override
  Future<Business> getBusinessById(String token, int id) async {
    final json = await service.getBusinessById(token, id); // call
    return BusinessModel.fromJson(json); // map
  }

  @override
  Future<void> updateVisibility(String token, int id, bool isPublic) =>
      service.updateVisibility(token, id, isPublic); // forward

  @override
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) => service.updateStatus(token, id, status, password: password); // forward

  @override
  Future<void> deleteBusiness(String token, int id, String password) =>
      service.deleteBusiness(token, id, password); // forward

  @override
  Future<bool> checkStripeStatus(String token, int id) =>
      service.checkStripeStatus(token, id); // forward

  @override
  Future<String> createStripeConnectLink(String token, int id) =>
      service.createStripeConnectLink(token, id); // NEW forward
}
