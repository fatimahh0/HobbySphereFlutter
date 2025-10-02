// Events that drive the forgot-flow.

import 'package:meta/meta.dart'; // annotations

@immutable // value classes
abstract class ForgotEvent {} // base

/// Toggle between user/business.
class ForgotRoleChanged extends ForgotEvent {
  final bool isBusiness; // true -> business, false -> user
  ForgotRoleChanged(this.isBusiness); // ctor
}

/// Update email text.
class ForgotEmailChanged extends ForgotEvent {
  final String email; // email value
  ForgotEmailChanged(this.email); // ctor
}

/// Update code text (6 digits).
class ForgotCodeChanged extends ForgotEvent {
  final String code; // code
  ForgotCodeChanged(this.code); // ctor
}

/// Update new password text.
class ForgotNewPasswordChanged extends ForgotEvent {
  final String newPassword; // password
  ForgotNewPasswordChanged(this.newPassword); // ctor
}

/// Step 1: send code.
class ForgotSendCodePressed extends ForgotEvent {}

/// Step 2: verify code.
class ForgotVerifyCodePressed extends ForgotEvent {}

/// Step 3: update password.
class ForgotUpdatePasswordPressed extends ForgotEvent {}
