import 'package:equatable/equatable.dart';

class InviteManagerState extends Equatable {
  final String email;
  final String? emailErrorCode; // 'required' | 'invalid' | null
  final bool submitting;
  final String? successMessage;
  final String? error;

  const InviteManagerState({
    this.email = '',
    this.emailErrorCode,
    this.submitting = false,
    this.successMessage,
    this.error,
  });

  bool get isValid => emailErrorCode == null && email.trim().isNotEmpty;

  InviteManagerState copyWith({
    String? email,
    String? emailErrorCode,
    bool? submitting,
    String? successMessage,
    String? error,
  }) {
    return InviteManagerState(
      email: email ?? this.email,
      emailErrorCode: emailErrorCode,
      submitting: submitting ?? this.submitting,
      successMessage: successMessage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    email,
    emailErrorCode,
    submitting,
    successMessage,
    error,
  ];
}

String? validateEmailCode(String email) {
  final v = email.trim();
  if (v.isEmpty) return 'required';
  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return re.hasMatch(v) ? null : 'invalid';
}
