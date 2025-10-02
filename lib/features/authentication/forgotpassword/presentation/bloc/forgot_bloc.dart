// BLoC that orchestrates the 3-step flow.

import 'package:flutter_bloc/flutter_bloc.dart'; // bloc core
import '../../domain/usecases/send_reset_code.dart'; // uc
import '../../domain/usecases/verify_reset_code.dart'; // uc
import '../../domain/usecases/update_password.dart'; // uc
import 'forgot_event.dart'; // events
import 'forgot_state.dart'; // state

class ForgotBloc extends Bloc<ForgotEvent, ForgotState> {
  // hold the 3 use cases
  final SendResetCode sendResetCode; // UC 1
  final VerifyResetCode verifyResetCode; // UC 2
  final UpdatePassword updatePassword; // UC 3

  ForgotBloc({
    required this.sendResetCode, // inject
    required this.verifyResetCode, // inject
    required this.updatePassword, // inject
    bool isBusiness = false, // default
  }) : super(ForgotState.initial(isBusiness: isBusiness)) {
    // event: change role
    on<ForgotRoleChanged>((e, emit) {
      // set role and keep current inputs
      emit(state.copyWith(isBusiness: e.isBusiness, error: null, info: null)); // update role
    });

    // event: email text change
    on<ForgotEmailChanged>((e, emit) {
      emit(state.copyWith(email: e.email, error: null, info: null)); // update email
    });

    // event: code text change
    on<ForgotCodeChanged>((e, emit) {
      emit(state.copyWith(code: e.code, error: null, info: null)); // update code
    });

    // event: new password text change
    on<ForgotNewPasswordChanged>((e, emit) {
      emit(state.copyWith(newPassword: e.newPassword, error: null, info: null)); // update pwd
    });

    // step 1: send code
    on<ForgotSendCodePressed>((e, emit) async {
      // basic check
      if (state.email.isEmpty) {
        emit(state.copyWith(error: 'Email is required')); // show error
        return; // stop
      }
      // loading on
      emit(state.copyWith(loading: true, error: null, info: null)); // spin
      try {
        // call uc
        final r = await sendResetCode(state.email, isBusiness: state.isBusiness); // send
        // next step
        emit(state.copyWith(
          loading: false, // stop spinner
          step: ForgotStep.enterCode, // move to code
          info: r.message, // server msg
        )); // new state
      } catch (err) {
        // show error
        emit(state.copyWith(loading: false, error: '$err')); // error
      }
    });

    // step 2: verify code
    on<ForgotVerifyCodePressed>((e, emit) async {
      // validate
      if (state.code.length < 4) {
        emit(state.copyWith(error: 'Enter the code')); // simple check
        return; // stop
      }
      // loading on
      emit(state.copyWith(loading: true, error: null, info: null)); // spin
      try {
        // call uc
        final r = await verifyResetCode(state.email, state.code, isBusiness: state.isBusiness); // verify
        // next step
        emit(state.copyWith(
          loading: false, // stop
          step: ForgotStep.enterNew, // move to new pwd
          info: r.message, // msg
        )); // new state
      } catch (err) {
        // show error
        emit(state.copyWith(loading: false, error: '$err')); // error
      }
    });

    // step 3: update password
    on<ForgotUpdatePasswordPressed>((e, emit) async {
      // validate
      if (state.newPassword.length < 6) {
        emit(state.copyWith(error: 'Password must be at least 6 chars')); // rule
        return; // stop
      }
      // loading on
      emit(state.copyWith(loading: true, error: null, info: null)); // spin
      try {
        // call uc
        final r = await updatePassword(state.email, state.newPassword, isBusiness: state.isBusiness); // update
        // finish (stay on same screen with info)
        emit(state.copyWith(
          loading: false, // stop
          info: r.message, // success
        )); // new state
      } catch (err) {
        // show error
        emit(state.copyWith(loading: false, error: '$err')); // error
      }
    });
  }
}
