// contract: how UI/domain asks for a payment intent
import '../entities/payment_intent_result.dart'; // result entity

abstract class StripePaymentRepository {
  // create a PaymentIntent on backend and return secret + id
  Future<PaymentIntentResult> createPaymentIntent({
    required num amount, // total amount (your backend handles minor units)
    required String currency, // 'usd' | 'eur' | 'cad' (lowercase)
    required String accountId, // connected Stripe account id (acct_...)
    String? bearerToken, // optional "Bearer xxx" to auth on server
  });
}
