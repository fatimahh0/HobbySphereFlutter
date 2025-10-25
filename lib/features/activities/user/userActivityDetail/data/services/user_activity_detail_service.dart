// lib/features/activities/user/activity_detail/data/services/user_activity_detail_service.dart
import 'package:dio/dio.dart';
import 'package:hobby_sphere/config/env.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

/// Service for item details, availability and booking
class UserActivityDetailService {
  final Dio _dio;
  final String _baseUrl;

  UserActivityDetailService({Dio? dio, String? baseUrl})
    : _dio = dio ?? (g.appDio ?? Dio()),
      _baseUrl = (baseUrl ?? g.serverRootNoApi()).trim();

  /// Owner id required by backend as ownerProjectLinkId
  String get _ownerId {
    final raw = Env.ownerProjectLinkId; // e.g. set via --dart-define
    // normalize to string
    final asInt = int.tryParse(raw);
    return (asInt ?? raw).toString();
  }

  /// Ensure "Bearer " prefix
  String _auth(String bearerToken) =>
      bearerToken.startsWith('Bearer ') ? bearerToken : 'Bearer $bearerToken';

  String _api(String p) => '$_baseUrl/api/items$p';

  /// Merge ownerProjectLinkId into query map (without overwriting given keys)
  Map<String, dynamic> _withOwner(Map<String, dynamic>? query) {
    final q = <String, dynamic>{'ownerProjectLinkId': _ownerId};
    if (query != null) q.addAll(query);
    return q;
  }

  /// GET /api/items/{id}?ownerProjectLinkId=...
  Future<Map<String, dynamic>> getById(int id, {String? bearerToken}) async {
    final res = await _dio.get(
      _api('/$id'),
      queryParameters: _withOwner(null),
      options: bearerToken == null
          ? null
          : Options(headers: {'Authorization': _auth(bearerToken)}),
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  /// GET /api/items/{itemId}/check-availability?participants=..&ownerProjectLinkId=..
  Future<bool> checkAvailability({
    required int itemId,
    required int participants,
    required String bearerToken,
  }) async {
    final res = await _dio.get(
      _api('/$itemId/check-availability'),
      queryParameters: _withOwner(<String, dynamic>{
        'participants': participants,
      }),
      options: Options(headers: {'Authorization': _auth(bearerToken)}),
    );
    final data = (res.data as Map);
    return data['available'] == true;
  }

  /// POST /api/items/confirm-booking
  /// Backend often reads ownerProjectLinkId as @RequestParam; to be safe we send it
  /// in both queryParameters and body.
  Future<int> confirmBooking({
    required int itemId,
    required int participants,
    required String stripePaymentId,
    required String bearerToken,
  }) async {
    final body = <String, dynamic>{
      'itemId': itemId,
      'participants': participants,
      'stripePaymentId': stripePaymentId,
      // Include in body in case controller reads it from form/json
      'ownerProjectLinkId': _ownerId,
    };

    final res = await _dio.post(
      _api('/confirm-booking'),
      queryParameters: _withOwner(null), // also include as query param
      data: body,
      options: Options(headers: {'Authorization': _auth(bearerToken)}),
    );
    return ((res.data as Map)['bookingId'] as num).toInt();
  }
}
