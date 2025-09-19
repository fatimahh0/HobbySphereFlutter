import 'package:flutter_stripe/flutter_stripe.dart';

class StripeSheet {
  static Future<bool> present({
    required String clientSecret,
    String merchantDisplayName = 'HobbySphere',
  }) async {
    // Init
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantDisplayName,
      ),
    );

    // Present
    try {
      await Stripe.instance.presentPaymentSheet();
      return true; // paid
    } on StripeException {
      return false; // cancelled / stripe-handled error
    } catch (_) {
      return false; // unexpected
    }
  }
}
