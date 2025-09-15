import 'package:image_picker/image_picker.dart';

abstract class RegisterEvent {}

class RegRoleChanged extends RegisterEvent {
  final int index;
  RegRoleChanged(this.index);
}

class RegToggleMethod extends RegisterEvent {}

class RegEmailChanged extends RegisterEvent {
  final String v;
  RegEmailChanged(this.v);
}

class RegPhoneChanged extends RegisterEvent {
  final String v;
  RegPhoneChanged(this.v);
}

class RegPasswordChanged extends RegisterEvent {
  final String v;
  RegPasswordChanged(this.v);
}

class RegSendVerification extends RegisterEvent {}

class RegResendCode extends RegisterEvent {}

class RegCodeChanged extends RegisterEvent {
  final String v;
  RegCodeChanged(this.v);
}

class RegVerifyCode extends RegisterEvent {}

// user steps
class RegFirstNameChanged extends RegisterEvent {
  final String v;
  RegFirstNameChanged(this.v);
}

class RegLastNameChanged extends RegisterEvent {
  final String v;
  RegLastNameChanged(this.v);
}

class RegUsernameChanged extends RegisterEvent {
  final String v;
  RegUsernameChanged(this.v);
}

class RegUserPublicToggled extends RegisterEvent {
  final bool v;
  RegUserPublicToggled(this.v);
}

class RegPickUserImage extends RegisterEvent {
  final XFile? f;
  RegPickUserImage(this.f);
}

class RegSubmitUserProfile extends RegisterEvent {}

class RegToggleInterest extends RegisterEvent {
  final int id;
  RegToggleInterest(this.id);
}

class RegSubmitInterests extends RegisterEvent {}

// business steps
class RegBusinessNameChanged extends RegisterEvent {
  final String v;
  RegBusinessNameChanged(this.v);
}

class RegBusinessDescChanged extends RegisterEvent {
  final String v;
  RegBusinessDescChanged(this.v);
}

class RegBusinessWebsiteChanged extends RegisterEvent {
  final String v;
  RegBusinessWebsiteChanged(this.v);
}

class RegPickBusinessLogo extends RegisterEvent {
  final XFile? f;
  RegPickBusinessLogo(this.f);
}

class RegPickBusinessBanner extends RegisterEvent {
  final XFile? f;
  RegPickBusinessBanner(this.f);
}

// load interests from backend
// load interests from backend
class RegFetchInterests extends RegisterEvent {
  RegFetchInterests(); // make it NON-const  ✅
}

class RegSubmitBusinessProfile extends RegisterEvent {}
