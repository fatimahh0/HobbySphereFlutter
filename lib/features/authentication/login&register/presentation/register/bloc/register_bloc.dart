// Flutter 3.35.x — simple & clean
// Every line has a short, simple comment.

import 'dart:io'; // HttpException
import 'package:dio/dio.dart'; // DioException
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart'; // interests usecase

// usecases (domain layer)
import '../../../domain/usecases/register/send_user_verification.dart'; // send code (user)
import '../../../domain/usecases/register/verify_user_email_code.dart'; // verify email (user)
import '../../../domain/usecases/register/verify_user_phone_code.dart'; // verify phone (user)
import '../../../domain/usecases/register/complete_user_profile.dart'; // complete profile (user)
import '../../../domain/usecases/register/add_user_interests.dart'; // add interests (user)
import '../../../domain/usecases/register/resend_user_code.dart'; // resend (user)

import '../../../domain/usecases/register/send_business_verification.dart'; // send code (biz)
import '../../../domain/usecases/register/verify_business_email_code.dart'; // verify email (biz)
import '../../../domain/usecases/register/verify_business_phone_code.dart'; // verify phone (biz)
import '../../../domain/usecases/register/complete_business_profile.dart'; // complete profile (biz)
import '../../../domain/usecases/register/resend_business_code.dart'; // resend (biz)

// bloc parts
import 'register_event.dart'; // events
import 'register_state.dart'; // state

// ===== small helpers =====

// convert exceptions to readable text
String _friendlyError(Object err) {
  if (err is DioException) {
    final res = err.response; // response
    final data = res?.data; // body
    if (data is Map) {
      final msg =
          (data['error'] ?? data['message'] ?? data['detail']); // known fields
      if (msg is String && msg.trim().isNotEmpty)
        return msg.trim(); // return if exists
    }
    if (data is String && data.trim().isNotEmpty)
      return data.trim(); // string body
    final code = res?.statusCode ?? 0; // status
    if (code == 409) return 'Already in use'; // conflict hint
    if (code == 400) return 'Something went wrong'; // bad request
    if (code == 401) return 'Unauthorized'; // 401
    if (code == 403) return 'Forbidden'; // 403
    if (code == 404) return 'Not found'; // 404
    if (code >= 500) return 'Server error, please try again'; // 5xx
    return err.message ?? 'Something went wrong'; // dio generic
  }
  if (err is HttpException) return err.message; // http exception
  return 'Something went wrong'; // fallback
}

// map user error message to the correct UI step
RegStep _stepForUserError(String msg) {
  final m = msg.toLowerCase(); // lowercase
  if (m.contains('username')) return RegStep.username; // username problems
  if (m.contains('first')) return RegStep.name; // first name invalid
  if (m.contains('last')) return RegStep.name; // last name invalid
  if (m.contains('image') || m.contains('photo'))
    return RegStep.profile; // image issues
  return RegStep.profile; // default for user profile
}

// map business error message to the correct UI step
RegStep _stepForBusinessError(String msg) {
  final m = msg.toLowerCase(); // lowercase
  if (m.contains('name'))
    return RegStep.bizName; // e.g., "Business name already in use"
  if (m.contains('description') || m.contains('website') || m.contains('url')) {
    return RegStep.bizDetails; // details fields
  }
  if (m.contains('logo') ||
      m.contains('banner') ||
      m.contains('image') ||
      m.contains('file')) {
    return RegStep.bizProfile; // media fields
  }
  return RegStep.bizDetails; // safe default
}

