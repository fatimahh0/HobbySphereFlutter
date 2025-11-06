// domain/usecases/get_business_by_id.dart
import '../entities/business.dart';
import '../repositories/edit_business_repository.dart';

class GetBusinessById {
  final EditBusinessRepository repo;
  GetBusinessById(this.repo);

  Future<Business> call(String token, int id) {
    return repo.getBusinessById(token, id);
  }
}
