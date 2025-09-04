import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class ReviewService {
  final _fetch = ApiFetch();
  static const _base = '/reviews';

  Future<List<dynamic>> getBusinessReviews(String token, int businessId) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/business/$businessId',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.data is List) return res.data;
    return [];
  }
}