// ===== main bloc =====
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  // user usecases
  final SendUserVerification sendUserVerification; // send code
  final VerifyUserEmailCode verifyUserEmail; // verify email
  final VerifyUserPhoneCode verifyUserPhone; // verify phone
  final CompleteUserProfile completeUser; // complete profile
  final AddUserInterests addInterests; // add interests
  final ResendUserCode resendUser; // resend

  // business usecases
  final SendBusinessVerification sendBizVerification; // send code
  final VerifyBusinessEmailCode verifyBizEmail; // verify email
  final VerifyBusinessPhoneCode verifyBizPhone; // verify phone
  final CompleteBusinessProfile completeBiz; // complete profile
  final ResendBusinessCode resendBiz; // resend

  // interests
  final GetActivityTypes getActivityTypes; // load interest options

  RegisterBloc({
    required this.sendUserVerification, // inject
    required this.verifyUserEmail, // inject
    required this.verifyUserPhone, // inject
    required this.completeUser, // inject
    required this.addInterests, // inject
    required this.resendUser, // inject
    required this.sendBizVerification, // inject
    required this.verifyBizEmail, // inject
    required this.verifyBizPhone, // inject
    required this.completeBiz, // inject
    required this.resendBiz, // inject
    required this.getActivityTypes, // inject
  }) : super(const RegisterState()) {
    // ===== tiny setters / toggles =====
    on<RegRoleChanged>(
      (e, emit) => emit(
        state.copyWith(
          roleIndex: e.index, // change role
          step: RegStep.contact, // restart flow at contact
          error: null, // clear error
          info: null, // clear info
        ),
      ),
    );

    on<RegToggleMethod>(
      (e, emit) => emit(
        state.copyWith(usePhone: !state.usePhone, error: null, info: null),
      ),
    ); // phone/email

    on<RegEmailChanged>((e, emit) => emit(state.copyWith(email: e.v))); // email
    on<RegPhoneChanged>((e, emit) => emit(state.copyWith(phone: e.v))); // phone
    on<RegPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.v)),
    ); // password
    on<RegCodeChanged>((e, emit) => emit(state.copyWith(code: e.v))); // otp

    on<RegFirstNameChanged>(
      (e, emit) => emit(state.copyWith(firstName: e.v)),
    ); // first
    on<RegLastNameChanged>(
      (e, emit) => emit(state.copyWith(lastName: e.v)),
    ); // last
    on<RegUsernameChanged>(
      (e, emit) => emit(state.copyWith(username: e.v)),
    ); // username
    on<RegUserPublicToggled>(
      (e, emit) => emit(state.copyWith(userPublic: e.v)),
    ); // public

    on<RegPickUserImage>(
      (e, emit) => emit(state.copyWith(userImage: e.f)),
    ); // avatar

    on<RegBusinessNameChanged>(
      (e, emit) => emit(state.copyWith(bizName: e.v)),
    ); // biz name
    on<RegBusinessDescChanged>(
      (e, emit) => emit(state.copyWith(bizDesc: e.v)),
    ); // biz desc
    on<RegBusinessWebsiteChanged>(
      (e, emit) => emit(state.copyWith(bizWebsite: e.v)),
    ); // site
    on<RegPickBusinessLogo>(
      (e, emit) => emit(state.copyWith(bizLogo: e.f)),
    ); // logo
    on<RegPickBusinessBanner>(
      (e, emit) => emit(state.copyWith(bizBanner: e.f)),
    ); // banner

    // toggle interest ids inside a Set<int>
    on<RegToggleInterest>((e, emit) {
      final s = {...state.interests}; // copy set
      s.contains(e.id) ? s.remove(e.id) : s.add(e.id); // toggle
      emit(state.copyWith(interests: s)); // save
    });

    // load interest options from backend
    on<RegFetchInterests>((e, emit) async {
      emit(
        state.copyWith(interestsLoading: true, interestsError: null),
      ); // start
      try {
        final items = await getActivityTypes(); // call usecase
        emit(
          state.copyWith(
            interestOptions: items, // set options
            interestsLoading: false, // stop loading
            interestsError: null, // clear error
          ),
        );
      } catch (err) {
        emit(
          state.copyWith(
            interestsLoading: false, // stop
            interestsError: _friendlyError(err), // show error
          ),
        );
      }
    });

    // wire main actions
    on<RegSendVerification>(_sendVerification); // send code
    on<RegResendCode>(_resend); // resend
    on<RegVerifyCode>(_verifyCode); // verify
    on<RegSubmitUserProfile>(_submitUserProfile); // complete user profile
    on<RegSubmitInterests>(_submitInterests); // save interests
    on<RegSubmitBusinessProfile>(
      _submitBusinessProfile,
    ); // complete business profile
  }

  // ===== handlers =====

  // send verification based on role + method
  Future<void> _sendVerification(
    RegSendVerification e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null)); // start
    try {
      if (state.roleIndex == 0) {
        // user role
        await sendUserVerification(
          email: state.usePhone
              ? null
              : state.email.trim(), // email if email mode
          phone: state.usePhone
              ? state.phone.trim()
              : null, // phone if phone mode
          password: state.password.trim(), // password
        );
      } else {
        // business role
        final id = await sendBizVerification(
          email: state.usePhone
              ? null
              : state.email.trim(), // email if email mode
          phone: state.usePhone
              ? state.phone.trim()
              : null, // phone if phone mode
          password: state.password.trim(), // password
        );
        emit(state.copyWith(pendingId: id)); // store pendingId
      }

      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.code, // next
          info: 'Verification code sent', // info
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // resend verification
  Future<void> _resend(RegResendCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null)); // start
    try {
      final contact = state.usePhone
          ? state.phone.trim()
          : state.email.trim(); // pick contact
      if (state.roleIndex == 0) {
        await resendUser(contact); // user
      } else {
        await resendBiz(contact); // business
      }
      emit(state.copyWith(loading: false, info: 'Code resent')); // ok
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // verify otp code and move to next step
  Future<void> _verifyCode(RegVerifyCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null)); // start
    try {
      if (state.roleIndex == 0) {
        // user role
        final id = state.usePhone
            ? await verifyUserPhone(
                state.phone.trim(),
                state.code.trim(),
              ) // phone
            : await verifyUserEmail(
                state.email.trim(),
                state.code.trim(),
              ); // email

        emit(
          state.copyWith(
            loading: false, // stop
            pendingId: id, // store
            step: RegStep.name, // to names
          ),
        );
      } else {
        // business role
        final id = state.pendingId != 0
            ? state.pendingId
            : (state.usePhone
                  ? await verifyBizPhone(state.phone.trim(), state.code.trim())
                  : await verifyBizEmail(
                      state.email.trim(),
                      state.code.trim(),
                    ));

        emit(
          state.copyWith(
            loading: false, // stop
            pendingId: id, // store
            step: RegStep.bizName, // to biz name
          ),
        );
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // complete user profile -> returns REAL user -> then go to interests
  Future<void> _submitUserProfile(
    RegSubmitUserProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      final user = await completeUser(
        pendingId: state.pendingId, // pending id
        username: state.username.trim(), // username
        firstName: state.firstName.trim(), // first name
        lastName: state.lastName.trim(), // last name
        isPublic: state.userPublic, // public flag
        image: state.userImage, // avatar (optional)
      );

      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.interests, // to interests
          userId: user.id, // store REAL user id
        ),
      );
    } catch (err) {
      final msg = _friendlyError(err); // readable
      final step = _stepForUserError(msg); // map to step
      emit(
        state.copyWith(
          loading: false, // stop
          error: msg, // show error
          step: step, // rewind to field
        ),
      );
    }
  }

  // save selected interests using REAL user id
  Future<void> _submitInterests(
    RegSubmitInterests e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      await addInterests(state.userId, state.interests.toList()); // call
      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.done, // done
          info: 'Registration complete', // info
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // complete business profile (handles media + fields)
  Future<void> _submitBusinessProfile(
    RegSubmitBusinessProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      await completeBiz(
        pendingId: state.pendingId, // pending id
        name: state.bizName.trim(), // business name
        description: state.bizDesc.trim().isEmpty
            ? null
            : state.bizDesc.trim(), // desc optional
        websiteUrl: state.bizWebsite.trim().isEmpty
            ? null
            : state.bizWebsite.trim(), // url optional
        logo: state.bizLogo, // logo (optional)
        banner: state.bizBanner, // banner (optional)
      );

      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.done, // done
          info: 'Registration complete', // info
        ),
      );
    } catch (err) {
      final msg = _friendlyError(err); // readable
      final step = _stepForBusinessError(msg); // map to step
      emit(
        state.copyWith(
          loading: false, // stop
          error: msg, // show
          step: step, // rewind to correct form
        ),
      );
    }
  }
}
