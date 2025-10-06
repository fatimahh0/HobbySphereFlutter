// user_interests_api.dart
import 'package:dio/dio.dart';

class UserInterestsApi {
  final Dio dio;
  UserInterestsApi(this.dio);

  Options _auth(String token) {
    final t = token.trim();
    return Options(
      headers: {
        'Authorization': t.startsWith('Bearer ') ? t : 'Bearer $t',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  // Prefer the new categories endpoint; keep safe fallback chain
  Future<List<String>> getUserInterestNames(String token, int userId) async {
    final paths = <String>[
      '/users/$userId/categories', // new read endpoint
      '/users/$userId/interests', // old read endpoint (if you add alias)
    ];

    DioException? lastError;
    for (final p in paths) {
      try {
        final res = await dio.get(p, options: _auth(token));
        final data = res.data;
        if (data is List) return data.map((e) => '$e').toList();
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((e) => '$e').toList();
        }
      } on DioException catch (e) {
        lastError = e;
        final sc = e.response?.statusCode ?? 0;
        if (!(sc == 404 || sc == 405)) rethrow;
      }
    }
    if (lastError != null) throw lastError;
    return const <String>[];
  }

  // Replace all categories for a user in one shot
  Future<void> replaceUserInterests(
    String token,
    int userId,
    List<int> ids,
  ) async {
    final paths = <String>[
      '/users/$userId/UpdateCategory', // canonical
      '/users/$userId/categoriess', // typo'ed alternate
      '/users/$userId/UpdateInterest', // legacy
    ];

    DioException? lastError;
    for (final p in paths) {
      try {
        final res = await dio.post(p, data: ids, options: _auth(token));
        if (res.statusCode != null &&
            res.statusCode! >= 200 &&
            res.statusCode! < 300)
          return;
      } on DioException catch (e) {
        lastError = e;
        final sc = e.response?.statusCode ?? 0;
        if (!(sc == 404 || sc == 405)) rethrow;
      }
    }
    if (lastError != null) throw lastError;
    throw Exception('No user categories endpoint found.');
  }
}
