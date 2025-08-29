import 'package:flutter/foundation.dart';

class LoginState {
  final int roleIndex; // 0 user / 1 business
  final bool usePhone;
  final bool obscure;
  final bool loading;

  const LoginState({
    this.roleIndex = 0,
    this.usePhone = true,
    this.obscure = true,
    this.loading = false,
  });

  LoginState copyWith({
    int? roleIndex,
    bool? usePhone,
    bool? obscure,
    bool? loading,
  }) => LoginState(
    roleIndex: roleIndex ?? this.roleIndex,
    usePhone: usePhone ?? this.usePhone,
    obscure: obscure ?? this.obscure,
    loading: loading ?? this.loading,
  );
}

class LoginController extends ChangeNotifier {
  LoginState _state = const LoginState();
  LoginState get state => _state;

  void setRole(int i) { _state = _state.copyWith(roleIndex: i); notifyListeners(); }
  void toggleUsePhone() { _state = _state.copyWith(usePhone: !state.usePhone); notifyListeners(); }
  void toggleObscure() { _state = _state.copyWith(obscure: !state.obscure); notifyListeners(); }
  void setLoading(bool v) { _state = _state.copyWith(loading: v); notifyListeners(); }
}
