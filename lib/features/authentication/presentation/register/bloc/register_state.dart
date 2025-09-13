import 'package:image_picker/image_picker.dart';

enum RegStep {
  contact,
  code,
  name,
  username,
  profile,
  interests,
  bizName,
  bizDetails,
  bizProfile,
  done,
}

class RegisterState {
  final int roleIndex;
  final bool usePhone;
  final String email, phone, password, code;
  final bool loading;
  final String? error, info;
  final RegStep step;
  final int pendingId;

  // user
  final String firstName, lastName, username;
  final bool userPublic;
  final XFile? userImage;
  final Set<int> interests;

  // business
  final String bizName, bizDesc, bizWebsite;
  final XFile? bizLogo, bizBanner;

  const RegisterState({
    this.roleIndex = 0,
    this.usePhone = true,
    this.email = '',
    this.phone = '',
    this.password = '',
    this.code = '',
    this.loading = false,
    this.error,
    this.info,
    this.step = RegStep.contact,
    this.pendingId = 0,
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.userPublic = true,
    this.userImage,
    this.interests = const {},
    this.bizName = '',
    this.bizDesc = '',
    this.bizWebsite = '',
    this.bizLogo,
    this.bizBanner,
  });

  RegisterState copyWith({
    int? roleIndex,
    bool? usePhone,
    String? email,
    String? phone,
    String? password,
    String? code,
    bool? loading,
    String? error,
    String? info,
    RegStep? step,
    int? pendingId,
    String? firstName,
    String? lastName,
    String? username,
    bool? userPublic,
    XFile? userImage,
    Set<int>? interests,
    String? bizName,
    String? bizDesc,
    String? bizWebsite,
    XFile? bizLogo,
    XFile? bizBanner,
  }) => RegisterState(
    roleIndex: roleIndex ?? this.roleIndex,
    usePhone: usePhone ?? this.usePhone,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    password: password ?? this.password,
    code: code ?? this.code,
    loading: loading ?? this.loading,
    error: error,
    info: info,
    step: step ?? this.step,
    pendingId: pendingId ?? this.pendingId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    username: username ?? this.username,
    userPublic: userPublic ?? this.userPublic,
    userImage: userImage ?? this.userImage,
    interests: interests ?? this.interests,
    bizName: bizName ?? this.bizName,
    bizDesc: bizDesc ?? this.bizDesc,
    bizWebsite: bizWebsite ?? this.bizWebsite,
    bizLogo: bizLogo ?? this.bizLogo,
    bizBanner: bizBanner ?? this.bizBanner,
  );
}
