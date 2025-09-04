import '../repositories/business_repository.dart';

class UpdateBusinessVisibility {
  final BusinessRepository repository;
  UpdateBusinessVisibility(this.repository);

  Future<void> call(String token, int id, bool isPublic) {
    return repository.updateVisibility(token, id, isPublic);
  }
}
