import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
import '../../../domain/usecases/register/get_activity_types.dart';

import 'register_event.dart';
import 'register_state.dart';

String _friendlyError(Object err) {
  // Dio 5.x
  if (err is DioException) {
    final res = err.response;
    final data = res?.data;

    // server returned a json body with an error/message
    if (data is Map) {
      final msg = (data['error'] ?? data['message'] ?? data['detail']);
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    // sometimes backend sends plain string body
    if (data is String && data.trim().isNotEmpty) return data.trim();

    // fallback by status code
    final code = res?.statusCode ?? 0;
    if (code == 409) return 'Username already in use';
    if (code == 400) return 'Something went wrong';
    if (code == 401) return 'Unauthorized';
    if (code == 403) return 'Forbidden';
    if (code == 404) return 'Not found';
    if (code >= 500) return 'Server error, please try again';

    return err.message ?? 'Something went wrong';
  }
  if (err is HttpException) return err.message;
  return 'Something went wrong';
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  // usecases
  final SendUserVerification sendUserVerification;
  final VerifyUserEmailCode verifyUserEmail;
  final VerifyUserPhoneCode verifyUserPhone;
  final CompleteUserProfile completeUser;
  final AddUserInterests addInterests;
  final ResendUserCode resendUser;

  final SendBusinessVerification sendBizVerification;
  final VerifyBusinessEmailCode verifyBizEmail;
  final VerifyBusinessPhoneCode verifyBizPhone;
  final CompleteBusinessProfile completeBiz;
  final ResendBusinessCode resendBiz;

  final GetActivityTypes getActivityTypes;

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
    // reducers
    on<RegRoleChanged>(
      (e, emit) => emit(
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
        state.copyWith(usePhone: !state.usePhone, error: null, info: null),
      ),
    );
    on<RegEmailChanged>((e, emit) => emit(state.copyWith(email: e.v)));
    on<RegPhoneChanged>((e, emit) => emit(state.copyWith(phone: e.v)));
    on<RegPasswordChanged>((e, emit) => emit(state.copyWith(password: e.v)));
    on<RegCodeChanged>((e, emit) => emit(state.copyWith(code: e.v)));
    on<RegFirstNameChanged>((e, emit) => emit(state.copyWith(firstName: e.v)));
    on<RegLastNameChanged>((e, emit) => emit(state.copyWith(lastName: e.v)));
    on<RegUsernameChanged>((e, emit) => emit(state.copyWith(username: e.v)));
    on<RegUserPublicToggled>(
      (e, emit) => emit(state.copyWith(userPublic: e.v)),
    );
    on<RegPickUserImage>((e, emit) => emit(state.copyWith(userImage: e.f)));
    on<RegBusinessNameChanged>((e, emit) => emit(state.copyWith(bizName: e.v)));
    on<RegBusinessDescChanged>((e, emit) => emit(state.copyWith(bizDesc: e.v)));
    on<RegBusinessWebsiteChanged>(
      (e, emit) => emit(state.copyWith(bizWebsite: e.v)),
    );
    on<RegPickBusinessLogo>((e, emit) => emit(state.copyWith(bizLogo: e.f)));
    on<RegPickBusinessBanner>(
      (e, emit) => emit(state.copyWith(bizBanner: e.f)),
    );
    on<RegToggleInterest>((e, emit) {
      final s = {...state.interests};
      s.contains(e.id) ? s.remove(e.id) : s.add(e.id);
      emit(state.copyWith(interests: s));
    });

    // fetch interests (remote)
    on<RegFetchInterests>((e, emit) async {
      emit(state.copyWith(interestsLoading: true, interestsError: null));
      try {
        final items = await getActivityTypes();
        emit(
          state.copyWith(
            interestOptions: items,
            interestsLoading: false,
            interestsError: null,
          ),
        );
      } catch (err) {
        emit(
          state.copyWith(
            interestsLoading: false,
            interestsError: _friendlyError(err),
          ),
        );
      }
    });

    // actions
    on<RegSendVerification>(_sendVerification);
    on<RegResendCode>(_resend);
    on<RegVerifyCode>(_verifyCode);
    on<RegSubmitUserProfile>(_submitUserProfile);
    on<RegSubmitInterests>(_submitInterests);
    on<RegSubmitBusinessProfile>(_submitBusinessProfile);
  }

  Future<void> _sendVerification(
    RegSendVerification e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      if (state.roleIndex == 0) {
        await sendUserVerification(
          email: state.usePhone ? null : state.email.trim(),
          phone: state.usePhone ? state.phone.trim() : null,
          password: state.password.trim(),
        );
      } else {
        final id = await sendBizVerification(
          email: state.usePhone ? null : state.email.trim(),
          phone: state.usePhone ? state.phone.trim() : null,
          password: state.password.trim(),
        );
        emit(state.copyWith(pendingId: id));
      }
      emit(
        state.copyWith(
          loading: false,
          step: RegStep.code,
          info: 'Verification code sent',
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err)));
    }
  }

  Future<void> _resend(RegResendCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      final contact = state.usePhone ? state.phone.trim() : state.email.trim();
      if (state.roleIndex == 0) {
        await resendUser(contact);
      } else {
        await resendBiz(contact);
      }
      emit(state.copyWith(loading: false, info: 'Code resent'));
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err)));
    }
  }

  Future<void> _verifyCode(RegVerifyCode e, Emitter<RegisterState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      if (state.roleIndex == 0) {
        final id = state.usePhone
            ? await verifyUserPhone(state.phone.trim(), state.code.trim())
            : await verifyUserEmail(state.email.trim(), state.code.trim());
        emit(state.copyWith(loading: false, pendingId: id, step: RegStep.name));
      } else {
        final id = state.pendingId != 0
            ? state.pendingId
            : (state.usePhone
                  ? await verifyBizPhone(state.phone.trim(), state.code.trim())
                  : await verifyBizEmail(
                      state.email.trim(),
                      state.code.trim(),
                    ));
        emit(
          state.copyWith(loading: false, pendingId: id, step: RegStep.bizName),
        );
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err)));
    }
  }

  Future<void> _submitUserProfile(
    RegSubmitUserProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await completeUser(
        pendingId: state.pendingId,
        username: state.username.trim(),
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        isPublic: state.userPublic,
        image: state.userImage,
      );
      emit(state.copyWith(loading: false, step: RegStep.interests));
    } catch (err) {
      final msg = _friendlyError(err);

      final shouldBackToUsername = msg.toLowerCase().contains('username');
      emit(
        state.copyWith(
          loading: false,
          error: msg,
          step: shouldBackToUsername ? RegStep.username : state.step,
        ),
      );
    }
  }

  Future<void> _submitInterests(
    RegSubmitInterests e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await addInterests(state.pendingId, state.interests.toList());
      emit(
        state.copyWith(
          loading: false,
          step: RegStep.done,
          info: 'Registration complete',
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err)));
    }
  }

  Future<void> _submitBusinessProfile(
    RegSubmitBusinessProfile e,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await completeBiz(
        pendingId: state.pendingId,
        name: state.bizName.trim(),
        description: state.bizDesc.trim().isEmpty ? null : state.bizDesc.trim(),
        websiteUrl: state.bizWebsite.trim().isEmpty
            ? null
            : state.bizWebsite.trim(),
        logo: state.bizLogo,
        banner: state.bizBanner,
      );
      emit(
        state.copyWith(
          loading: false,
          step: RegStep.done,
          info: 'Registration complete',
        ),
      );
    } catch (err) {
      emit(state.copyWith(loading: false, error: _friendlyError(err)));
    }
  }
}
