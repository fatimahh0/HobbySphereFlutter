// lib/core/registration/registration_service.dart
// Flutter 3.35.x
// Dio service for registration-related APIs with explicit ownerProjectLinkId injection.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hobby_sphere/config/env.dart';

class RegistrationService {
  final Dio dio;
  RegistrationService(this.dio);

  // ---- helper: normalize owner id from dart-define ----
  String get _ownerId =>
      (int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId)
          .toString();

  // ---------- USER: send verification (email or phone) ----------
  // Backend expects ownerProjectLinkId as @RequestParam, so we add it in queryParameters.
  Future<void> sendUserVerification({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final res = await dio.post(
      '/auth/send-verification',
      queryParameters: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
        'password': password,
        'ownerProjectLinkId':
            _ownerId, // 👈 required by controller as @RequestParam
      },
    );
    _ok(res);
  }

  // ---------- USER: verify code (EMAIL) -> returns pendingId ----------
  // Controller doesn't require ownerProjectLinkId here.
  Future<int> verifyUserEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/verify-email-code',
      data: {'email': email, 'code': code},
    );
    _ok(r);
    final pendingId = (r.data['pendingId'] ?? r.data['user']?['id']) as num;
    return pendingId.toInt();
  }

  // ---------- USER: verify code (PHONE) -> returns pendingId ----------
  // Controller doesn't require ownerProjectLinkId here.
  Future<int> verifyUserPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/user/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code},
    );
    _ok(r);
    final pendingId = (r.data['pendingId'] ?? r.data['user']?['id']) as num;
    return pendingId.toInt();
  }

  // ---------- USER: complete profile (multipart) ----------
  // Controller expects ownerProjectLinkId as @RequestParam in multipart → add as field.
  Future<Map<String, dynamic>> completeUserProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    XFile? profileImage,
  }) async {
    final form = FormData.fromMap({
      'pendingId': pendingId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'isPublicProfile': isPublicProfile,
      'ownerProjectLinkId': _ownerId, // 👈 required @RequestParam in controller
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.name,
        ),
    });

    final r = await dio.post('/auth/complete-profile', data: form);
    _ok(r);
    return Map<String, dynamic>.from(r.data['user'] as Map);
  }

  // ---------- USER: add interests (tries multiple known endpoints) ----------
  Future<void> addUserInterests(int userId, List<int> ids) async {
    final paths = <String>[
      '/users/$userId/UpdateCategory',
      '/users/$userId/categoriess',
      '/users/$userId/categories',
      '/users/$userId/UpdateInterest',
    ];

    DioException? lastError;
    for (final path in paths) {
      try {
        final r = await dio.post(path, data: ids);
        if ((r.statusCode ?? 0) >= 200 && (r.statusCode ?? 0) < 300) return;
      } on DioException catch (e) {
        lastError = e;
        final sc = e.response?.statusCode ?? 0;
        if (sc != 404 && sc != 405) rethrow;
      }
    }
    if (lastError != null) throw lastError;
    throw HttpException('No interests endpoint accepted the request.');
  }

  // ---------- USER: resend verification code ----------
  // (Your controller example shows resend-business-code only; keeping user variant in case it exists)
  Future<void> resendUserCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-user-code',
      data: {'emailOrPhone': contact},
    );
    _ok(r);
  }

  // ---------- BUSINESS: send verification -> returns pendingId ----------
  // Controller expects ownerProjectLinkId as @RequestParam, so add in queryParameters.
  Future<int> sendBusinessVerification({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    final r = await dio.post(
      '/auth/business/send-verification',
      queryParameters: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
        'password': password,
        'ownerProjectLinkId': _ownerId, // 👈 required @RequestParam
      },
    );
    _ok(r);
    return (r.data['pendingId'] as num).toInt();
  }

  // ---------- BUSINESS: verify email -> returns businessId ----------
  Future<int> verifyBusinessEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/business/verify-code',
      data: {'email': email, 'code': code},
    );
    _ok(r);
    return (r.data['business']['id'] as num).toInt();
  }

  // ---------- BUSINESS: verify phone -> returns businessId ----------
  Future<int> verifyBusinessPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/business/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code},
    );
    _ok(r);
    return (r.data['business']['id'] as num).toInt();
  }

  // ---------- BUSINESS: complete profile (multipart) ----------
  // Controller expects ownerProjectLinkId & pendingId as @RequestParam in multipart → include as fields.
  Future<Map<String, dynamic>> completeBusinessProfile({
    required int pendingId,
    required String businessName,
    String? description,
    String? websiteUrl,
    XFile? logo,
    XFile? banner,
  }) async {
    final form = FormData.fromMap({
      'ownerProjectLinkId': _ownerId, // 👈 required @RequestParam
      'pendingId': pendingId,
      'businessName': businessName,
      if (description != null) 'description': description,
      if (websiteUrl != null) 'websiteUrl': websiteUrl,
      if (logo != null)
        'logo': await MultipartFile.fromFile(logo.path, filename: logo.name),
      if (banner != null)
        'banner': await MultipartFile.fromFile(
          banner.path,
          filename: banner.name,
        ),
    });

    final r = await dio.post('/auth/business/complete-profile', data: form);
    _ok(r);
    return Map<String, dynamic>.from(r.data['business'] as Map);
  }

  // ---------- BUSINESS: resend code ----------
  Future<void> resendBusinessCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-business-code',
      data: {'emailOrPhone': contact},
    );
    _ok(r);
  }

  // ---------- INTERESTS: GET all categories (new API + safe fallback) ----------
  Future<List<Map<String, dynamic>>> fetchActivityTypes() async {
    // normalize/require the project id
    final pid = Env.requiredVar(Env.projectId, 'PROJECT_ID');

    // preferred project-scoped endpoint (your controller: /api/admin/categories/by-project/{projectId})
    final primary = '/admin/categories/by-project/$pid';

    // safe fallbacks (old endpoints you had)
    const fallback1 = '/admin/categoriess';
    const fallback2 = '/admin/categories';

    try {
      final r = await dio.get(primary);
      _ok(r);
      return _asListOfMap(r.data);
    } on DioException catch (e) {
      final sc = e.response?.statusCode ?? 0;

      // try the legacy ones you already use
      if (sc == 404 || sc == 400 || sc == 405) {
        try {
          final r2 = await dio.get(fallback1);
          _ok(r2);
          return _asListOfMap(r2.data);
        } on DioException {
          final r3 = await dio.get(fallback2);
          _ok(r3);
          return _asListOfMap(r3.data);
        }
      }
      rethrow;
    }
  }

  // ---------- helpers ----------
  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return const <Map<String, dynamic>>[];
  }

  void _ok(Response r) {
    if (r.statusCode == null || r.statusCode! < 200 || r.statusCode! >= 300) {
      throw HttpException('Request failed: ${r.statusCode} ${r.statusMessage}');
    }
  }
}
