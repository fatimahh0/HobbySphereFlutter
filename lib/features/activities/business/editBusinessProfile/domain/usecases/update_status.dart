// domain/usecases/update_status.dart
import '../repositories/edit_business_repository.dart';

class UpdateStatus {
  final EditBusinessRepository repo;
  UpdateStatus(this.repo);

  Future<void> call(String token, int id, String status, {String? password}) {
    return repo.updateStatus(token, id, status, password: password);
  }
}
