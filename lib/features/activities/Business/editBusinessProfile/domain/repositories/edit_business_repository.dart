import '../entities/business.dart';

abstract class EditBusinessRepository {
  Future<Business> getBusinessById(String token, int id);

  Future<void> updateBusiness(
    String token,
    int id,
    Map<String, dynamic> body, {
    bool withImages = false,
  });

  Future<void> deleteBusiness(String token, int id, String password);

  Future<void> deleteLogo(String token, int id);

  Future<void> deleteBanner(String token, int id);

  Future<void> updateVisibility(String token, int id, bool isPublic);

  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  });
}
