import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationService {
  final Dio dio; // pass g.appDio
  RegistrationService(this.dio);

  // ---------- USER ----------
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
      },
    );
    _ok(res);
  }

  Future<int> verifyUserEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/verify-email-code',
      data: {'email': email, 'code': code},
    );
    _ok(r);
    return (r.data['user']['id'] as num).toInt();
  }

  Future<int> verifyUserPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/user/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code},
    );
    _ok(r);
    return (r.data['user']['id'] as num).toInt();
  }

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

  Future<void> addUserInterests(int userId, List<int> ids) async {
    final r = await dio.post('/users/$userId/interests', data: ids);
    _ok(r);
  }

  Future<void> resendUserCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-user-code',
      data: {'emailOrPhone': contact},
    );
    _ok(r);
  }

  // ---------- BUSINESS ----------
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
      },
    );
    _ok(r);
    return (r.data['pendingId'] as num).toInt();
  }

  Future<int> verifyBusinessEmailCode(String email, String code) async {
    final r = await dio.post(
      '/auth/business/verify-code',
      data: {'email': email, 'code': code},
    );
    _ok(r);
    return (r.data['business']['id'] as num).toInt();
  }

  Future<int> verifyBusinessPhoneCode(String phone, String code) async {
    final r = await dio.post(
      '/auth/business/verify-phone-code',
      data: {'phoneNumber': phone, 'code': code},
    );
    _ok(r);
    return (r.data['business']['id'] as num).toInt();
  }

  Future<Map<String, dynamic>> completeBusinessProfile({
    required int businessId,
    required String businessName,
    String? description,
    String? websiteUrl,
    XFile? logo,
    XFile? banner,
  }) async {
    final form = FormData.fromMap({
      'businessId': businessId,
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

  Future<void> resendBusinessCode(String contact) async {
    final r = await dio.post(
      '/auth/resend-business-code',
      data: {'emailOrPhone': contact},
    );
    _ok(r);
  }

  void _ok(Response r) {
    if (r.statusCode == null || r.statusCode! < 200 || r.statusCode! >= 300) {
      throw HttpException('Request failed: ${r.statusCode} ${r.statusMessage}');
    }
  }
}
