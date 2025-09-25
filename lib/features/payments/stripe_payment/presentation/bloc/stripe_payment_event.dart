// events: what the UI asks the BLoC to do
abstract class StripePaymentEvent {} // base type

class StripeCreateAndPayPressed extends StripePaymentEvent {
  final num amount; // total amount
  final String currency; // stripe currency
  final String accountId; // connected acct
  final String? bearerToken; // "Bearer xxx" or null
  final Future<void> Function(String stripePaymentId) onPaymentSucceeded; // cb

  StripeCreateAndPayPressed({
    required this.amount, // set amount
    required this.currency, // set currency
    required this.accountId, // set account
    required this.onPaymentSucceeded, // set callback
    this.bearerToken, // set token
  });
}
