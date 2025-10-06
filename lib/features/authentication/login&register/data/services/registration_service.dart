// registration_service.dart
// Flutter 3.35.x
// Simple Dio service for registration-related APIs.
// Every line has a small comment to explain what it does.

import 'dart:io'; // for HttpException (readable errors)
import 'package:dio/dio.dart'; // Dio HTTP client
import 'package:image_picker/image_picker.dart'; // for image file upload

class RegistrationService {
  final Dio dio; // injected Dio instance (has baseUrl, interceptors)
  RegistrationService(this.dio); // constructor

  // ---------- USER: send verification (email or phone) ----------
  Future<void> sendUserVerification({
    String? email, // optional email
    String? phoneNumber, // optional phone
    required String password, // required password
  }) async {
    final res = await dio.post(
      '/auth/send-verification', // endpoint (no /api)
      queryParameters: {
        if (email != null && email.isNotEmpty) 'email': email, // pass email
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber, // pass phone
        'password': password, // pass password
      },
    );
    _ok(res); // throw if not 2xx
  }

  // ---------- USER: verify code (EMAIL) -> returns pendingId ----------
  Future<int> verifyUserEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/verify-email-code', // verify email code
      data: {'email': email, 'code': code}, // request body
    );
    _ok(r); // ensure 2xx
    // prefer pendingId; fallback to user.id if backend still returns it
    final pendingId = (r.data['pendingId'] ?? r.data['user']?['id']) as num;
    return pendingId.toInt(); // return int
  }

  // ---------- USER: verify code (PHONE) -> returns pendingId ----------
  Future<int> verifyUserPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/user/verify-phone-code', // verify phone code
      data: {'phoneNumber': phone, 'code': code}, // request body
    );
    _ok(r); // ensure 2xx
    // prefer pendingId; fallback to user.id if needed
    final pendingId = (r.data['pendingId'] ?? r.data['user']?['id']) as num;
    return pendingId.toInt(); // return int
  }

  // ---------- USER: complete profile -> returns the REAL created user map ----------
  Future<Map<String, dynamic>> completeUserProfile({
    required int pendingId, // pending id from verify step
    required String username, // username
    required String firstName, // first name
    required String lastName, // last name
    required bool isPublicProfile, // visibility flag
    XFile? profileImage, // optional image
  }) async {
    final form = FormData.fromMap({
      'pendingId': pendingId, // send pending id
      'username': username, // send username
      'firstName': firstName, // send first name
      'lastName': lastName, // send last name
      'isPublicProfile': isPublicProfile, // public flag
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path, // file path
          filename: profileImage.name, // file name
        ), // attach file
    });

    final r = await dio.post(
      '/auth/complete-profile', // finalize user creation
      data: form, // multipart form
    );
    _ok(r); // ensure 2xx

    final user = Map<String, dynamic>.from(r.data['user'] as Map); // user json
    return user; // return user map
  }

  // ---------- USER: add interests -> primary /api path + legacy fallback ----------
 // in registration_service.dart
  Future<void> addUserInterests(int userId, List<int> ids) async {
    // New canonical endpoint
    final primary = '/users/$userId/UpdateCategory';

    // Known alternates in your codebase
    final alt1 = '/users/$userId/categoriess';
    final alt2 =
        '/users/$userId/categories'; // if you later switch to PUT/POST here
    final legacy =
        '/users/$userId/UpdateInterest'; // old path your app used

    // Try them in order until one succeeds
    final paths = <String>[primary, alt1, alt2, legacy];

    DioException? lastError;

    for (final path in paths) {
      try {
        final r = await dio.post(path, data: ids);
        if (r.statusCode != null &&
            r.statusCode! >= 200 &&
            r.statusCode! < 300) {
          return; // success on this path
        }
      } on DioException catch (e) {
        lastError = e;
        // continue to next path only if it was a 404/405
        final sc = e.response?.statusCode ?? 0;
        if (!(sc == 404 || sc == 405)) rethrow;
      }
    }

    // If we got here, all attempts failed
    if (lastError != null) throw lastError;
    throw HttpException('No interests endpoint accepted the request.');
  }


  // ---------- USER: resend verification code ----------
  Future<void> resendUserCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-user-code', // resend endpoint
      data: {'emailOrPhone': contact}, // contact string
    );
    _ok(r); // ensure 2xx
  }

  // ---------- BUSINESS: send verification -> returns pendingId ----------
  Future<int> sendBusinessVerification({
    String? email, // optional email
    String? phoneNumber, // optional phone
    required String password, // password
  }) async {
    final r = await dio.post(
      '/auth/business/send-verification', // business path (no /api)
      queryParameters: {
        if (email != null && email.isNotEmpty) 'email': email, // pass email
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber, // pass phone
        'password': password, // pass password
      },
    );
    _ok(r); // ensure 2xx
    return (r.data['pendingId'] as num).toInt(); // return pendingId
  }

  // ---------- BUSINESS: verify email -> returns businessId ----------
  Future<int> verifyBusinessEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/business/verify-code', // verify email
      data: {'email': email, 'code': code}, // request body
    );
    _ok(r); // ensure 2xx
    return (r.data['business']['id'] as num).toInt(); // business id
  }

  // ---------- BUSINESS: verify phone -> returns businessId ----------
  Future<int> verifyBusinessPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/business/verify-phone-code', // verify phone
      data: {'phoneNumber': phone, 'code': code}, // request body
    );
    _ok(r); // ensure 2xx
    return (r.data['business']['id'] as num).toInt(); // business id
  }

  // ---------- BUSINESS: complete profile -> returns business map ----------
  Future<Map<String, dynamic>> completeBusinessProfile({
    required int businessId, // business id from verify step
    required String businessName, // business name
    String? description, // optional description
    String? websiteUrl, // optional website
    XFile? logo, // optional logo file
    XFile? banner, // optional banner file
  }) async {
    final form = FormData.fromMap({
      'businessId': businessId, // id
      'businessName': businessName, // name
      if (description != null) 'description': description, // set if non-null
      if (websiteUrl != null) 'websiteUrl': websiteUrl, // set if non-null
      if (logo != null)
        'logo': await MultipartFile.fromFile(
          logo.path, // logo path
          filename: logo.name, // logo filename
        ), // attach file
      if (banner != null)
        'banner': await MultipartFile.fromFile(
          banner.path, // banner path
          filename: banner.name, // banner filename
        ), // attach file
    });

    final r = await dio.post(
      '/auth/business/complete-profile', // business finalize
      data: form, // multipart form
    );
    _ok(r); // ensure 2xx
    return Map<String, dynamic>.from(r.data['business'] as Map); // map
  }

  // ---------- BUSINESS: resend code ----------
  Future<void> resendBusinessCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-business-code', // resend endpoint
      data: {'emailOrPhone': contact}, // contact
    );
    _ok(r); // ensure 2xx
  }

  // ---------- INTERESTS: GET all categories (new API + safe fallback) ----------
  Future<List<Map<String, dynamic>>> fetchActivityTypes() async {
    const primary = '/admin/categoriess'; // new controller mapping
    const fallback = '/admin/categories'; // safe fallback if server fixes path
    try {
      final r = await dio.get(primary); // try primary
      _ok(r); // ensure 2xx
      return _asListOfMap(r.data); // normalize to List<Map>
    } on DioException catch (e) {
      // on 4xx/5xx try fallback path
      if ((e.response?.statusCode ?? 0) >= 400) {
        final r2 = await dio.get(fallback); // fallback
        _ok(r2); // ensure 2xx
        return _asListOfMap(r2.data); // normalize
      }
      rethrow; // bubble if it's a network/unknown error
    }
  }

  // ---------- helper: normalize to List<Map<String, dynamic>> ----------
  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    if (data is List) {
      return List<Map<String, dynamic>>.from(data); // already a list → cast
    }
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(
        data['data'],
      ); // unwrap {data:[...]}
    }
    return const <Map<String, dynamic>>[]; // safe empty
  }

  // ---------- helper: throws if not 2xx ----------
  void _ok(Response r) {
    if (r.statusCode == null || r.statusCode! < 200 || r.statusCode! >= 300) {
      throw HttpException(
        'Request failed: ${r.statusCode} ${r.statusMessage}', // readable error
      );
    }
  }

  // in registration_service.dart
 
}
