// register_bloc.dart
// Flutter 3.35.x
// Bloc that drives the registration flow.
// We make sure to store REAL userId after profile and use it when saving interests.
// Every block of code is commented simply.

import 'dart:io'; // for HttpException
import 'package:dio/dio.dart'; // Dio errors
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc base
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart';

// usecases (your existing domain layer)
import '../../../domain/usecases/register/send_user_verification.dart';
import '../../../domain/usecases/register/verify_user_email_code.dart';
import '../../../domain/usecases/register/verify_user_phone_code.dart';
import '../../../domain/usecases/register/complete_user_profile.dart';
import '../../../domain/usecases/register/add_user_interests.dart';
import '../../../domain/usecases/register/resend_user_code.dart';
import '../../../domain/usecases/register/send_business_verification.dart';
import '../../../domain/usecases/register/verify_business_email_code.dart';
import '../../../domain/usecases/register/verify_business_phone_code.dart';
import '../../../domain/usecases/register/complete_business_profile.dart';
import '../../../domain/usecases/register/resend_business_code.dart';

// bloc parts
import 'register_event.dart'; // events
import 'register_state.dart'; // state

// helper to convert exceptions to friendly text
String _friendlyError(Object err) {
  if (err is DioException) {
    // dio error?
    final res = err.response; // get response
    final data = res?.data; // body
    if (data is Map) {
      // json body
      final msg =
          (data['error'] ?? data['message'] ?? data['detail']); // message field
      if (msg is String && msg.trim().isNotEmpty)
        return msg.trim(); // return if present
    }
    if (data is String && data.trim().isNotEmpty)
      return data.trim(); // plain string fallback
    final code = res?.statusCode ?? 0; // status code
    if (code == 409) return 'Username already in use'; // conflict hint
    if (code == 400) return 'Something went wrong'; // bad request
    if (code == 401) return 'Unauthorized'; // unauthorized
    if (code == 403) return 'Forbidden'; // forbidden
    if (code == 404) return 'Not found'; // not found
    if (code >= 500) return 'Server error, please try again'; // server error
    return err.message ?? 'Something went wrong'; // generic dio message
  }
  if (err is HttpException) return err.message; // http exception text
  return 'Something went wrong'; // last fallback
}

