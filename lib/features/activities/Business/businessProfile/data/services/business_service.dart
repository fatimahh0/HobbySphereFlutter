import 'package:hobby_sphere/core/network/api_fetch.dart';
import 'package:hobby_sphere/core/network/api_methods.dart';

class BusinessService {
  final _fetch = ApiFetch();
  static const _base = '/businesses';

  String _auth(String token) =>
      token.startsWith('Bearer ') ? token : 'Bearer $token';

  /// GET /api/businesses/{id}
  Future<Map<String, dynamic>> getBusinessById(String token, int id) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$id',
      headers: {'Authorization': _auth(token)},
    );
    return (res.data as Map).cast<String, dynamic>();
  }

  /// PUT /api/businesses/{id}/visibility
  Future<void> updateVisibility(
    String token,
    int id,
    bool isPublic,
  ) async {
    await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/visibility',
      headers: {'Authorization': _auth(token)},
      data: {'isPublicProfile': isPublic},
    );
  }

  /// PUT /api/businesses/{id}/status
  /// When status == INACTIVE, backend requires { password }.
  Future<void> updateStatus(
    String token,
    int id,
    String status, {
    String? password,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (password != null) body['password'] = password;

    await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/status',
      headers: {'Authorization': _auth(token)},
      data: body,
    );
  }

  /// DELETE /api/businesses/{id}
  Future<void> deleteBusiness(
    String token,
    int id,
    String password,
  ) async {
    await _fetch.fetch(
      HttpMethod.delete,
      '$_base/$id',
      headers: {'Authorization': _auth(token)},
      data: {'password': password},
    );
  }

  /// GET /api/businesses/{id}/stripe-status
  Future<bool> checkStripeStatus(String token, int id) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$id/stripe-status',
      headers: {'Authorization': _auth(token)},
    );
    final data = res.data;
    if (data is Map && data['stripeConnected'] is bool) {
      return data['stripeConnected'] as bool;
    }
    return false;
  }

  /// (Optional) POST /api/businesses/{id}/send-manager-invite
  Future<void> sendManagerInvite(
    String token,
    int id,
    String email,
  ) async {
    await _fetch.fetch(
      HttpMethod.post,
      '$_base/$id/send-manager-invite',
      headers: {'Authorization': _auth(token)},
      data: {'email': email},
    );
  }
}
