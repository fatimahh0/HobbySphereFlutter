// Service uses your global Dio (g.appDio) to call backend.

import 'package:dio/dio.dart'; // http client
import 'package:hobby_sphere/core/network/globals.dart' as g; // global Dio
import 'package:hobby_sphere/config/env.dart'; // for ownerProjectLinkId

class ForgotService {
  // read owner id once; keep it as int when possible
  dynamic get _ownerId =>
      int.tryParse(Env.ownerProjectLinkId) ?? Env.ownerProjectLinkId;

  // helper to pick base path by role (leading slash kept)
  String _base(bool isBusiness) => isBusiness ? '/businesses' : '/users';

  // POST /reset-password
  Future<Response> sendCode({required String email, required bool isBusiness}) {
    return g.appDio!.post(
      '${_base(isBusiness)}/reset-password',
      data: {
        'email': email,
        // 👇 inject owner id into JSON body (backend requires it)
        'ownerProjectLinkId': _ownerId,
      },
    );
  }

  // POST /verify-reset-code
  Future<Response> verifyCode({
    required String email,
    required String code,
    required bool isBusiness,
  }) {
    return g.appDio!.post(
      '${_base(isBusiness)}/verify-reset-code',
      data: {
        'email': email,
        'code': code,
        // 👇 inject owner id into JSON body
        'ownerProjectLinkId': _ownerId,
      },
    );
  }

  // POST /update-password
  Future<Response> updatePassword({
    required String email,
    required String newPassword,
    required bool isBusiness,
  }) {
    return g.appDio!.post(
      '${_base(isBusiness)}/update-password',
      data: {
        'email': email,
        'newPassword': newPassword,
        // 👇 inject owner id into JSON body
        'ownerProjectLinkId': _ownerId,
      },
    );
  }
}
