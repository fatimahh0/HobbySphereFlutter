// ===== Flutter 3.35.x =====
// services/profile_service.dart
// Profile API: update profile, delete user, delete profile image.

import 'package:dio/dio.dart'; // FormData, Multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // HTTP helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // PUT / DELETE

class ProfileService {
  final _fetch = ApiFetch(); // shared client
  static const _base = ''; // baseUrl already ends with /api

  // ------------------------------------------------------------
  // PUT /api/auth/{userId}
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required FormData formData, // multipart body
    required String token, // JWT
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '/auth/$userId', // path
      data: formData,
      headers: {
        'Authorization': 'Bearer $token', // auth header
        'Content-Type': 'multipart/form-data', // needed for files
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid profile update response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/users/{userId}
  Future<Map<String, dynamic>> deleteUser({
    required int userId,
    required String password, // confirmation password
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/users/$userId', // path
      data: {'password': password}, // JSON body
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid delete user response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/users/delete-profile-image/{userId}
  Future<Map<String, dynamic>> deleteProfileImage({
    required int userId,
    required String token,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '/users/delete-profile-image/$userId', // path
      headers: {'Authorization': 'Bearer $token'}, // auth only
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid delete profile image response');
    return Map<String, dynamic>.from(data);
  }
}
