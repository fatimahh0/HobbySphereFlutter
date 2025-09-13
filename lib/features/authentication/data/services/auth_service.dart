// Dio calls only. Map in/out only. Keep neutral and small.
import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class AuthService {
  final _fetch = ApiFetch(); // shared wrapper
  static const _base = '/auth'; // base path

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _fetch.fetch(
        // send
        HttpMethod.post,
        path,
        data: body,
        headers: headers,
      );
      final data =
          (res.data is Map) // normalize to Map
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};
      data['_status'] = res.statusCode ?? 200; // add status
      return data; // ok map
    } on DioException catch (e) {
      final data = (e.response?.data is Map)
          ? Map<String, dynamic>.from(e.response!.data)
          : <String, dynamic>{};
      data['error'] =
          data['error'] ?? e.message ?? 'Request failed'; // add error
      data['_status'] = e.response?.statusCode ?? 0; // status
      return data; // error map (no throw)
    } catch (e) {
      return {'_status': 0, 'error': 'Unexpected: $e'}; // last guard
    }
  }

  // ---------- USER ----------
  Future<Map<String, dynamic>> loginUserEmail({
    required String email,
    required String password,
  }) => _post('$_base/user/login', {
    'email': email.trim(), // backend expects Users model
    'passwordHash': password, // field name is passwordHash
  });

  Future<Map<String, dynamic>> loginUserPhone({
    required String phoneNumber,
    required String password,
  }) => _post('$_base/user/login-phone', {
    'phoneNumber': phoneNumber, // phone
    'passwordHash': password, // field name
  });

  // ---------- BUSINESS ----------
  Future<Map<String, dynamic>> loginBusinessEmail({
    required String email,
    required String password,
  }) => _post('$_base/business/login', {
    'email': email.trim(), // business login
    'passwordHash': password, // field name
  });

  Future<Map<String, dynamic>> loginBusinessPhone({
    required String phoneNumber,
    required String password,
  }) => _post('$_base/business/login-phone', {
    'phoneNumber': phoneNumber, // phone
    'passwordHash': password, // field name
  });

  // ---------- GOOGLE (optional) ----------
  Future<Map<String, dynamic>> loginGoogle(String idToken) =>
      _post('$_base/google', {'idToken': idToken}); // idToken

  // ---------- REACTIVATE ----------
  Future<Map<String, dynamic>> reactivateUser(int id) =>
      _post('$_base/reactivate', {'id': id}); // user reactivate

  Future<Map<String, dynamic>> reactivateBusiness(int id) =>
      _post('$_base/business/reactivate', {'id': id}); // business reactivate
}
