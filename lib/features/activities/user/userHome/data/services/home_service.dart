import 'package:hobby_sphere/core/network/api_fetch.dart' as net;
import 'package:hobby_sphere/core/network/api_methods.dart';

class HomeService {
  final net.ApiFetch _fetch = net.ApiFetch();

  Future<List<Map<String, dynamic>>> getInterestBased(
    String token,
    int userId,
  ) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/items/interest-based/$userId',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<List<Map<String, dynamic>>> getUpcomingGuest({int? typeId}) async {
    final path = typeId == null
        ? '/items/guest/upcoming'
        : '/items/guest/upcoming?typeId=$typeId';
    final res = await _fetch.fetch(HttpMethod.get, path);
    final data = res.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
