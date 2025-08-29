// ===== Flutter 3.35.x =====
// services/auth_registration_service.dart
// Auth registration & verification flow (user + business).
// - send verification (email/phone + password)  [multipart]
// - verify codes (email/phone)
// - complete profile (with optional images)     [multipart]
// - resend codes
// - google / facebook login passthrough (optional here; you can keep them in AuthService)

import 'package:dio/dio.dart';                                  // FormData, MultipartFile
import 'package:hobby_sphere/core/network/api_fetch.dart';      // HTTP helper
import 'package:hobby_sphere/core/network/api_methods.dart';    // method names

class AuthRegistrationService {
  // reuse the shared Dio client through our ApiFetch wrapper
  final _fetch = ApiFetch();                                     // one helper
  // base path (global baseUrl already contains "/api")
  static const _base = '/auth';                                  // "/api/auth"

  // ----------------------------- USER FLOW -----------------------------

  // STEP 1: send verification (email OR phone + password) [multipart]
  Future<Map<String, dynamic>> sendUserVerificationCode({
    String? email,                                               // optional email
    String? phoneNumber,                                         // optional phone
    required String password,                                    // required password
  }) async {
    final form = FormData();                                     // init multipart
    if (email != null && email.isNotEmpty) {                     // if email provided
      form.fields.add(MapEntry('email', email));                 // add email
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {         // if phone provided
      form.fields.add(MapEntry('phoneNumber', phoneNumber));     // add phone
    }
    form.fields.add(MapEntry('password', password));             // add password

    final res = await _fetch.fetch(                              // call API
      HttpMethod.post,                                           // POST
      '$_base/send-verification',                                // endpoint
      data: form,                                                // multipart body
      headers: {'Content-Type': 'multipart/form-data'},          // content-type
    );

    final data = res.data;                                       // payload
    if (data is! Map) throw Exception('Invalid send verification response'); // guard
    return Map<String, dynamic>.from(data);                      // return map
  }

  // STEP 2: verify user email code (JSON body)
  Future<Map<String, dynamic>> verifyUserEmailCode({
    required String email,                                       // email
    required String code,                                        // code
  }) async {
    final res = await _fetch.fetch(                              // call API
      HttpMethod.post,                                           // POST
      '$_base/verify-email-code',                                // endpoint
      data: {'email': email, 'code': code},                      // JSON body
    );
    final data = res.data;                                       // payload
    if (data is! Map) throw Exception('Invalid verify email response'); // guard
    return Map<String, dynamic>.from(data);                      // return map
  }

  // STEP 2: verify user phone code (JSON body)
  Future<Map<String, dynamic>> verifyUserPhoneCode({
    required String phoneNumber,                                  // phone
    required String code,                                         // code
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/user/verify-phone-code',                            // endpoint
      data: {'phoneNumber': phoneNumber, 'code': code},           // JSON body
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid verify phone response');
    return Map<String, dynamic>.from(data);
  }

  // STEP 3: complete user profile (username/name/photo/isPublic) [multipart]
  Future<Map<String, dynamic>> completeUserProfile({
    required String pendingId,                                    // id from previous step
    required String username,                                     // username
    required String firstName,                                    // first name
    required String lastName,                                     // last name
    required bool isPublicProfile,                                // visibility flag
    String? profilePhotoPath,                                     // local file path (optional)
  }) async {
    final form = FormData();                                      // init multipart
    form.fields
      ..add(MapEntry('pendingId', pendingId))                     // pendingId
      ..add(MapEntry('username', username))                       // username
      ..add(MapEntry('firstName', firstName))                     // firstName
      ..add(MapEntry('lastName', lastName))                       // lastName
      ..add(MapEntry('isPublicProfile', isPublicProfile.toString())); // bool -> string

    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) { // if image exists
      final name = profilePhotoPath.split('/').last;              // file name
      final corrected = profilePhotoPath.startsWith('file://')    // ensure file://
          ? profilePhotoPath
          : 'file://$profilePhotoPath';
      form.files.add(
        MapEntry(
          'profileImage',                                         // backend field name
          await MultipartFile.fromFile(corrected, filename: name),// attach file
        ),
      );
    }

    final res = await _fetch.fetch(                               // call API
      HttpMethod.post,                                            // POST
      '$_base/complete-profile',                                  // endpoint
      data: form,                                                 // multipart
      headers: {'Content-Type': 'multipart/form-data'},           // header
    );

    final data = res.data;                                        // payload
    if (data is! Map) throw Exception('Invalid complete profile response'); // guard
    return Map<String, dynamic>.from(data);                       // return map
  }

  // STEP 4: resend user code (email or phone in one field)
  Future<Map<String, dynamic>> resendUserCode(String emailOrPhone) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/resend-user-code',                                  // endpoint
      data: {'emailOrPhone': emailOrPhone},                       // JSON body
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid resend user code response');
    return Map<String, dynamic>.from(data);
  }

