// lib/features/payments/stripe_payment/presentation/helpers/stripe_sheet.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeSheet {
  static Future<bool> present({
    required String clientSecret, // from backend
    String merchantDisplayName = 'HobbySphere', // shown to user
  }) async {
    if (clientSecret.trim().isEmpty) {
      if (kDebugMode) debugPrint('[StripeSheet] empty clientSecret');
      throw Exception('Empty client secret');
    }

    try {
      if (kDebugMode) debugPrint('[StripeSheet] initPaymentSheet()');
      // make sure settings are applied (safe to call again)
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret, // pass client secret
          merchantDisplayName: merchantDisplayName, // display name
          // NOTE: do NOT enable GPay/ApplePay until init works
        ),
      );
      if (kDebugMode) debugPrint('[StripeSheet] presentPaymentSheet()');

      await Stripe.instance.presentPaymentSheet();
      if (kDebugMode) debugPrint('[StripeSheet] success');
      return true;
    } on PlatformException catch (e) {
      // this prints the real native reason
      debugPrint(
        '[StripeSheet] PlatformException code=${e.code} msg=${e.message} details=${e.details}',
      );
      return false;
    } on StripeException catch (e) {
      debugPrint(
        '[StripeSheet] StripeException ${e.error.code} ${e.error.message}',
      );
      return false;
    } catch (e) {
      debugPrint('[StripeSheet] unexpected: $e');
      return false;
    }
  }
}
