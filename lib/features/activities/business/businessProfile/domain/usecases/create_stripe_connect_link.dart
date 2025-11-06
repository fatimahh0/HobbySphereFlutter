// Flutter 3.35.x
// Usecase to request Stripe onboarding URL from repository.

import '../repositories/business_repository.dart'; // repo

class CreateStripeConnectLink {
  final BusinessRepository repository; // dependency
  CreateStripeConnectLink(this.repository); // ctor

  Future<String> call(String token, int businessId) {
    return repository.createStripeConnectLink(token, businessId); // delegate
  }
}
