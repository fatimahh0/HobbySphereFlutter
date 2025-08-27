// ===== Flutter 3.35.x =====
// services/auth_service.dart
// Clean + resilient Auth APIs for: user/business login (email/phone),
// Google (optional), and reactivate. Always returns a Map with backend JSON
// and never hides server error messages.

// NOTE: This file assumes you have a Dio wrapper ApiFetch that exposes:
//   Future<Response> fetch(HttpMethod method, String path, {dynamic data})
// If your wrapper throws on non-2xx, we catch that and still extract response.

import 'package:dio/dio.dart'; // to read DioException safely
import 'package:hobby_sphere/core/network/api_fetch.dart'; // your Dio wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod enum

class AuthService {
  // shared HTTP client
  final _fetch = ApiFetch(); // uses baseUrl from ApiClient / ApiConfig
  // base path (your ApiClient baseUrl should already include /api)
  static const _base = '/auth';

  // ---------- small helpers ----------

  // normalize any response (success or error) into a Map<String,dynamic>
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      // do the request
      final res = await _fetch.fetch(
        HttpMethod.post,
        path,
        data: body,
      ); // call API
      final data = res.data; // backend JSON/body
      // ensure we always return a map
      final map = (data is Map)
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      // annotate with status + ok flag
      map.putIfAbsent('_status', () => res.statusCode ?? 200);
      map.putIfAbsent(
        '_ok',
        () => (res.statusCode ?? 200) >= 200 && (res.statusCode ?? 200) < 300,
      );
      return map; // return normalized map
    } on DioException catch (e) {
      // when backend returns 4xx/5xx, Dio may throw. Extract body if present.
      final status = e.response?.statusCode ?? 0; // http status or 0
      final data = e.response?.data; // server body
      final map = (data is Map)
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      // if backend used "message" or "error", keep them; otherwise add readable text
      map.putIfAbsent('message', () => e.message ?? 'Request failed');
      map['_status'] = status; // expose status code
      map['_ok'] = false; // mark as not OK
      return map; // IMPORTANT: return map instead of throwing to keep UX smooth
    } catch (e) {
      // any other unexpected error
      return <String, dynamic>{
        '_status': 0, // unknown
        '_ok': false, // failed
        'message': 'Unexpected error: $e', // readable message
      };
    }
  }

  // ---------- USER LOGIN (EMAIL) ----------
  // POST /api/auth/user/login
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email, // user email
    required String password, // plain password
  }) async {
    // backend expects a Users-like payload with "email" + "passwordHash"
    return _post('$_base/user/login', {
      'email': email, // email string
      'passwordHash': password, // plain is fine; backend encodes/compares
    });
  }

  // ---------- USER LOGIN (PHONE) ----------
  // POST /api/auth/user/login-phone
  Future<Map<String, dynamic>> loginWithPhonePassword({
    required String phoneNumber, // +E.164 like +9617xxxxxx
    required String password, // plain password
  }) async {
    // backend expects "phoneNumber" + "passwordHash"
    return _post('$_base/user/login-phone', {
      'phoneNumber': phoneNumber, // phone
      'passwordHash': password, // password
    });
  }

  // ---------- BUSINESS LOGIN (EMAIL) ----------
  // POST /api/auth/business/login
  Future<Map<String, dynamic>> loginBusiness({
    required String email, // business email
    required String password, // plain password
  }) async {
    // backend reads from a Users-like object too: "email" + "passwordHash"
    return _post('$_base/business/login', {
      'email': email, // email
      'passwordHash': password, // password
    });
  }

  // ---------- BUSINESS LOGIN (PHONE) ----------
  // POST /api/auth/business/login-phone
  Future<Map<String, dynamic>> loginBusinessWithPhone({
    required String phoneNumber, // +E.164 like +9617xxxxxx
    required String password, // plain password
  }) async {
    return _post('$_base/business/login-phone', {
      'phoneNumber': phoneNumber, // phone
      'passwordHash': password, // password
    });
  }

  // ---------- GOOGLE LOGIN (OPTIONAL) ----------
  // POST /api/auth/google
  // IMPORTANT: Your AuthController (shared above) does NOT yet expose this path.
  // Add it server-side first; until then this will likely return 404.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    return _post('$_base/google', {
      'idToken': idToken, // Google ID Token (JWT)
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
  // POST /api/auth/reactivate      (for user)
  // POST /api/auth/business/reactivate  (for business)
  Future<Map<String, dynamic>> reactivateAccount({
    required int id, // entity id (user.id or business.id)
    required String role, // "user" or "business"
  }) async {
    final endpoint = (role == 'user')
        ? '$_base/reactivate' // user endpoint
        : '$_base/business/reactivate'; // business endpoint

    // backend expects body { "id": <Long> }
    return _post(endpoint, {
      'id': id, // pass id
    });
  }
}
