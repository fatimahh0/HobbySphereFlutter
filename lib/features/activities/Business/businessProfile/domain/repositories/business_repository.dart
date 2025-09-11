// domain/repositories/business_repository.dart
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<Business> getBusinessById(String token, int id);
  Future<void> updateVisibility(String token, int id, bool isPublic);
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  });
  Future<void> deleteBusiness(String token, int id, String password);
  Future<bool> checkStripeStatus(String token, int id);
}
