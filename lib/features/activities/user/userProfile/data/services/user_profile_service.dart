// === Low-level HTTP service (Dio) ===
import 'package:dio/dio.dart'; // HTTP client
import 'package:hobby_sphere/core/network/globals.dart' as g; // global Dio/base
import 'package:hobby_sphere/config/env.dart'; // <-- for ownerProjectLinkId

class UserProfileService {
  final Dio _dio = g.appDio!; // shared Dio
  String get _base => '${g.appServerRoot}/users'; // /api/users

  // GET /api/users/{id}?ownerProjectLinkId=...
  Future<Map<String, dynamic>> fetchProfileMap({
    required String token, // bearer
    required int userId, // id
  }) async {
    final res = await _dio.get(
      '$_base/$userId',
      queryParameters: {
        'ownerProjectLinkId':
            int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
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
      // backend returns text, not JSON
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain,
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
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain,
        validateStatus: (code) => code != null && code >= 200 && code < 300,
      ),
    );
  }
}