// main bloc
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  // usecases (injected)
  final SendUserVerification sendUserVerification; // send code (user)
  final VerifyUserEmailCode verifyUserEmail; // verify email (user)
  final VerifyUserPhoneCode verifyUserPhone; // verify phone (user)
  final CompleteUserProfile completeUser; // complete profile (user)
  final AddUserInterests addInterests; // add interests (user)
  final ResendUserCode resendUser; // resend code (user)

  final SendBusinessVerification sendBizVerification; // send code (biz)
  final VerifyBusinessEmailCode verifyBizEmail; // verify email (biz)
  final VerifyBusinessPhoneCode verifyBizPhone; // verify phone (biz)
  final CompleteBusinessProfile completeBiz; // complete profile (biz)
  final ResendBusinessCode resendBiz; // resend code (biz)

  final GetActivityTypes getActivityTypes; // load interest options

  RegisterBloc({
    required this.sendUserVerification,
    required this.verifyUserEmail,
    required this.verifyUserPhone,
    required this.completeUser,
    required this.addInterests,
    required this.resendUser,
    required this.sendBizVerification,
    required this.verifyBizEmail,
    required this.verifyBizPhone,
    required this.completeBiz,
    required this.resendBiz,
    required this.getActivityTypes,
  }) : super(const RegisterState()) {
    // initial state

    // simple setters for small fields
    on<RegRoleChanged>(
      (e, emit) => emit(
        // change role
        state.copyWith(
          roleIndex: e.index,
          step: RegStep.contact,
          error: null,
          info: null,
        ),
      ),
    );
    on<RegToggleMethod>(
      (e, emit) => emit(
        // toggle phone/email
        state.copyWith(usePhone: !state.usePhone, error: null, info: null),
      ),
    );
    on<RegEmailChanged>(
      (e, emit) => emit(state.copyWith(email: e.v)),
    ); // set email
    on<RegPhoneChanged>(
      (e, emit) => emit(state.copyWith(phone: e.v)),
    ); // set phone
    on<RegPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.v)),
    ); // set password
    on<RegCodeChanged>(
      (e, emit) => emit(state.copyWith(code: e.v)),
    ); // set otp code
    on<RegFirstNameChanged>(
      (e, emit) => emit(state.copyWith(firstName: e.v)),
    ); // set first name
    on<RegLastNameChanged>(
      (e, emit) => emit(state.copyWith(lastName: e.v)),
    ); // set last name
    on<RegUsernameChanged>(
      (e, emit) => emit(state.copyWith(username: e.v)),
    ); // set username
    on<RegUserPublicToggled>(
      (e, emit) => emit(state.copyWith(userPublic: e.v)),
    ); // set public flag
    on<RegPickUserImage>(
      (e, emit) => emit(state.copyWith(userImage: e.f)),
    ); // set image
    on<RegBusinessNameChanged>(
      (e, emit) => emit(state.copyWith(bizName: e.v)),
    ); // set biz name
    on<RegBusinessDescChanged>(
      (e, emit) => emit(state.copyWith(bizDesc: e.v)),
    ); // set biz desc
    on<RegBusinessWebsiteChanged>(
      (e, emit) => emit(state.copyWith(bizWebsite: e.v)),
    ); // set biz site
    on<RegPickBusinessLogo>(
      (e, emit) => emit(state.copyWith(bizLogo: e.f)),
    ); // set logo
    on<RegPickBusinessBanner>(
      (e, emit) => emit(state.copyWith(bizBanner: e.f)),
    ); // set banner

    // toggle an interest id in a Set<int>
    on<RegToggleInterest>((e, emit) {
      final s = {...state.interests}; // copy set
      s.contains(e.id) ? s.remove(e.id) : s.add(e.id); // toggle id
      emit(state.copyWith(interests: s)); // save
    });

    // load remote interest options
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
            interestsError: _friendlyError(err), // show friendly error
          ),
        );
      }
    });

    // wire main actions
    on<RegSendVerification>(_sendVerification); // send code
    on<RegResendCode>(_resend); // resend code
    on<RegVerifyCode>(_verifyCode); // verify code
    on<RegSubmitUserProfile>(_submitUserProfile); // complete user profile
    on<RegSubmitInterests>(_submitInterests); // save interests
    on<RegSubmitBusinessProfile>(
      _submitBusinessProfile,
    ); // complete biz profile
  }

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
          // send code
          email: state.usePhone
              ? null
              : state.email.trim(), // pass email if email mode
          phone: state.usePhone
              ? state.phone.trim()
              : null, // pass phone if phone mode
          password: state.password.trim(), // pass password
        );
      } else {
        // business role
        final id = await sendBizVerification(
          // send code for business
          email: state.usePhone
              ? null
              : state.email.trim(), // pass email if email mode
          phone: state.usePhone
              ? state.phone.trim()
              : null, // pass phone if phone mode
          password: state.password.trim(), // pass password
        );
        emit(state.copyWith(pendingId: id)); // store pendingId for business
      }
      emit(
        state.copyWith(
          // go to code step
          loading: false, // stop loading
          step: RegStep.code, // next step
          info: 'Verification code sent', // info text
        ),
      );
    } catch (err) {
      emit(
        state.copyWith(loading: false, error: _friendlyError(err)),
      ); // show error
    }
  }

  // resend verification
  Future<void> _resend(RegResendCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null)); // start
    try {
      final contact = state.usePhone
          ? state.phone.trim()
          : state.email.trim(); // decide contact
      if (state.roleIndex == 0) {
        // user
        await resendUser(contact); // resend for user
      } else {
        // business
        await resendBiz(contact); // resend for business
      }
      emit(state.copyWith(loading: false, info: 'Code resent')); // ok
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // verify otp code
  Future<void> _verifyCode(RegVerifyCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null)); // start
    try {
      if (state.roleIndex == 0) {
        // user role
        // use email/phone verify to get PENDING id
        final id = state.usePhone
            ? await verifyUserPhone(
                state.phone.trim(),
                state.code.trim(),
              ) // verify phone
            : await verifyUserEmail(
                state.email.trim(),
                state.code.trim(),
              ); // verify email

        emit(
          state.copyWith(
            loading: false, // stop
            pendingId: id, // store pending id
            step: RegStep.name, // go to names step
          ),
        );
      } else {
        // business role
        // for business, you might already have pendingId
        final id = state.pendingId != 0
            ? state.pendingId
            : (state.usePhone
                  ? await verifyBizPhone(
                      state.phone.trim(),
                      state.code.trim(),
                    ) // verify phone
                  : await verifyBizEmail(
                      state.email.trim(),
                      state.code.trim(),
                    )); // verify email

        emit(
          state.copyWith(
            loading: false, // stop
            pendingId: id, // store id
            step: RegStep.bizName, // go to biz name step
          ),
        );
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // complete user profile (creates REAL user), store REAL userId, then go to interests
  Future<void> _submitUserProfile(
    RegSubmitUserProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      final user = await completeUser(
        // call usecase -> service
        pendingId: state.pendingId, // send pendingId
        username: state.username.trim(), // send username
        firstName: state.firstName.trim(), // send first name
        lastName: state.lastName.trim(), // send last name
        isPublic: state.userPublic, // send visibility flag
        image: state.userImage, // optional image
      );

      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.interests, // to interests
          userId: user.id, // ✅ store REAL user id for next call
        ),
      );
    } catch (err) {
      final msg = _friendlyError(err); // message
      final shouldBackToUsername = msg.toLowerCase().contains(
        'username',
      ); // check for username issue
      emit(
        state.copyWith(
          loading: false, // stop
          error: msg, // show error
          step: shouldBackToUsername
              ? RegStep.username
              : state.step, // go back if username problem
        ),
      );
    }
  }

  // save selected interests using REAL userId
  Future<void> _submitInterests(
    RegSubmitInterests e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      await addInterests(
        state.userId,
        state.interests.toList(),
      ); // ✅ use REAL user id
      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.done, // finished
          info: 'Registration complete', // info
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }

  // complete business profile
  Future<void> _submitBusinessProfile(
    RegSubmitBusinessProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start
    try {
      await completeBiz(
        // call usecase
        pendingId: state.pendingId, // business id/pending id
        name: state.bizName.trim(), // business name
        description: state.bizDesc.trim().isEmpty
            ? null
            : state.bizDesc.trim(), // optional desc
        websiteUrl: state.bizWebsite.trim().isEmpty
            ? null
            : state.bizWebsite.trim(), // optional site
        logo: state.bizLogo, // optional logo
        banner: state.bizBanner, // optional banner
      );
      emit(
        state.copyWith(
          loading: false, // stop
          step: RegStep.done, // finished
          info: 'Registration complete', // info
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err))); // error
    }
  }
}
