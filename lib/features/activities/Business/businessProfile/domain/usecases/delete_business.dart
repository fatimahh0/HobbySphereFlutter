import '../repositories/business_repository.dart';

class DeleteBusiness {
  final BusinessRepository repository;
  DeleteBusiness(this.repository);

  Future<void> call(String token, int id, String password) {
    return repository.deleteBusiness(token, id, password);
  }
}
