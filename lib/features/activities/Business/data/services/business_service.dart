// ===== Flutter 3.35.x =====
// services/business_service.dart
// Business API: profile, update with images, analytics, reset password,
// status/visibility, logo/banner, manager invites, Stripe, mark booking paid.

import 'package:dio/dio.dart'; // FormData, Multipart
import 'package:hobby_sphere/core/network/api_fetch.dart'; // axios-like helper
import 'package:hobby_sphere/core/network/api_methods.dart'; // GET/POST/PUT/DELETE

class BusinessService {
  final _fetch = ApiFetch(); // reuse Dio client
  static const _base = '/businesses'; // base (Dio baseUrl ends with /api)
  static const _analytics = '/analytics'; // analytics path

  // small helper for images
  String _fileName(String path) => path.split('/').last;
  String _mimeByExt(String name) =>
      name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

  // ------------------------------------------------------------
  // GET /api/businesses/{id}
  Future<Map<String, dynamic>> getBusinessProfile({
    required String token,
    required int id,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid business profile');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // PUT /api/businesses/update-with-images/{id}  (multipart/form-data)
  Future<Map<String, dynamic>> updateBusinessWithImages({
    required String token,
    required int id,
    String? name,
    String? email,
    String? password,
    String? description,
    String? phoneNumber,
    String? websiteUrl,
    String? logoUri, // path on device
    String? bannerUri, // path on device
  }) async {
    final form = FormData();

    // only add non-empty fields
    if (name?.trim().isNotEmpty == true)
      form.fields.add(MapEntry('name', name!.trim()));
    if (email?.trim().isNotEmpty == true)
      form.fields.add(MapEntry('email', email!.trim()));
    if (description?.trim().isNotEmpty == true)
      form.fields.add(MapEntry('description', description!.trim()));
    if (phoneNumber?.trim().isNotEmpty == true)
      form.fields.add(MapEntry('phoneNumber', phoneNumber!.trim()));
    if (websiteUrl?.trim().isNotEmpty == true)
      form.fields.add(MapEntry('websiteUrl', websiteUrl!.trim()));
    if (password!.trim().length >= 6) {
      form.fields.add(MapEntry('password', password!.trim()));
    }

    // add images if they look like local files
    if (logoUri != null && logoUri.startsWith('file://')) {
      final name = _fileName(logoUri);
      form.files.add(
        MapEntry('logo', await MultipartFile.fromFile(logoUri, filename: name)),
      );
    }
    if (bannerUri != null && bannerUri.startsWith('file://')) {
      final name = _fileName(bannerUri);
      form.files.add(
        MapEntry(
          'banner',
          await MultipartFile.fromFile(bannerUri, filename: name),
        ),
      );
    }

    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_base/update-with-images/$id',
      data: form,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid update response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------------------------------------------------
  // DELETE /api/businesses/{id}
  Future<Map<String, dynamic>> deleteBusiness({
    required String token,
    required int id,
    required String password,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/$id',
      data: {'password': password},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // GET /api/analytics/business/{id}/insights
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

  // ------------------------------------------------------------
  // POST /api/businesses/reset-password
  Future<Map<String, dynamic>> sendBusinessResetCode(String email) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/reset-password',
        data: {'email': email},
      );
      return {
        'success': true,
        'message': res.data['message'] ?? 'Reset code sent to business email.',
      };
    } catch (err) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // POST /api/businesses/verify-reset-code
  Future<Map<String, dynamic>> verifyBusinessResetCode(
    String email,
    String code,
  ) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/verify-reset-code',
        data: {'email': email, 'code': code},
      );
      return {
        'success': true,
        'message': res.data['message'] ?? 'Code verified successfully.',
      };
    } catch (err) {
      return {'success': false, 'message': 'Invalid code.'};
    }
  }

  // POST /api/businesses/update-password
  Future<Map<String, dynamic>> updateBusinessPassword(
    String email,
    String newPassword,
  ) async {
    try {
      final res = await _fetch.fetch(
        HttpMethod.post,
        '$_base/update-password',
        data: {'email': email, 'newPassword': newPassword},
      );
      return {
        'success': true,
        'message': res.data['message'] ?? 'Password updated successfully.',
      };
    } catch (err) {
      return {'success': false, 'message': 'Failed to update password.'};
    }
  }

  // ------------------------------------------------------------
  // PUT /api/businesses/{id}/status
  Future<Map<String, dynamic>> updateBusinessStatus({
    required String token,
    required int id,
    required String status,
    required String password,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/status',
      data: {'status': status, 'password': password},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // PUT /api/businesses/{id}/visibility
  Future<Map<String, dynamic>> updateBusinessVisibility({
    required String token,
    required int id,
    required bool isPublicProfile,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '$_base/$id/visibility',
      data: {'isPublicProfile': isPublicProfile},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // DELETE /api/businesses/delete-logo/{id}
  Future<Map<String, dynamic>> deleteBusinessLogo({
    required String token,
    required int id,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/delete-logo/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // DELETE /api/businesses/delete-banner/{id}
  Future<Map<String, dynamic>> deleteBusinessBanner({
    required String token,
    required int id,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.delete,
      '$_base/delete-banner/$id',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // POST /api/businesses/{businessId}/send-manager-invite
  Future<Map<String, dynamic>> sendManagerInvite({
    required String token,
    required int businessId,
    required String email,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/$businessId/send-manager-invite',
      data: {'email': email},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // POST /api/businesses/stripe/connect
  Future<Map<String, dynamic>> connectStripeAccount(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/stripe/connect',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // GET /api/businesses/{id}/stripe-status
  Future<Map<String, dynamic>> checkStripeConnection({
    required String token,
    required int businessId,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '$_base/$businessId/stripe-status',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // POST /api/businesses/stripe/resume
  Future<Map<String, dynamic>> resumeStripeOnboarding(String token) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/stripe/resume',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ------------------------------------------------------------
  // PUT /api/bookings/mark-paid/{bookingId}
  Future<Map<String, dynamic>> markBookingAsPaid({
    required String token,
    required int bookingId,
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.put,
      '/bookings/mark-paid/$bookingId',
      headers: {'Authorization': 'Bearer $token'},
    );
    return Map<String, dynamic>.from(res.data);
  }
}
