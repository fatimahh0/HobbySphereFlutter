import '../repositories/business_repository.dart';

class CheckStripeStatus {
  final BusinessRepository repository;
  CheckStripeStatus(this.repository);

  Future<bool> call(String token, int id) {
    return repository.checkStripeStatus(token, id);
  }
}
