// lib/core/auth/auth_service.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class AuthService {
  final _fetch = ApiFetch(); // uses the shared Dio (with interceptors)
  static const _base = '/auth'; // no leading slash

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.post,
        path,
        data: body,
        headers: headers,
      );
      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};
      data['_status'] = res.statusCode ?? 200;
      return data;
    } on DioException catch (e) {
      final data = (e.response?.data is Map)
          ? Map<String, dynamic>.from(e.response!.data)
          : <String, dynamic>{};
      data['error'] = data['error'] ?? e.message ?? 'Request failed';
      data['_status'] = e.response?.statusCode ?? 0;
      return data;
    } catch (e) {
      return {'_status': 0, 'error': 'Unexpected: $e'};
    }
  }

  // ---------- USER ----------
  Future<Map<String, dynamic>> loginUserEmail({
    required String email,
    required String password,
  }) => _post('$_base/user/login'.replaceFirst('_.', ''), {
    'email': email.trim(),
    'password': password, // backend expects "password"
    'ownerProjectLinkId':
        int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
  });

  Future<Map<String, dynamic>> loginUserPhone({
    required String phoneNumber,
    required String password,
  }) => _post('$_base/user/login-phone'.replaceFirst('_.', ''), {
    'phoneNumber': phoneNumber,
    'password': password,
    'ownerProjectLinkId':
        int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
  });

  // ---------- BUSINESS ----------
  Future<Map<String, dynamic>> loginBusinessEmail({
    required String email,
    required String password,
  }) => _post('$_base/business/login'.replaceFirst('_.', ''), {
    'email': email.trim(),
    'password': password,
    'ownerProjectLinkId':
        int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
  });

  Future<Map<String, dynamic>> loginBusinessPhone({
    required String phoneNumber,
    required String password,
  }) => _post('$_base/business/login-phone'.replaceFirst('_.', ''), {
    'phoneNumber': phoneNumber,
    'password': password,
    'ownerProjectLinkId':
        int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
  });

  // ---------- GOOGLE ----------
  Future<Map<String, dynamic>> loginGoogle(String idToken) =>
      _post('$_base/google'.replaceFirst('_.', ''), {
        'idToken': idToken,
        'ownerProjectLinkId':
            int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
      });

  // ---------- REACTIVATE ----------
  Future<Map<String, dynamic>> reactivateUser(int id) =>
      _post('$_base/reactivate'.replaceFirst('_.', ''), {'id': id});

  Future<Map<String, dynamic>> reactivateBusiness(int id) =>
      _post('$_base/business/reactivate'.replaceFirst('_.', ''), {'id': id});
}
