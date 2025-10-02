// State for the forgot-flow.

import 'package:meta/meta.dart'; // annotations

/// Small enum for steps in the UI.
enum ForgotStep { enterEmail, enterCode, enterNew } // 3 steps

@immutable // state is immutable
class ForgotState {
  // whether business role is selected
  final bool isBusiness; // role switch
  // current step (email -> code -> new)
  final ForgotStep step; // current step
  // form values
  final String email; // email
  final String code; // 6 digits
  final String newPassword; // new pwd
  // ui flags
  final bool loading; // show spinner
  final String? error; // error text
  final String? info; // info text

  const ForgotState({
    required this.isBusiness,
    required this.step,
    required this.email,
    required this.code,
    required this.newPassword,
    required this.loading,
    this.error,
    this.info,
  }); // ctor

  // initial state helper
  factory ForgotState.initial({bool isBusiness = false}) => ForgotState(
        isBusiness: isBusiness, // default user
        step: ForgotStep.enterEmail, // start at email
        email: '', // empty
        code: '', // empty
        newPassword: '', // empty
        loading: false, // not loading
      ); // initial

  // copy with updates
  ForgotState copyWith({
    bool? isBusiness,
    ForgotStep? step,
    String? email,
    String? code,
    String? newPassword,
    bool? loading,
    String? error,
    String? info,
  }) {
    return ForgotState(
      isBusiness: isBusiness ?? this.isBusiness, // keep or set
      step: step ?? this.step, // keep or set
      email: email ?? this.email, // keep or set
      code: code ?? this.code, // keep or set
      newPassword: newPassword ?? this.newPassword, // keep or set
      loading: loading ?? this.loading, // keep or set
      error: error, // replace (can be null)
      info: info, // replace (can be null)
    ); // new state
  }
}
