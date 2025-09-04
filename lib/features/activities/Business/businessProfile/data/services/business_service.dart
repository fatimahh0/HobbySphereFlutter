import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/network/globals.dart' as g;

class BusinessService {
  final Dio _dio = g.appDio!;

  Future<Map<String, dynamic>> getBusinessById(String token, int id) async {
    final res = await _dio.get(
      '/businesses/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data;
  }

  Future<void> updateVisibility(String token, int id, bool isPublic) async {
    await _dio.put(
      '/businesses/$id/visibility',
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
      '/businesses/$id/status',
      data: {"status": status, if (password != null) "password": password},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> deleteBusiness(String token, int id, String password) async {
    await _dio.delete(
      '/businesses/$id',
      data: {"password": password},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<bool> checkStripeStatus(String token, int id) async {
    final res = await _dio.get(
      '/businesses/$id/stripe-status',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return res.data['stripeConnected'] ?? false;
  }
}

