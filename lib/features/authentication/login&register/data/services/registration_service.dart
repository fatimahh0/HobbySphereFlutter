// registration_service.dart
// Flutter 3.35.x
// Simple Dio service for registration-related APIs.
// Every line has a small comment to explain what it does.

import 'dart:io'; // for HttpException
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
      // POST request
      '/auth/send-verification', // endpoint (no /api here in your backend)
      queryParameters: {
        // backend expects query params
        if (email != null && email.isNotEmpty)
          'email': email, // add email if provided
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber, // add phone if provided
        'password': password, // send password
      },
    );
    _ok(res); // throw if not 2xx
  }

  // ---------- USER: verify code (EMAIL) -> returns pendingId ----------
  Future<int> verifyUserEmailCode(String email, String code) async {
    final r = await dio.post(
      // POST to verify email code
      '/auth/verify-email-code',
      data: {'email': email, 'code': code}, // send email and code as body
    );
    _ok(r); // throw if not 2xx
    // IMPORTANT: from now we return pendingId (not user.id)
    final pendingId =
        (r.data['pendingId'] ?? r.data['user']?['id'])
            as num; // fallback if backend still returns user.id
    return pendingId.toInt(); // return pendingId as int
  }

  // ---------- USER: verify code (PHONE) -> returns pendingId ----------
  Future<int> verifyUserPhoneCode(String phone, String code) async {
    final r = await dio.post(
      // POST to verify phone code
      '/auth/user/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code}, // send phone and code
    );
    _ok(r); // throw if not 2xx
    // IMPORTANT: same rule: return pendingId
    final pendingId =
        (r.data['pendingId'] ?? r.data['user']?['id'])
            as num; // fallback if needed
    return pendingId.toInt(); // return pendingId
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
      // create form-data for file upload
      'pendingId': pendingId, // send pending id
      'username': username, // send username
      'firstName': firstName, // send first name
      'lastName': lastName, // send last name
      'isPublicProfile': isPublicProfile, // send visibility flag
      if (profileImage != null) // if image is provided
        'profileImage': await MultipartFile.fromFile(
          profileImage.path, // file path
          filename: profileImage.name, // file name
        ),
    });

    final r = await dio.post(
      // POST request
      '/auth/complete-profile', // endpoint to finalize user creation
      data: form, // send form
    );
    _ok(r); // throw if not 2xx

    final user = Map<String, dynamic>.from(
      r.data['user'] as Map,
    ); // extract user json
    return user; // return user map to caller
  }

  // ---------- USER: add interests -> primary /api path + legacy fallback ----------
  Future<void> addUserInterests(int userId, List<int> ids) async {
    final String primary =
        '/api/users/$userId/interests'; // primary endpoint from your controller
    try {
      final r = await dio.post(primary, data: ids); // send JSON array [1,2,3]
      _ok(r); // succeed if 2xx
      return; // done
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0; // read status code
      if (status == 404 || status == 405) {
        // if route not found / method mismatch
        final String fallback =
            '/users/$userId/UpdateInterest'; // legacy fallback (capital U)
        final r2 = await dio.post(
          fallback,
          data: ids,
        ); // retry with same array body
        _ok(r2); // throw if not 2xx
        return; // done
      }
      rethrow; // otherwise bubble up error
    }
  }

  // ---------- USER: resend verification code ----------
  Future<void> resendUserCode(String contact) async {
    final r = await dio.post(
      // POST to resend code
      '/auth/resend-user-code',
      data: {'emailOrPhone': contact}, // contact string
    );
    _ok(r); // throw if not 2xx
  }

  // ---------- BUSINESS: send verification -> returns pendingId ----------
  Future<int> sendBusinessVerification({
    String? email, // optional email
    String? phoneNumber, // optional phone
    required String password, // password
  }) async {
    final r = await dio.post(
      // POST request
      '/auth/business/send-verification', // business path (no /api)
      queryParameters: {
        // backend expects query params here
        if (email != null && email.isNotEmpty)
          'email': email, // pass email if set
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber, // pass phone if set
        'password': password, // pass password
      },
    );
    _ok(r); // throw if not 2xx
    return (r.data['pendingId'] as num)
        .toInt(); // return pendingId from backend
  }

  // ---------- BUSINESS: verify email -> returns businessId ----------
  Future<int> verifyBusinessEmailCode(String email, String code) async {
    final r = await dio.post(
      // POST verify
      '/auth/business/verify-code',
      data: {'email': email, 'code': code}, // send email + code
    );
    _ok(r); // throw if not 2xx
    return (r.data['business']['id'] as num).toInt(); // return id
  }

  // ---------- BUSINESS: verify phone -> returns businessId ----------
  Future<int> verifyBusinessPhoneCode(String phone, String code) async {
    final r = await dio.post(
      // POST verify
      '/auth/business/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code}, // send phone + code
    );
    _ok(r); // throw if not 2xx
    return (r.data['business']['id'] as num).toInt(); // return id
  }

  // ---------- BUSINESS: complete profile -> returns business map ----------
  Future<Map<String, dynamic>> completeBusinessProfile({
    required int businessId, // business id (from verify step)
    required String businessName, // business name
    String? description, // optional description
    String? websiteUrl, // optional website
    XFile? logo, // optional logo file
    XFile? banner, // optional banner file
  }) async {
    final form = FormData.fromMap({
      // build form-data
      'businessId': businessId, // id
      'businessName': businessName, // name
      if (description != null) 'description': description, // description if set
      if (websiteUrl != null) 'websiteUrl': websiteUrl, // website if set
      if (logo != null) // if logo provided
        'logo': await MultipartFile.fromFile(
          logo.path, // logo path
          filename: logo.name, // logo filename
        ),
      if (banner != null) // if banner provided
        'banner': await MultipartFile.fromFile(
          banner.path, // banner path
          filename: banner.name, // banner filename
        ),
    });

    final r = await dio.post(
      // POST request
      '/auth/business/complete-profile', // endpoint
      data: form, // send form
    );
    _ok(r); // throw if not 2xx
    return Map<String, dynamic>.from(r.data['business'] as Map); // return map
  }

  // ---------- BUSINESS: resend code ----------
  Future<void> resendBusinessCode(String contact) async {
    final r = await dio.post(
      // POST
      '/auth/resend-business-code',
      data: {'emailOrPhone': contact}, // contact
    );
    _ok(r); // throw if not 2xx
  }

  // ---------- ACTIVITY TYPES: GET all (use /api prefix) ----------
  Future<List<Map<String, dynamic>>> fetchActivityTypes() async {
    final r = await dio.get('/item-types/all'); // hit /api endpoint
    _ok(r); // throw if not 2xx
    final data = r.data; // raw body
    if (data is List) {
      // if direct list
      return List<Map<String, dynamic>>.from(data); // cast list of maps
    }
    if (data is Map && data['data'] is List) {
      // if wrapped {data: [...]}
      return List<Map<String, dynamic>>.from(data['data']); // unwrap data
    }
    return const <Map<String, dynamic>>[]; // safe empty list
  }

  // ---------- Small helper: throws if not 2xx ----------
  void _ok(Response r) {
    if (r.statusCode == null || r.statusCode! < 200 || r.statusCode! >= 300) {
      throw HttpException(
        'Request failed: ${r.statusCode} ${r.statusMessage}',
      ); // readable error
    }
  }
}
