// lib/features/payments/stripe_payment/domain/usecases/create_payment_intent.dart

import '../entities/payment_intent_result.dart'; // entity
import '../repositories/stripe_payment_repository.dart'; // repo

// Use case: call repo to create PI
class CreatePaymentIntent {
  final StripePaymentRepository repo; // dependency
  const CreatePaymentIntent(this.repo); // inject

  // forward call to repository
  Future<PaymentIntentResult> call({
    required num amount, // price total
    required String currency, // 'usd' | 'eur' | 'cad'
    required String accountId, // connected account
  }) {
    return repo.createPaymentIntent(
      amount: amount, // pass amount
      currency: currency, // pass currency
      accountId: accountId, // pass account
    );
  }
}
