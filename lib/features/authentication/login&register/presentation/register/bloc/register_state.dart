// register_state.dart
// Flutter 3.35.x
// State for the register flow. We add `userId` to hold the REAL user id.
// Every line has a small comment.

import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart';
import 'package:image_picker/image_picker.dart'; // for image file

// Steps in the registration wizard
enum RegStep {
  contact, // contact + password
  code, // otp code
  name, // first/last name
  username, // username choose
  profile, // profile picture + public toggle
  interests, // pick interests
  bizName, // business name
  bizDetails, // business description + website
  bizProfile, // business logo + banner
  done, // completed
}

// Immutable-ish state (copyWith creates new)
class RegisterState {
  // role: 0 = user, 1 = business
  final int roleIndex; // current role index
  final bool usePhone; // true if phone method, false email

  // contact + password + code
  final String email; // email text
  final String phone; // phone text (E.164)
  final String password; // chosen password
  final String code; // otp code

  // UI flags
  final bool loading; // global loading flag
  final String? error; // error message
  final String? info; // info message

  // step + ids
  final RegStep step; // current step
  final int pendingId; // pendingId from verify step (pre-user)
  final int userId; // ✅ REAL user id after complete profile

  // interests (remote)
  final List<ActivityType> interestOptions; // list of available interests
  final bool interestsLoading; // loading interests flag
  final String? interestsError; // interests error message

  // user profile
  final String firstName; // user's first name
  final String lastName; // user's last name
  final String username; // user's username
  final bool userPublic; // public profile flag
  final XFile? userImage; // selected user image
  final Set<int> interests; // chosen interest ids

  // business profile
  final String bizName; // business name
  final String bizDesc; // business description
  final String bizWebsite; // business website
  final XFile? bizLogo; // selected logo
  final XFile? bizBanner; // selected banner

  const RegisterState({
    this.roleIndex = 0, // default role user
    this.usePhone = true, // default method phone
    this.email = '', // init email empty
    this.phone = '', // init phone empty
    this.password = '', // init password empty
    this.code = '', // init code empty
    this.loading = false, // not loading at start
    this.error, // no error by default
    this.info, // no info by default
    this.step = RegStep.contact, // start at contact
    this.pendingId = 0, // no pending id yet
    this.userId = 0, // ✅ no real user id yet
    this.firstName = '', // empty first name
    this.lastName = '', // empty last name
    this.username = '', // empty username
    this.userPublic = true, // default public
    this.userImage, // no image
    this.interests = const {}, // empty selection
    this.bizName = '', // empty biz name
    this.bizDesc = '', // empty biz desc
    this.bizWebsite = '', // empty biz site
    this.bizLogo, // no logo
    this.bizBanner, // no banner
    this.interestOptions = const [], // no options loaded yet
    this.interestsLoading = false, // not loading yet
    this.interestsError, // no error message
  });

  // copyWith to clone with changes
  RegisterState copyWith({
    int? roleIndex, // maybe change role
    bool? usePhone, // maybe change method
    String? email, // maybe change email
    String? phone, // maybe change phone
    String? password, // maybe change password
    String? code, // maybe change code
    bool? loading, // maybe change loading
    String? error, // maybe set error
    String? info, // maybe set info
    RegStep? step, // maybe change step
    int? pendingId, // maybe set pending id
    int? userId, // ✅ maybe set REAL user id
    String? firstName, // maybe change firstname
    String? lastName, // maybe change lastname
    String? username, // maybe change username
    bool? userPublic, // maybe change visibility
    XFile? userImage, // maybe set image
    Set<int>? interests, // maybe set interests
    String? bizName, // maybe change biz name
    String? bizDesc, // maybe change biz desc
    String? bizWebsite, // maybe change biz site
    XFile? bizLogo, // maybe change logo
    XFile? bizBanner, // maybe change banner
    List<ActivityType>? interestOptions, // maybe set interest list
    bool? interestsLoading, // maybe set loading flag
    String? interestsError, // maybe set error text
  }) {
    return RegisterState(
      // build new state
      roleIndex: roleIndex ?? this.roleIndex, // keep or replace
      usePhone: usePhone ?? this.usePhone, // keep or replace
      email: email ?? this.email, // keep or replace
      phone: phone ?? this.phone, // keep or replace
      password: password ?? this.password, // keep or replace
      code: code ?? this.code, // keep or replace
      loading: loading ?? this.loading, // keep or replace
      error: error, // replace exactly (can be null)
      info: info, // replace exactly (can be null)
      step: step ?? this.step, // keep or replace
      pendingId: pendingId ?? this.pendingId, // keep or replace
      userId: userId ?? this.userId, // ✅ keep or replace
      firstName: firstName ?? this.firstName, // keep or replace
      lastName: lastName ?? this.lastName, // keep or replace
      username: username ?? this.username, // keep or replace
      userPublic: userPublic ?? this.userPublic, // keep or replace
      userImage: userImage ?? this.userImage, // keep or replace
      interests: interests ?? this.interests, // keep or replace
      bizName: bizName ?? this.bizName, // keep or replace
      bizDesc: bizDesc ?? this.bizDesc, // keep or replace
      bizWebsite: bizWebsite ?? this.bizWebsite, // keep or replace
      bizLogo: bizLogo ?? this.bizLogo, // keep or replace
      bizBanner: bizBanner ?? this.bizBanner, // keep or replace
      interestOptions:
          interestOptions ?? this.interestOptions, // keep or replace
      interestsLoading:
          interestsLoading ?? this.interestsLoading, // keep or replace
      interestsError: interestsError, // replace exactly (can be null)
    );
  }
}
