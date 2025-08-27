// ===== Flutter 3.35.x =====
// services/stripe_service.dart
// Stripe API: create PaymentIntent (with connected account support).

import 'package:hobby_sphere/core/network/api_fetch.dart'; // Dio wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // POST

class StripeService {
  final _fetch = ApiFetch(); // shared Dio client
  static const _base = '/payments'; // base path (/api already in baseUrl)

  // ------------------------------------------------------------
  // POST /api/payments/create-intent
  Future<Map<String, String>> createPaymentIntent({
    required double price, // amount
    required String currency, // e.g. "usd"
    required String stripeAccountId, // connected account id
  }) async {
    final body = {
      'price': price,
      'currency': currency,
      'stripeAccountId': stripeAccountId,
    };

    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/create-intent', // endpoint
      data: body, // JSON body
      headers: {'Content-Type': 'application/json'}, // header
    );

    final data = res.data;

    // validate response: must contain both clientSecret + paymentIntentId
    if (data is! Map ||
        !data.containsKey('clientSecret') ||
        !data.containsKey('paymentIntentId')) {
      throw Exception(data['error'] ?? 'Failed to create payment intent');
    }

    return {
      'clientSecret': data['clientSecret'].toString(),
      'paymentIntentId': data['paymentIntentId'].toString(),
    };
  }
}
