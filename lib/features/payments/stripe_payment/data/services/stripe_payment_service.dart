// lib/features/payments/stripe_payment/data/services/stripe_payment_service.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class StripePaymentService {
  final Dio _dio;
  final String baseUrl;

  StripePaymentService({Dio? dio, String? baseUrl})
    : _dio = dio ?? (g.appDio ?? Dio()),
      baseUrl = (baseUrl ?? g.serverRootNoApi()).trim();

  String _api(String p) => '$baseUrl/api/payments$p';

  Future<Map<String, dynamic>> createIntent({
    required num price,
    required String currency, // e.g. "cad", "usd"
    required String accountId, // connected acct_...
    String? bearerToken, // optional "Bearer xxx"
  }) async {
    try {
      final res = await _dio.post(
        _api('/create-intent'),
        data: <String, dynamic>{
          'price': price,
          'currency': currency.toLowerCase(),
          'stripeAccountId': accountId,
        },
        options: Options(
          validateStatus: (s) => s != null && s < 500,
          headers: {
            if (bearerToken != null && bearerToken.isNotEmpty)
              'Authorization': bearerToken,
          },
        ),
      );

      if (res.statusCode != null && res.statusCode! >= 400) {
        final data = res.data;
        final msg = (data is Map && data['error'] is String)
            ? data['error'] as String
            : 'Payment intent failed (HTTP ${res.statusCode}).';

        // Build the DioException with `error:` in the constructor.
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: msg,
        );
      }

      return (res.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      final serverMsg = (e.error is String)
          ? e.error as String
          : (e.response?.data is Map
                ? (e.response!.data['error'] ?? e.message)
                : e.message);
      throw Exception(serverMsg ?? 'Failed to create payment intent.');
    }
  }
}
