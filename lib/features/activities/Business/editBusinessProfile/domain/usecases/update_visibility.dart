// domain/usecases/update_visibility.dart
import '../repositories/edit_business_repository.dart';

class UpdateVisibility {
  final EditBusinessRepository repo;
  UpdateVisibility(this.repo);

  Future<void> call(String token, int id, bool isPublic) {
    return repo.updateVisibility(token, id, isPublic);
  }
}
