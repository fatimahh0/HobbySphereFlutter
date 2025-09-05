// domain/usecases/delete_business.dart
import '../repositories/edit_business_repository.dart';

class DeleteBusiness {
  final EditBusinessRepository repo;
  DeleteBusiness(this.repo);

  Future<void> call(String token, int id, String password) {
    return repo.deleteBusiness(token, id, password);
  }
}
