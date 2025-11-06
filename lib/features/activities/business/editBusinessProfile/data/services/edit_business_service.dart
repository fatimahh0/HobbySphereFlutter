import 'package:dio/dio.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class EditBusinessService {
  final Dio _dio = g.appDio!;

  Future<Map<String, dynamic>> getBusinessById(String token, int id) async {
    final res = await _dio.get(
      '/businesses/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> updateBusiness(
    String token,
    int id,
    Map<String, dynamic> body, {
    bool withImages = false,
  }) async {
    Response res;
    if (withImages) {
      final formData = FormData.fromMap(body);
      res = await _dio.put(
        '/businesses/update-with-images/$id',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } else {
      res = await _dio.put(
        '/businesses/$id',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    }
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> deleteBusiness(
    String token,
    int id,
    String password,
  ) async {
    final res = await _dio.delete(
      '/businesses/$id',
      data: {"password": password},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // 👈 force plain text
      ),
    );
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> deleteLogo(String token, int id) async {
    final res = await _dio.delete(
      '/businesses/delete-logo/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // 👈 force plain text
      ),
    );
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> deleteBanner(String token, int id) async {
    final res = await _dio.delete(
      '/businesses/delete-banner/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.plain, // 👈 force plain text
      ),
    );
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> updateVisibility(
    String token,
    int id,
    bool isPublic,
  ) async {
    final res = await _dio.put(
      '/businesses/$id/visibility',
      data: {"isPublicProfile": isPublic},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return _normalizeResponse(res.data);
  }

  Future<Map<String, dynamic>> updateStatus(
    String token,
    int id,
    String status,
    String? password,
  ) async {
    final body = {"status": status};
    if (password != null) body["password"] = password;

    final res = await _dio.put(
      '/businesses/$id/status',
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return _normalizeResponse(res.data);
  }

  // ✅ Normalize response into Map
  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is String) {
      return {"message": data};
    } else {
      return {"message": data.toString()};
    }
  }
}
