// Flutter 3.35.x
// Clean, simple, and professional.
// Every line has a short, simple comment.

import 'package:meta/meta.dart'; // for @immutable

/// A small response model with a message only.
@immutable // immutable object
class SimpleMsg {
  // text message from server or local
  final String message; // message
  const SimpleMsg(this.message); // constructor
}

/// Abstraction for forgot password actions.
abstract class ForgotRepository {
  /// Send reset code to email (user or business based on flag).
  Future<SimpleMsg> sendResetCode({required String email, required bool isBusiness}); // send code

  /// Verify the received code (user or business).
  Future<SimpleMsg> verifyResetCode({required String email, required String code, required bool isBusiness}); // verify code

  /// Update password after code verification (user or business).
  Future<SimpleMsg> updatePassword({required String email, required String newPassword, required bool isBusiness}); // update pwd
}