  // --------------------------- BUSINESS FLOW ---------------------------

  // STEP 1: send business verification (email OR phone + password) [multipart]
  Future<Map<String, dynamic>> sendBusinessVerificationCode({
    String? email,                                                // optional email
    String? phoneNumber,                                          // optional phone
    required String password,                                     // required password
  }) async {
    final form = FormData();                                      // init multipart
    if (email != null && email.isNotEmpty) {
      form.fields.add(MapEntry('email', email));                  // add email
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      form.fields.add(MapEntry('phoneNumber', phoneNumber));      // add phone
    }
    form.fields.add(MapEntry('password', password));              // add password

    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/business/send-verification',                        // endpoint
      data: form,                                                 // multipart body
      headers: {'Content-Type': 'multipart/form-data'},           // header
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid send business verification response');
    return Map<String, dynamic>.from(data);
  }

  // STEP 2: verify business email code (JSON body)
  Future<Map<String, dynamic>> verifyBusinessEmailCode({
    required String email,                                        // email
    required String code,                                         // code
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/business/verify-code',                              // endpoint
      data: {'email': email, 'code': code},                       // JSON
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid business verify email response');
    return Map<String, dynamic>.from(data);
  }

  // STEP 2: verify business phone code (JSON body)
  Future<Map<String, dynamic>> verifyBusinessPhoneCode({
    required String phoneNumber,                                   // phone
    required String code,                                          // code
  }) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/business/verify-phone-code',                         // endpoint
      data: {'phoneNumber': phoneNumber, 'code': code},            // JSON
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid business verify phone response');
    return Map<String, dynamic>.from(data);
  }

  // STEP 3: complete business profile (name/desc/website/logo/banner) [multipart]
  Future<Map<String, dynamic>> completeBusinessProfile({
    required String businessId,                                    // id from step 1/2
    required String businessName,                                  // display name
    required String description,                                   // description
    String? websiteUrl,                                            // optional site
    String? logoPath,                                              // local file path
    String? bannerPath,                                            // local file path
    bool? isPublicProfile,                                         // optional visibility
  }) async {
    final form = FormData();                                       // init form
    form.fields
      ..add(MapEntry('businessId', businessId))                    // id
      ..add(MapEntry('businessName', businessName))                // name
      ..add(MapEntry('description', description));                 // description
    if (websiteUrl != null && websiteUrl.isNotEmpty) {
      form.fields.add(MapEntry('websiteUrl', websiteUrl));         // website
    }
    if (isPublicProfile != null) {
      form.fields.add(MapEntry('isPublicProfile', isPublicProfile.toString())); // bool->str
    }

    if (logoPath != null && logoPath.isNotEmpty) {                 // attach logo
      final name = logoPath.split('/').last;                       // file name
      final corrected = logoPath.startsWith('file://') ? logoPath : 'file://$logoPath'; // ensure file://
      form.files.add(
        MapEntry('logo', await MultipartFile.fromFile(corrected, filename: name)),
      );
    }

    if (bannerPath != null && bannerPath.isNotEmpty) {             // attach banner
      final name = bannerPath.split('/').last;                     // file name
      final corrected = bannerPath.startsWith('file://') ? bannerPath : 'file://$bannerPath';
      form.files.add(
        MapEntry('banner', await MultipartFile.fromFile(corrected, filename: name)),
      );
    }

    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/business/complete-profile',                          // endpoint
      data: form,                                                  // multipart body
      headers: {'Content-Type': 'multipart/form-data'},            // header
    );

    final data = res.data;
    if (data is! Map) throw Exception('Invalid complete business profile response');
    return Map<String, dynamic>.from(data);
  }

  // STEP 4: resend business code (email or phone in one field)
  Future<Map<String, dynamic>> resendBusinessCode(String emailOrPhone) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/resend-business-code',                               // endpoint
      data: {'emailOrPhone': emailOrPhone},                        // JSON body
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid resend business code response');
    return Map<String, dynamic>.from(data);
  }

  // ------------------ OPTIONAL: Social logins here too ------------------

  // POST /api/auth/google
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/google',                                             // endpoint
      data: {'idToken': idToken},                                  // JSON body
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid google login response');
    return Map<String, dynamic>.from(data);
  }

  // POST /api/auth/facebook/login
  Future<Map<String, dynamic>> facebookLogin(String accessToken) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '$_base/facebook/login',                                     // endpoint
      data: {'accessToken': accessToken},                          // JSON body
    );
    final data = res.data;
    if (data is! Map) throw Exception('Invalid facebook login response');
    return Map<String, dynamic>.from(data);
  }
}
