import 'package:dio/dio.dart';
import '../../../../../../core/network/globals.dart' as g;

class BusinessService {
  final Dio _dio = g.appDio!;

  // Ensure we hit /api even if baseUrl lacks it; avoid double /api if it has it.
  String _p(String raw) {
    final base = Uri.parse(_dio.options.baseUrl);
    final baseHasApi = base.pathSegments.contains('api');
    final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
    final withApi = baseHasApi ? cleaned : 'api/$cleaned';
    // IMPORTANT: return a relative path (no leading slash) so Dio appends to baseUrl.
    return withApi;
  }

  Future<Map<String, dynamic>> getBusinessById(String token, int id) async {
    final res = await _dio.get(
      _p('businesses/$id'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<void> updateVisibility(String token, int id, bool isPublic) async {
    await _dio.put(
      _p('businesses/$id/visibility'),
      data: {"isPublicProfile": isPublic},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) async {
    await _dio.put(
      _p('businesses/$id/status'),
      data: {"status": status, if (password != null) "password": password},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> deleteBusiness(String token, int id, String password) async {
    await _dio.delete(
      _p('businesses/$id'),
      data: {"password": password},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<bool> checkStripeStatus(String token, int id) async {
    final res = await _dio.get(
      _p('businesses/$id/stripe-status'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = res.data;
    if (data is Map && data['stripeConnected'] is bool) {
      return data['stripeConnected'] as bool;
    }
    return false;
  }
}
