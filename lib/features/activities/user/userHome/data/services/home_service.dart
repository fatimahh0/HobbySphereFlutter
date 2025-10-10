import 'package:dio/dio.dart' show DioException;
import 'package:hobby_sphere/core/network/api_fetch.dart' as net;
import 'package:hobby_sphere/core/network/api_methods.dart';

class HomeService {
  final net.ApiFetch _fetch = net.ApiFetch();

  Future<List<Map<String, dynamic>>> getInterestBased(
    String token,
    int userId,
  ) async {
    try {
      final auth = token.isEmpty
          ? null
          : (token.startsWith('Bearer ') ? token : 'Bearer $token');

      final res = await _fetch.fetch(
        HttpMethod.get,
        '/items/category-based/$userId',
        headers: {if (auth != null) 'Authorization': auth},
      );

      final data = res.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const <Map<String, dynamic>>[];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const <Map<String, dynamic>>[];
      }

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingGuest({int? typeId}) async {
    try {
      final path = typeId == null
          ? '/items/upcoming'
          : '/items/guest/upcoming?typeId=$typeId';

      final res = await _fetch.fetch(HttpMethod.get, path);

      final data = res.data;
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const <Map<String, dynamic>>[];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const <Map<String, dynamic>>[];
      }
      rethrow;
    }
  }
}
