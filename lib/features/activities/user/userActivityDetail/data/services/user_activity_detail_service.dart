
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class UserActivityDetailService {
  final Dio _dio;
  final String baseUrl;

  UserActivityDetailService({Dio? dio, String? baseUrl})
    : _dio = dio ?? (g.appDio ?? Dio()),
      baseUrl = (baseUrl ?? g.serverRootNoApi()).trim();

  String _api(String p) => '$baseUrl/api/items$p';

  Future<Map<String, dynamic>> getById(int id) async {
    final res = await _dio.get(_api('/$id'));
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<bool> checkAvailability({
    required int itemId,
    required int participants,
    required String bearerToken,
  }) async {
    final res = await _dio.get(
      _api('/$itemId/check-availability'),
      queryParameters: {'participants': '$participants'},
      options: Options(headers: {'Authorization': bearerToken}),
    );
    return ((res.data as Map)['available'] == true);
  }

  Future<int> confirmBooking({
    required int itemId,
    required int participants,
    required String stripePaymentId,
    required String bearerToken,
  }) async {
    final res = await _dio.post(
      _api('/confirm-booking'),
      data: {
        'itemId': itemId,
        'participants': participants,
        'stripePaymentId': stripePaymentId,
      },
      options: Options(headers: {'Authorization': bearerToken}),
    );
    return ((res.data as Map)['bookingId'] as num).toInt();
  }
}
