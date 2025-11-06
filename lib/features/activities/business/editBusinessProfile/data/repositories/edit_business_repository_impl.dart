import '../../domain/entities/business.dart';
import '../../domain/repositories/edit_business_repository.dart';
import '../models/business_model.dart';
import '../services/edit_business_service.dart';

class EditBusinessRepositoryImpl implements EditBusinessRepository {
  final EditBusinessService service;
  EditBusinessRepositoryImpl(this.service);

  @override
  Future<Business> getBusinessById(String token, int id) async {
    final json = await service.getBusinessById(token, id);
    return BusinessModel.fromJson(json);
  }

  @override
  Future<void> updateBusiness(
    String token,
    int id,
    Map<String, dynamic> body, {
    bool withImages = false,
  }) {
    return service.updateBusiness(token, id, body, withImages: withImages);
  }

  @override
  Future<void> deleteBusiness(String token, int id, String password) {
    return service.deleteBusiness(token, id, password);
  }

  @override
  Future<void> deleteLogo(String token, int id) {
    return service.deleteLogo(token, id);
  }

  @override
  Future<void> deleteBanner(String token, int id) {
    return service.deleteBanner(token, id);
  }

  @override
  Future<void> updateVisibility(String token, int id, bool isPublic) {
    return service.updateVisibility(token, id, isPublic);
  }

  @override
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) {
    return service.updateStatus(token, id, status, password);
  }
}
