// Flutter 3.35.x — simple, clean, and professional.
// Forgot password (email) with role toggle, resend timer, and safe guards.

import 'dart:async'; // Timer for resend countdown
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // TextInputFormatter
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc

import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_bloc.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_event.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_state.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // AppTextField
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'
    show AppPasswordField; // password field

// DI
import '../../data/services/forgot_service.dart'; // service
import '../../data/repositories/forgot_repository_impl.dart'; // repo impl
import '../../domain/usecases/send_reset_code.dart'; // uc
import '../../domain/usecases/verify_reset_code.dart'; // uc
import '../../domain/usecases/update_password.dart'; // uc

/// Page argument to choose role (optional).
class ForgotPasswordArgs {
  final bool isBusiness; // true -> business, false -> user
  const ForgotPasswordArgs({this.isBusiness = false}); // default user
}

/// Entry widget to provide BLoC + DI.
class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordArgs? args; // role arg
  const ForgotPasswordPage({super.key, this.args}); // ctor

  @override
  Widget build(BuildContext context) {
    // services + repo + use cases
    final service = ForgotService(); // http service
    final repo = ForgotRepositoryImpl(service); // repository
    return BlocProvider(
      create: (_) => ForgotBloc(
        sendResetCode: SendResetCode(repo),
        verifyResetCode: VerifyResetCode(repo),
        updatePassword: UpdatePassword(repo),
        isBusiness: args?.isBusiness ?? false,
      ),
      child: const _ForgotView(), // render view
    );
  }
}

/// Internal stateful view for form handling.
class _ForgotView extends StatefulWidget {
  const _ForgotView();
  @override
  State<_ForgotView> createState() => _ForgotViewState();
}

class _ForgotViewState extends State<_ForgotView> {
  // controllers
  final _email = TextEditingController(); // email
  final _code = TextEditingController(); // 6-digit code
  final _pwd = TextEditingController(); // new password

  // focus
  final _emailNode = FocusNode();
  final _codeNode = FocusNode();
  final _pwdNode = FocusNode();

  // resend
  static const _resendSecs = 45; // cooldown seconds
  Timer? _resendTimer; // timer
  int _left = 0; // seconds left

  // simple email check
  bool get _emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());

  @override
  void dispose() {
    _resendTimer?.cancel(); // stop timer
    _email.dispose();
    _code.dispose();
    _pwd.dispose();
    _emailNode.dispose();
    _codeNode.dispose();
    _pwdNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel(); // reset
    setState(() => _left = _resendSecs); // start
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        setState(() => _left = 0);
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'), // title
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: BlocConsumer<ForgotBloc, ForgotState>(
        listenWhen: (p, c) => p != c,
        listener: (context, s) {
          // error toast
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            );
          }
          // info/success toast
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.success);
          }

          // when state transitions occur, nudge focus where helpful
          switch (s.step) {
            case ForgotStep.enterEmail:
              _code.clear();
              _pwd.clear();
              _resendTimer?.cancel();
              _left = 0;
              FocusScope.of(context).requestFocus(_emailNode);
              break;
            case ForgotStep.enterCode:
              // start cooldown after code is sent
              if (_left == 0) _startResendTimer();
              FocusScope.of(context).requestFocus(_codeNode);
              break;
            case ForgotStep.enterNew:
              _resendTimer?.cancel();
              _left = 0;
              FocusScope.of(context).requestFocus(_pwdNode);
              break;
          }
        },
        builder: (context, s) {
          final bloc = context.read<ForgotBloc>(); // bloc

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // role toggle
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('User'),
                          selected: !s.isBusiness,
                          onSelected: s.loading
                              ? null
                              : (v) {
                                  if (!v) return;
                                  bloc.add(ForgotRoleChanged(false));
                                },
                        ),
                        ChoiceChip(
                          label: const Text('Business'),
                          selected: s.isBusiness,
                          onSelected: s.loading
                              ? null
                              : (v) {
                                  if (!v) return;
                                  bloc.add(ForgotRoleChanged(true));
                                },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      s.step == ForgotStep.enterEmail
                          ? 'Step 1 of 3 • Enter email'
                          : s.step == ForgotStep.enterCode
                          ? 'Step 2 of 3 • Enter code'
                          : 'Step 3 of 3 • New password',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ========== Step 1: Email ==========
                    if (s.step == ForgotStep.enterEmail) ...[
                      AppTextField(
                        controller: _email,
                        focusNode: _emailNode,
                        label: 'Email',
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (!_emailValid || s.loading) return;
                          bloc.add(ForgotSendCodePressed());
                        },
                        onChanged: (v) =>
                            bloc.add(ForgotEmailChanged(v.trim())),
                        filled: true,
                        errorText: _email.text.isEmpty
                            ? null
                            : (_emailValid ? null : 'Enter a valid email'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: (s.loading || !_emailValid)
                            ? null
                            : () {
                                bloc.add(ForgotSendCodePressed());
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('Send code'),
                      ),
                    ],

                    // ========== Step 2: Code ==========
                    if (s.step == ForgotStep.enterCode) ...[
                      AppTextField(
                        controller: _email,
                        label: 'Email',
                        readOnly: true,
                        filled: true,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _code,
                        focusNode: _codeNode,
                        label: 'Code',
                        hint: '6-digit code',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        // Removed inputFormatters as it is not supported by AppTextField
                        onChanged: (v) => bloc.add(ForgotCodeChanged(v.trim())),
                        filled: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: s.loading
                                  ? null
                                  : () => bloc.add(ForgotVerifyCodePressed()),
                              icon: const Icon(Icons.verified),
                              label: const Text('Verify code'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: (s.loading || _left > 0)
                                ? null
                                : () {
                                    // allow resending and restart cooldown
                                    bloc.add(ForgotSendCodePressed());
                                    _startResendTimer();
                                  },
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              _left > 0 ? 'Resend in $_left s' : 'Resend',
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ========== Step 3: New password ==========
                    if (s.step == ForgotStep.enterNew) ...[
                      AppTextField(
                        controller: _email,
                        label: 'Email',
                        readOnly: true,
                        filled: true,
                      ),
                      const SizedBox(height: 12),
                      AppPasswordField(
                        controller: _pwd,
                        focusNode: _pwdNode,
                        label: 'New password',
                        hint: 'Enter new password',
                        onChanged: (v) =>
                            bloc.add(ForgotNewPasswordChanged(v.trim())),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: s.loading
                            ? null
                            : () {
                                bloc.add(ForgotUpdatePasswordPressed());
                              },
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Update password'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use at least 8 characters. Avoid common words.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.outline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // loading overlay
              if (s.loading)
                Container(
                  color: Colors.black.withOpacity(.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
