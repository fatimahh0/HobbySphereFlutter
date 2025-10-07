// Flutter 3.35.x — simple & clean
// Every line has a short, simple comment.

import 'package:image_picker/image_picker.dart'; // XFile
import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart'; // interest model

// Steps in the registration flow (wizard)
enum RegStep {
  contact, // contact + password
  code, // otp
  name, // first / last
  username, // username
  profile, // avatar + public toggle
  interests, // pick interests
  bizName, // business name
  bizDetails, // business desc + website
  bizProfile, // logo + banner
  done, // finished
}

// Immutable state (copyWith returns a new instance)
class RegisterState {
  // role + method
  final int roleIndex; // 0 user / 1 business
  final bool usePhone; // true = phone, false = email

  // contact + password + code
  final String email; // email text
  final String phone; // phone in E.164
  final String password; // password
  final String code; // otp code

  // ui flags
  final bool loading; // global loading
  final String? error; // error text
  final String? info; // info text

  // step + ids
  final RegStep step; // current step
  final int pendingId; // pending id from verify
  final int userId; // real user id after complete profile

  // interests (remote)
  final List<ActivityType> interestOptions; // remote list
  final bool interestsLoading; // loading flag
  final String? interestsError; // error text

  // user profile
  final String firstName; // first name
  final String lastName; // last name
  final String username; // username
  final bool userPublic; // public flag
  final XFile? userImage; // picked avatar
  final Set<int> interests; // chosen ids

  // business profile
  final String bizName; // business name
  final String bizDesc; // business description
  final String bizWebsite; // business website
  final XFile? bizLogo; // picked logo
  final XFile? bizBanner; // picked banner

  const RegisterState({
    this.roleIndex = 0, // default user
    this.usePhone = true, // default phone method
    this.email = '', // empty email
    this.phone = '', // empty phone
    this.password = '', // empty password
    this.code = '', // empty code
    this.loading = false, // not loading
    this.error, // none
    this.info, // none
    this.step = RegStep.contact, // start at contact
    this.pendingId = 0, // no pending yet
    this.userId = 0, // no real user yet
    this.interestOptions = const [], // no options yet
    this.interestsLoading = false, // not loading
    this.interestsError, // none
    this.firstName = '', // empty
    this.lastName = '', // empty
    this.username = '', // empty
    this.userPublic = true, // default public
    this.userImage, // none
    this.interests = const {}, // empty set
    this.bizName = '', // empty
    this.bizDesc = '', // empty
    this.bizWebsite = '', // empty
    this.bizLogo, // none
    this.bizBanner, // none
  });

  // Create a new state with some changed fields
  RegisterState copyWith({
    int? roleIndex, // role
    bool? usePhone, // method
    String? email, // email
    String? phone, // phone
    String? password, // password
    String? code, // otp
    bool? loading, // loading
    String? error, // error (can be null to clear)
    String? info, // info (can be null to clear)
    RegStep? step, // step
    int? pendingId, // pending id
    int? userId, // real user id
    List<ActivityType>? interestOptions, // options
    bool? interestsLoading, // loading flag
    String? interestsError, // error msg
    String? firstName, // first name
    String? lastName, // last name
    String? username, // username
    bool? userPublic, // public flag
    XFile? userImage, // avatar
    Set<int>? interests, // ids
    String? bizName, // biz name
    String? bizDesc, // biz desc
    String? bizWebsite, // website
    XFile? bizLogo, // logo
    XFile? bizBanner, // banner
  }) {
    return RegisterState(
      roleIndex: roleIndex ?? this.roleIndex, // keep/replace
      usePhone: usePhone ?? this.usePhone, // keep/replace
      email: email ?? this.email, // keep/replace
      phone: phone ?? this.phone, // keep/replace
      password: password ?? this.password, // keep/replace
      code: code ?? this.code, // keep/replace
      loading: loading ?? this.loading, // keep/replace
      error: error, // replace (can be null)
      info: info, // replace (can be null)
      step: step ?? this.step, // keep/replace
      pendingId: pendingId ?? this.pendingId, // keep/replace
      userId: userId ?? this.userId, // keep/replace
      interestOptions: interestOptions ?? this.interestOptions, // keep/replace
      interestsLoading:
          interestsLoading ?? this.interestsLoading, // keep/replace
      interestsError: interestsError, // replace (can be null)
      firstName: firstName ?? this.firstName, // keep/replace
      lastName: lastName ?? this.lastName, // keep/replace
      username: username ?? this.username, // keep/replace
      userPublic: userPublic ?? this.userPublic, // keep/replace
      userImage: userImage ?? this.userImage, // keep/replace
      interests: interests ?? this.interests, // keep/replace
      bizName: bizName ?? this.bizName, // keep/replace
      bizDesc: bizDesc ?? this.bizDesc, // keep/replace
      bizWebsite: bizWebsite ?? this.bizWebsite, // keep/replace
      bizLogo: bizLogo ?? this.bizLogo, // keep/replace
      bizBanner: bizBanner ?? this.bizBanner, // keep/replace
    );
  }
}
