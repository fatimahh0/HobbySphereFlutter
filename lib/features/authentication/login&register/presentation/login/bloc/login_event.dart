abstract class LoginEvent {}

class LoginRoleChanged extends LoginEvent {
  final int index; // 0 user / 1 business
  LoginRoleChanged(this.index);
}

class LoginToggleMethod extends LoginEvent {}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
}

class LoginPhoneChanged extends LoginEvent {
  final String phoneE164; // +E.164
  LoginPhoneChanged(this.phoneE164);
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
}

class LoginSubmitted extends LoginEvent {}

/// Google button pressed with a REAL Google idToken (JWT)
class LoginGooglePressed extends LoginEvent {
  final String idToken;
  LoginGooglePressed(this.idToken);
}

class LoginReactivateConfirmed extends LoginEvent {}

class LoginReactivateDismissed extends LoginEvent {}
