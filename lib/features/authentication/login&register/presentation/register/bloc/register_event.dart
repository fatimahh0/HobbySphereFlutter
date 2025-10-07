// Flutter 3.35.x — simple & clean
// Every line has a short, simple comment.

import 'package:image_picker/image_picker.dart'; // XFile from image_picker

// Base class for all registration events
abstract class RegisterEvent {
  const RegisterEvent(); // base ctor
}

// ===== flow switches / small setters =====
class RegRoleChanged extends RegisterEvent {
  final int index; // 0 = user, 1 = business
  const RegRoleChanged(this.index); // ctor
}

class RegToggleMethod extends RegisterEvent {
  const RegToggleMethod(); // toggle between phone/email
}

class RegEmailChanged extends RegisterEvent {
  final String v; // new email
  const RegEmailChanged(this.v); // ctor
}

class RegPhoneChanged extends RegisterEvent {
  final String v; // new phone
  const RegPhoneChanged(this.v); // ctor
}

class RegPasswordChanged extends RegisterEvent {
  final String v; // new password
  const RegPasswordChanged(this.v); // ctor
}

class RegSendVerification extends RegisterEvent {
  const RegSendVerification(); // send code
}

class RegResendCode extends RegisterEvent {
  const RegResendCode(); // resend code
}

class RegCodeChanged extends RegisterEvent {
  final String v; // new code
  const RegCodeChanged(this.v); // ctor
}

class RegVerifyCode extends RegisterEvent {
  const RegVerifyCode(); // verify otp
}

// ===== user profile steps =====
class RegFirstNameChanged extends RegisterEvent {
  final String v; // first name
  const RegFirstNameChanged(this.v); // ctor
}

class RegLastNameChanged extends RegisterEvent {
  final String v; // last name
  const RegLastNameChanged(this.v); // ctor
}

class RegUsernameChanged extends RegisterEvent {
  final String v; // username
  const RegUsernameChanged(this.v); // ctor
}

class RegUserPublicToggled extends RegisterEvent {
  final bool v; // public flag
  const RegUserPublicToggled(this.v); // ctor
}

class RegPickUserImage extends RegisterEvent {
  final XFile? f; // selected image file (nullable)
  const RegPickUserImage(this.f); // ctor
}

class RegSubmitUserProfile extends RegisterEvent {
  const RegSubmitUserProfile(); // submit user profile
}

// interests
class RegToggleInterest extends RegisterEvent {
  final int id; // interest id
  const RegToggleInterest(this.id); // ctor
}

class RegFetchInterests extends RegisterEvent {
  const RegFetchInterests(); // load options
}

class RegSubmitInterests extends RegisterEvent {
  const RegSubmitInterests(); // submit selection
}

// ===== business profile steps =====
class RegBusinessNameChanged extends RegisterEvent {
  final String v; // business name
  const RegBusinessNameChanged(this.v); // ctor
}

class RegBusinessDescChanged extends RegisterEvent {
  final String v; // business description
  const RegBusinessDescChanged(this.v); // ctor
}

class RegBusinessWebsiteChanged extends RegisterEvent {
  final String v; // website url
  const RegBusinessWebsiteChanged(this.v); // ctor
}

class RegPickBusinessLogo extends RegisterEvent {
  final XFile? f; // selected logo (nullable)
  const RegPickBusinessLogo(this.f); // ctor
}

class RegPickBusinessBanner extends RegisterEvent {
  final XFile? f; // selected banner (nullable)
  const RegPickBusinessBanner(this.f); // ctor
}

class RegSubmitBusinessProfile extends RegisterEvent {
  const RegSubmitBusinessProfile(); // submit business profile
}
