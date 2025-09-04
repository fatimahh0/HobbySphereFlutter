// ===== Flutter 3.35.x =====
// BusinessAnalyticsService — calls backend to fetch analytics for a business.

import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessAnalyticsService {
  // Shared HTTP client wrapper (based on Dio)
  final _fetch = ApiFetch();

  // Base path for analytics APIs
  static const _base = '/analytics';

  /// Fetch business analytics insights.
  ///
  /// - Requires a valid [token] (Business or Admin JWT).
  /// - [id] is the businessId to fetch analytics for.
  /// - Returns raw JSON Map from backend.
  Future<Map<String, dynamic>> getBusinessAnalytics({
    required String token,
    required int id,
  }) async {
    // Call: GET /api/analytics/business/{id}/insights
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/business/$id/insights',
      headers: {
        'Authorization': 'Bearer $token', // pass JWT
      },
    );
    

    // Ensure response is a Map
    return Map<String, dynamic>.from(res.data);
  }
}
