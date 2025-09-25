// typed result for create-intent response
class PaymentIntentResult {
  final String clientSecret; // secret to open Stripe sheet
  final String paymentIntentId; // id to confirm booking later

  const PaymentIntentResult({
    required this.clientSecret, // set secret
    required this.paymentIntentId, // set id
  });
}
