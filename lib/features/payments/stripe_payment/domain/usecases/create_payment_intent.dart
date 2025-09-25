// use case: the app asks here; we forward to repository
import '../entities/payment_intent_result.dart'; // result entity
import '../repositories/stripe_payment_repository.dart'; // repo contract

class CreatePaymentIntent {
  final StripePaymentRepository repo; // dependency on repo
  const CreatePaymentIntent(this.repo); // inject via constructor

  Future<PaymentIntentResult> call({
    required num amount, // total to charge
    required String currency, // currency code
    required String accountId, // connected account id
    String? bearerToken, // optional auth header
  }) {
    // forward everything to repo
    return repo.createPaymentIntent(
      amount: amount, // pass amount
      currency: currency, // pass currency
      accountId: accountId, // pass account
      bearerToken: bearerToken, // pass token
    );
  }
}
