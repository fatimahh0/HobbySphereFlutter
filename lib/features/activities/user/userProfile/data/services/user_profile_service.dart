// === Low-level HTTP service (Dio) ===
import 'package:dio/dio.dart'; // HTTP client
import 'package:hobby_sphere/core/network/globals.dart' as g; // global Dio/base

class UserProfileService {
  final Dio _dio = g.appDio!; // shared Dio
  String get _base => '${g.appServerRoot}/users'; // /api/users

  // GET /api/users/{id}
  Future<Map<String, dynamic>> fetchProfileMap({
    required String token, // bearer
    required int userId, // id
  }) async {
    final res = await _dio.get(
      // do GET
      '$_base/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}), // auth
    );
    return (res.data as Map).cast<String, dynamic>(); // normalize map
  }

  // PUT /api/users/profile-visibility?isPublic=true|false
  Future<void> updateVisibility({
    required String token,
    required bool isPublic,
  }) async {
    await _dio.put(
      '$_base/profile-visibility',
      queryParameters: {'isPublic': isPublic},
      // 👇 important: backend returns text, not JSON
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // <- do NOT parse as JSON
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );
  }

  // PUT /api/users/{id}/status  body:{status, password?}
  Future<void> updateStatus({
    required String token,
    required int userId,
    required String status,
    String? password,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (status.toUpperCase() == 'INACTIVE' && (password?.isNotEmpty ?? false)) {
      body['password'] = password;
    }

    await _dio.put(
      '$_base/$userId/status',
      data: body,
      // 👇 same here: treat as plain text
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // <- avoid JSON decoding
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );
  }
}
