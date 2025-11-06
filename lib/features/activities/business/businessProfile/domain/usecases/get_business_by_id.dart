import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetBusinessById {
  final BusinessRepository repository;
  GetBusinessById(this.repository);

  Future<Business> call(String token, int id) {
    return repository.getBusinessById(token, id);
  }
}
