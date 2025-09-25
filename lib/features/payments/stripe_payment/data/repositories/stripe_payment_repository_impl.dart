// repository implementation: calls the HTTP service
import '../../domain/entities/payment_intent_result.dart'; // entity
import '../../domain/repositories/stripe_payment_repository.dart'; // contract
import '../services/stripe_payment_service.dart'; // http svc

class StripePaymentRepositoryImpl implements StripePaymentRepository {
  final StripePaymentService svc; // hold service
  StripePaymentRepositoryImpl(this.svc); // inject service

  @override
  Future<PaymentIntentResult> createPaymentIntent({
    required num amount, // total
    required String currency, // 'usd' etc.
    required String accountId, // connected acct
    String? bearerToken, // optional auth
  }) async {
    // call backend to create intent
    final j = await svc.createIntent(
      price: amount, // send amount
      currency: currency, // send currency
      accountId: accountId, // send account
      bearerToken: bearerToken, // send token if any
    );
    // read fields from response
    final secret = '${j['clientSecret'] ?? ''}'; // client secret
    final pid = '${j['paymentIntentId'] ?? ''}'; // payment intent id
    // return typed result
    return PaymentIntentResult(
      clientSecret: secret, // set secret
      paymentIntentId: pid, // set id
    );
  }
}
