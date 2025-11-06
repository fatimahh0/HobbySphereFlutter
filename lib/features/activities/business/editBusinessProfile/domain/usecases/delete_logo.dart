// domain/usecases/delete_logo.dart
import '../repositories/edit_business_repository.dart';

class DeleteLogo {
  final EditBusinessRepository repo;
  DeleteLogo(this.repo);

  Future<void> call(String token, int id) {
    return repo.deleteLogo(token, id);
  }
}
