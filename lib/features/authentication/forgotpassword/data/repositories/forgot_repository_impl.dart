// Repository implementation that maps service responses to SimpleMsg.


import 'package:hobby_sphere/features/authentication/forgotpassword/domain/reposotories/forgot_repository.dart';

import '../services/forgot_service.dart'; // service

class ForgotRepositoryImpl implements ForgotRepository {
  // hold service
  final ForgotService s; // service
  ForgotRepositoryImpl(this.s); // constructor

  @override
  Future<SimpleMsg> sendResetCode({
    required String email,
    required bool isBusiness,
  }) async {
    // call service and read message
    final r = await s.sendCode(
      email: email,
      isBusiness: isBusiness,
    ); // send code
    final msg = (r.data is Map && r.data['message'] != null)
        ? r.data['message'] as String
        : 'Reset code sent'; // fallback
    return SimpleMsg(msg); // wrap
  }

  @override
  Future<SimpleMsg> verifyResetCode({
    required String email,
    required String code,
    required bool isBusiness,
  }) async {
    // call service and read message
    final r = await s.verifyCode(
      email: email,
      code: code,
      isBusiness: isBusiness,
    ); // verify
    final msg = (r.data is Map && r.data['message'] != null)
        ? r.data['message'] as String
        : 'Code verified'; // fallback
    return SimpleMsg(msg); // wrap
  }

  @override
  Future<SimpleMsg> updatePassword({
    required String email,
    required String newPassword,
    required bool isBusiness,
  }) async {
    // call service and read message
    final r = await s.updatePassword(
      email: email,
      newPassword: newPassword,
      isBusiness: isBusiness,
    ); // update
    final msg = (r.data is Map && r.data['message'] != null)
        ? r.data['message'] as String
        : 'Password updated'; // fallback
    return SimpleMsg(msg); // wrap
  }
}
