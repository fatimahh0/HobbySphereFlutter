import '../repositories/business_repository.dart';

class UpdateBusinessStatus {
  final BusinessRepository repository;
  UpdateBusinessStatus(this.repository);

  Future<void> call(String token, int id, String status, {String? password}) {
    return repository.updateStatus(token, id, status, password: password);
  }
}
