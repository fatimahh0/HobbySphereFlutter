import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/authentication/domain/entities/auth_result.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_business_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_business_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_user_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_user_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_google.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/reactivate_account.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUserWithEmail loginUserEmail;
  final LoginUserWithPhone loginUserPhone;
  final LoginBusinessWithEmail loginBizEmail;
  final LoginBusinessWithPhone loginBizPhone;
  final LoginWithGoogle loginGoogle;
  final ReactivateAccount reactivateAccount;

  LoginBloc({
    required this.loginUserEmail,
    required this.loginUserPhone,
    required this.loginBizEmail,
    required this.loginBizPhone,
    required this.loginGoogle,
    required this.reactivateAccount,
  }) : super(const LoginState()) {
    on<LoginRoleChanged>(
      (e, emit) => emit(
        state.copyWith(
          roleIndex: e.index,
          showReactivate: false,
          info: null,
          error: null,
        ),
      ),
    );
    on<LoginToggleMethod>(
      (e, emit) => emit(
        state.copyWith(
          usePhone: !state.usePhone,
          showReactivate: false,
          info: null,
          error: null,
        ),
      ),
    );
    on<LoginEmailChanged>(
      (e, emit) => emit(
        state.copyWith(
          email: e.email,
          showReactivate: false,
          info: null,
          error: null,
        ),
      ),
    );
    on<LoginPhoneChanged>(
      (e, emit) => emit(
        state.copyWith(
          phoneE164: e.phoneE164,
          showReactivate: false,
          info: null,
          error: null,
        ),
      ),
    );
    on<LoginPasswordChanged>(
      (e, emit) => emit(state.copyWith(password: e.password)),
    );
    on<LoginReactivateDismissed>(
      (e, emit) => emit(
        state.copyWith(showReactivate: false, reactivateId: 0, info: null),
      ),
    );

    on<LoginSubmitted>(_onSubmit);
    on<LoginReactivateConfirmed>(_onReactivate);
    on<LoginGooglePressed>(_onGoogle); // important: this event carries idToken
  }

  Future<void> _onSubmit(LoginSubmitted e, Emitter<LoginState> emit) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        info: null,
        showReactivate: false,
      ),
    );
    final isUser = state.roleIndex == 0;
    late AuthResult r;

    try {
      if (isUser) {
        r = state.usePhone
            ? await loginUserPhone(
                state.phoneE164.trim(),
                state.password.trim(),
              )
            : await loginUserEmail(state.email.trim(), state.password.trim());
      } else {
        r = state.usePhone
            ? await loginBizPhone(state.phoneE164.trim(), state.password.trim())
            : await loginBizEmail(state.email.trim(), state.password.trim());
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: 'Login failed: $err'));
      return;
    }

    if (r.wasInactive) {
      emit(
        state.copyWith(
          loading: false,
          showReactivate: true,
          reactivateId: r.subjectId,
          reactivateRole: r.role,
          info: r.message ?? 'Account inactive. Reactivate?',
        ),
      );
      return;
    }

    if (r.error?.isNotEmpty == true) {
      emit(state.copyWith(loading: false, error: r.error));
      return;
    }

    emit(
      state.copyWith(
        loading: false,
        token: r.token,
        businessId: r.businessId,
        info: r.message ?? 'Login successful',
      ),
    );
  }

  Future<void> _onGoogle(LoginGooglePressed e, Emitter<LoginState> emit) async {
    emit(state.copyWith(loading: true, error: null, info: null));
    try {
      final r = await loginGoogle(e.idToken); // pass the Google idToken
      if (r.wasInactive) {
        emit(
          state.copyWith(
            loading: false,
            showReactivate: true,
            reactivateId: r.subjectId,
            reactivateRole: r.role,
            info: r.message ?? 'Account inactive. Reactivate?',
          ),
        );
      } else if (r.error?.isNotEmpty == true) {
        emit(state.copyWith(loading: false, error: r.error));
      } else {
        emit(
          state.copyWith(
            loading: false,
            token: r.token,
            businessId: r.businessId,
            info: r.message ?? 'Google login successful',
          ),
        );
      }
    } catch (err) {
      emit(
        state.copyWith(loading: false, error: 'Google sign-in failed: $err'),
      );
    }
  }

  Future<void> _onReactivate(
    LoginReactivateConfirmed e,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final r = await reactivateAccount(
        id: state.reactivateId,
        role: state.reactivateRole,
      );
      if (r.error?.isNotEmpty == true) {
        emit(
          state.copyWith(
            loading: false,
            error: r.error!,
            showReactivate: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            loading: false,
            showReactivate: false,
            token: r.token,
            businessId: r.businessId,
            info: r.message ?? 'Account reactivated',
          ),
        );
      }
    } catch (err) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Reactivation failed: $err',
          showReactivate: false,
        ),
      );
    }
  }
}
