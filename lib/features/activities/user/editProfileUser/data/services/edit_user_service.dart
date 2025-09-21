import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class EditUserService {
  final Dio _dio = g.appDio!;
  String get _baseUsers => '${g.appServerRoot}/api/users';
  String get _baseAuth => '${g.appServerRoot}/api/auth';

  Future<Map<String, dynamic>> getUserMap({
    required String token,
    required int userId,
  }) async {
    final res = await _dio.get(
      '$_baseUsers/$userId',
      options: Options(
        responseType: ResponseType.json,
        headers: {'Authorization': 'Bearer $token'},
        // keep default validateStatus so non-2xx throws DioException
      ),
    );
    return (res.data as Map).cast<String, dynamic>();
  }


  /// Backend: PUT /api/auth/{id} (multipart)
  Future<void> putUserMultipartAuth({
    required String token,
    required int userId,
    required Map<String, dynamic>
    fields, // {firstName,lastName,username,newPassword?}
    String? imagePath, // file -> profilePicture
  }) async {
    final form = FormData();
    // map "newPassword" to backend "password"
    fields.forEach((k, v) {
      if (v == null) return;
      final key = (k == 'newPassword') ? 'password' : k;
      form.fields.add(MapEntry(key, '$v'));
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      form.files.add(
        MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        ),
      );
    }

    await _dio.put(
      '$_baseAuth/$userId',
      data: form,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
        responseType: ResponseType.plain, // backend returns JSON, but safe
        validateStatus: (c) => c != null && c >= 200 && c < 300,
      ),
    );
  }

  Future<void> deleteProfileImage({
    required String token,
    required int userId,
  }) async {
    await _dio.delete(
      '$_baseUsers/delete-profile-image/$userId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // ← important
        validateStatus: (c) => c != null && c >= 200 && c < 300,
      ),
    );
  }

  Future<void> deleteAccount({
    required String token,
    required int userId,
    required String password,
  }) async {
    await _dio.delete(
      '$_baseUsers/$userId',
      data: {'password': password},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // may be text
        validateStatus: (c) => c != null && c >= 200 && c < 300,
      ),
    );
  }
}
