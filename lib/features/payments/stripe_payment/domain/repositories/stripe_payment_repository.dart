// lib/features/payments/stripe_payment/domain/repositories/stripe_payment_repository.dart

import '../entities/payment_intent_result.dart'; // entity

// Abstraction for creating a payment intent on your backend
abstract class StripePaymentRepository {
  // asks backend to create PI with commission, returns secret + id
  Future<PaymentIntentResult> createPaymentIntent({
    required num amount, // total price (per person * participants)
    required String currency, // 'usd' | 'eur' | 'cad'...
    required String accountId, // connected account id of the business
  });
}
