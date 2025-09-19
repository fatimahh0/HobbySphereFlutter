// lib/features/payments/stripe_payment/data/repositories/stripe_payment_repository_impl.dart

import '../../domain/entities/payment_intent_result.dart'; // entity
import '../../domain/repositories/stripe_payment_repository.dart'; // contract
import '../services/stripe_payment_service.dart'; // service

// Concrete repository that talks to the service
class StripePaymentRepositoryImpl implements StripePaymentRepository {
  final StripePaymentService svc; // service dep
  StripePaymentRepositoryImpl(this.svc); // inject

  @override
  Future<PaymentIntentResult> createPaymentIntent({
    required num amount, // total
    required String currency, // 'usd' etc.
    required String accountId, // connected account
  }) async {
    // call backend
    final j = await svc.createIntent(
      price: amount, // pass price
      currency: currency, // pass currency
      accountId: accountId, // pass account
    );
    // read fields
    final secret = '${j['clientSecret'] ?? ''}'; // get secret
    final pid = '${j['paymentIntentId'] ?? ''}'; // get intent id
    // create value object
    return PaymentIntentResult(
      clientSecret: secret, // set secret
      paymentIntentId: pid, // set id
    );
  }
}
