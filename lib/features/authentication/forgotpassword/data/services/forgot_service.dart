// Service uses your global Dio (g.appDio) to call backend.

import 'package:dio/dio.dart'; // http client
import 'package:hobby_sphere/core/network/globals.dart' as g; // global Dio

class ForgotService {
  // helper to pick base path by role
  String _base(bool isBusiness) =>
      isBusiness ? '/businesses' : '/users'; // choose base

  // POST /reset-password
  Future<Response> sendCode({required String email, required bool isBusiness}) {
    // call endpoint with email body
    return g.appDio!.post(
      '${_base(isBusiness)}/reset-password',
      data: {'email': email},
    ); // send code
  }

  // POST /verify-reset-code
  Future<Response> verifyCode({
    required String email,
    required String code,
    required bool isBusiness,
  }) {
    // call endpoint with email + code body
    return g.appDio!.post(
      '${_base(isBusiness)}/verify-reset-code',
      data: {'email': email, 'code': code},
    ); // verify
  }

  // POST /update-password
  Future<Response> updatePassword({
    required String email,
    required String newPassword,
    required bool isBusiness,
  }) {
    // call endpoint with email + new password body
    return g.appDio!.post(
      '${_base(isBusiness)}/update-password',
      data: {'email': email, 'newPassword': newPassword},
    ); // update
  }
}
