/// Base type for payment events.
abstract class StripePaymentEvent {}

/// Create a PaymentIntent, present the sheet, then call onPaymentSucceeded.
class StripeCreateAndPayPressed extends StripePaymentEvent {
  final num amount; // total amount (your backend handles minor units)
  final String currency; // 'usd' | 'eur' | 'cad' etc (lowercase)
  final String accountId; // connected account id (if used)
  final Future<void> Function(String stripePaymentId) onPaymentSucceeded;

  StripeCreateAndPayPressed({
    required this.amount,
    required this.currency,
    required this.accountId,
    required this.onPaymentSucceeded,
  });
}
