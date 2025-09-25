// raw HTTP calls to your backend
import 'package:dio/dio.dart'; // http client
import 'package:hobby_sphere/core/network/globals.dart' as g; // base url

class StripePaymentService {
  final Dio _dio; // Dio instance
  final String baseUrl; // server root (no /api)

  StripePaymentService({Dio? dio, String? baseUrl})
    : _dio = dio ?? (g.appDio ?? Dio()), // reuse or create Dio
      baseUrl = (baseUrl ?? g.serverRootNoApi()).trim(); // compute base

  String _api(String p) => '$baseUrl/api/payments$p'; // build api path

  Future<Map<String, dynamic>> createIntent({
    required num price, // price to charge
    required String currency, // lowercase currency
    required String accountId, // connected acct id
    String? bearerToken, // "Bearer xxx"
  }) async {
    try {
      // POST /api/payments/create-intent
      final res = await _dio.post(
        _api('/create-intent'), // endpoint
        data: <String, dynamic>{
          'price': price, // price body
          'currency': currency.toLowerCase(), // currency body
          'stripeAccountId': accountId, // account body
        },
        options: Options(
          validateStatus: (s) => s != null && s < 500, // 4xx handled below
          headers: {
            if (bearerToken != null && bearerToken.isNotEmpty)
              'Authorization': bearerToken, // attach auth header
          },
        ),
      );

      // handle non-2xx as app-level error with readable message
      if (res.statusCode != null && res.statusCode! >= 400) {
        final data = res.data; // payload
        final msg =
            (data is Map && data['error'] is String) // try error field
            ? data['error'] as String
            : 'Payment intent failed (HTTP ${res.statusCode}).'; // fallback
        throw DioException(
          requestOptions: res.requestOptions, // req info
          response: res, // full resp
          type: DioExceptionType.badResponse, // kind
          error: msg, // human message
        );
      }

      // success: return map<String,dynamic>
      return (res.data as Map).cast<String, dynamic>(); // cast to map
    } on DioException catch (e) {
      // unwrap server message if any
      final serverMsg = (e.error is String)
          ? e.error
                as String // direct error
          : (e.response?.data is Map
                ? (e.response!.data['error'] ?? e.message) // map.error or msg
                : e.message); // generic msg
      throw Exception(serverMsg ?? 'Failed to create payment intent.'); // throw
    }
  }
}
