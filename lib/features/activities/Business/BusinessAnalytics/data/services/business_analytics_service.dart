import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessAnalyticsService {
  final _fetch = ApiFetch();
  static const _analytics = '/analytics'; // analytics path
  Future<Map<String, dynamic>> getBusinessAnalytics({
    required String token,
    required int id,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_analytics/business/$id/insights',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

}
