// ===== Flutter 3.35.x / Dart 3.9 =====
// services/auth_service.dart
// Clean Auth API service: user/business login (email/phone), social, reactivate.
// Always returns a Map with keys: _ok (bool) and _status (int).

import 'package:dio/dio.dart'; // HTTP client + DioException
import 'package:hobby_sphere/core/network/api_fetch.dart'; // your Dio wrapper (fetch)
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class AuthService {
  // create one ApiFetch instance (reuses baseUrl from your ApiClient/ApiConfig)
  final _fetch = ApiFetch();

  // base path for auth endpoints (your baseUrl should already include /api)
  static const _base = '/auth';

  // ---------- helpers ----------

  // normalize email: trim spaces (you can add .toLowerCase() if backend ignores case)
  String _normalizeEmail(String email) => email.trim();

  // central POST helper: returns Map for both success and error
  Future<Map<String, dynamic>> _post(
    String path, // endpoint path like /auth/user/login
    Map<String, dynamic> body, // request JSON body
  ) async {
    try {
      // send request using your wrapper (does JSON by default)
      final res = await _fetch.fetch(
        HttpMethod.post, // HTTP method: POST
        path, // endpoint path
        data: body, // JSON body
      );

      // read response data
      final data = res.data;

      // ensure a Map is returned even if server returns non-map
      final map = (data is Map)
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      // add status code if not present
      map.putIfAbsent('_status', () => res.statusCode ?? 200);

      // add ok flag (true if 2xx)
      map.putIfAbsent('_ok', () {
        final code = res.statusCode ?? 200;
        return code >= 200 && code < 300;
      });

      // return normalized map
      return map;
    } on DioException catch (e) {
      // handle HTTP errors (4xx/5xx) thrown by Dio or your wrapper
      final status = e.response?.statusCode ?? 0; // status or 0
      final data = e.response?.data; // server body
      final map = (data is Map)
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      // keep server message if any, else add readable message
      map.putIfAbsent('message', () => e.message ?? 'Request failed');

      // expose status + ok=false
      map['_status'] = status;
      map['_ok'] = false;

      // return error map (do not throw to keep UI flow smooth)
      return map;
    } catch (e) {
      // handle non-HTTP unexpected errors
      return <String, dynamic>{
        '_status': 0, // unknown status
        '_ok': false, // failed
        'message': 'Unexpected error: $e', // readable message
      };
    }
  }

  // ---------- USER LOGIN (EMAIL) ----------
  // POST /api/auth/user/login
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email, // user email (plain)
    required String password, // user password (plain)
  }) async {
    // IMPORTANT: backend expects "password" here (NOT "passwordHash")
    return _post('$_base/user/login', {
      'email': _normalizeEmail(email), // trim spaces
      'password': password, // correct key for email login
    });
  }

  // ---------- USER LOGIN (PHONE) ----------
  // POST /api/auth/user/login-phone
  Future<Map<String, dynamic>> loginWithPhonePassword({
    required String phoneNumber, // +E.164 like +9617xxxxxx
    required String password, // user password (plain)
  }) async {
    // Your backend expects "passwordHash" for phone login (keep as-is)
    return _post('$_base/user/login-phone', {
      'phoneNumber': phoneNumber, // phone input
      'passwordHash': password, // backend reads this field on phone login
    });
  }

  // ---------- BUSINESS LOGIN (EMAIL) ----------
  // POST /api/auth/business/login
  Future<Map<String, dynamic>> loginBusiness({
    required String email, // business email (plain)
    required String password, // business password (plain)
  }) async {
    // IMPORTANT: backend expects "password" here (NOT "passwordHash")
    return _post('$_base/business/login', {
      'email': _normalizeEmail(email), // trim spaces
      'password': password, // correct key for email login
    });
  }

  // ---------- BUSINESS LOGIN (PHONE) ----------
  // POST /api/auth/business/login-phone
  Future<Map<String, dynamic>> loginBusinessWithPhone({
    required String phoneNumber, // +E.164 like +9617xxxxxx
    required String password, // business password (plain)
  }) async {
    // Your backend expects "passwordHash" for phone login (keep as-is)
    return _post('$_base/business/login-phone', {
      'phoneNumber': phoneNumber, // phone input
      'passwordHash': password, // backend reads this field on phone login
    });
  }

  // ---------- GOOGLE LOGIN (OPTIONAL) ----------
  // POST /api/auth/google
  // Note: Ensure backend endpoint exists; otherwise you get 404.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    return _post('$_base/google', {
      'idToken': idToken, // Google ID token (JWT)
    });
  }

  // ---------- FACEBOOK LOGIN (OPTIONAL) ----------
  // POST /api/auth/facebook/login
  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    return _post('$_base/facebook/login', {
      'accessToken': accessToken, // Facebook access token
    });
  }

  // ---------- REACTIVATE (USER or BUSINESS) ----------
  // POST /api/auth/reactivate              (user)
  // POST /api/auth/business/reactivate     (business)
  Future<Map<String, dynamic>> reactivateAccount({
    required int id, // user.id or business.id
    required String role, // 'user' or 'business'
  }) async {
    // choose endpoint based on role
    final endpoint = (role == 'user')
        ? '$_base/reactivate'
        : '$_base/business/reactivate';

    // backend expects { "id": <Long> }
    return _post(endpoint, {
      'id': id, // pass id
    });
  }
}
