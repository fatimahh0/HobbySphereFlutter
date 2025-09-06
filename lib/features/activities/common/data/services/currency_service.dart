// lib/features/activities/common/data/services/currency_service.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class CurrencyService {
  final _fetch = ApiFetch();
  static const _base = '/currencies';

  Future<String> getCurrentCurrency(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/current',
      headers: {'Authorization': 'Bearer $token'},
      responseType: ResponseType.plain, // force raw string response
    );

    // Example: res.data = "CAD"
    return res.data.toString().replaceAll('"', '').trim();
  }
}
