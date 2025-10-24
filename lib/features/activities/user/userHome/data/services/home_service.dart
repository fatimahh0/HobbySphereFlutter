import 'package:dio/dio.dart' show DioException;
import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/api_fetch.dart' as net;
import 'package:hobby_sphere/core/network/api_methods.dart';

class HomeService {
  final net.ApiFetch _fetch = net.ApiFetch();

  // ---- Owner/Tenant helpers ----
  dynamic get _oplId {
    final raw = (Env.ownerProjectLinkId).trim();
    assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
    return int.tryParse(raw) ?? raw;
  }

  // Append ownerProjectLinkId safely (keeps existing query params)
  String _withOwnerQuery(String path) {
    final uri = Uri.parse(path);
    final qp = Map<String, String>.from(uri.queryParameters)
      ..['ownerProjectLinkId'] = _oplId.toString();
    return uri.replace(queryParameters: qp).toString();
  }

  String _bearerOrNull(String token) {
    if (token.trim().isEmpty) return '';
    return token.startsWith('Bearer ')
        ? token.trim()
        : 'Bearer ${token.trim()}';
  }

  Future<List<Map<String, dynamic>>> getInterestBased(
    String token,
    int userId,
  ) async {
    try {
      final auth = _bearerOrNull(token);
      final path = _withOwnerQuery('/items/category-based/$userId');

      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: {if (auth.isNotEmpty) 'Authorization': auth},
      );

      final data = res.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const <Map<String, dynamic>>[];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const <Map<String, dynamic>>[];
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingGuest({int? typeId}) async {
    try {
      final rawPath = typeId == null
          ? '/items/upcoming'
          : '/items/guest/upcoming?typeId=$typeId';
      final path = _withOwnerQuery(rawPath);

      final res = await _fetch.fetch(HttpMethod.get, path);

      final data = res.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const <Map<String, dynamic>>[];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const <Map<String, dynamic>>[];
      rethrow;
    }
  }
}
