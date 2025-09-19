// lib/features/payments/stripe_payment/domain/entities/payment_intent_result.dart

// Simple value object for the server response
class PaymentIntentResult {
  // secret used by the SDK to present sheet
  final String clientSecret; // client secret from /api/payments/create-intent
  // id used to confirm booking later
  final String paymentIntentId; // payment intent id to send to /confirm-booking

  const PaymentIntentResult({
    required this.clientSecret, // set client secret
    required this.paymentIntentId, // set intent id
  });
}
