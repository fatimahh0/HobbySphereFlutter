import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs, Routes;
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/services/token_store.dart';
import 'package:hobby_sphere/core/business/business_context.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import 'package:hobby_sphere/features/authentication/data/services/auth_service.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_user_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_user_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_business_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_business_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/login_google.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login/reactivate_account.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

import '../widgets/role_selector.dart';
import '../widgets/phone_input.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/primary_actions.dart';
import '../widgets/google_button.dart';
import '../widgets/register_footer.dart';

import 'package:hobby_sphere/core/auth/google_oauth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepositoryImpl(AuthService());
    return BlocProvider(
      create: (_) => LoginBloc(
        loginUserEmail: LoginUserWithEmail(repo),
        loginUserPhone: LoginUserWithPhone(repo),
        loginBizEmail: LoginBusinessWithEmail(repo),
        loginBizPhone: LoginBusinessWithPhone(repo),
        loginGoogle: LoginWithGoogle(repo),
        reactivateAccount: ReactivateAccount(repo),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();
  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  final _gsi = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: kGoogleWebClientId, // <-- use WEB client ID here
  );

  bool _reactivateOpen = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final bloc = context.read<LoginBloc>();
    if (bloc.state.roleIndex == 1) {
      showTopToast(
        context,
        'Google sign-in is for users only',
        type: ToastType.info,
      );
      return;
    }
    try {
      final acct = await _gsi.signIn();
      if (acct == null) {
        showTopToast(context, 'Google sign-in canceled', type: ToastType.info);
        return;
      }
      final auth = await acct.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        showTopToast(
          context,
          'Missing Google ID token (check Web client ID & SHA-1/SHA-256).',
          type: ToastType.error,
          haptics: true,
        );
        return;
      }
      bloc.add(LoginGooglePressed(idToken));
    } catch (e) {
      showTopToast(
        context,
        'Google sign-in failed: $e',
        type: ToastType.error,
        haptics: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listenWhen: (p, c) => p != c,
        listener: (context, state) async {
          if (state.error?.isNotEmpty == true) {
            showTopToast(
              context,
              state.error!,
              type: ToastType.error,
              haptics: true,
            );
          }
          if (state.info?.isNotEmpty == true &&
              !state.showReactivate &&
              state.token.isEmpty) {
            showTopToast(context, state.info!, type: ToastType.info);
          }
          if (state.showReactivate && !_reactivateOpen) {
            _reactivateOpen = true;
            final ok = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: Text(t.loginInactiveTitle),
                content: Text(t.loginInactiveMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(t.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(t.loginContinue),
                  ),
                ],
              ),
            );
            _reactivateOpen = false;
            if (!mounted) return;
            context.read<LoginBloc>().add(
              ok == true
                  ? LoginReactivateConfirmed()
                  : LoginReactivateDismissed(),
            );
          }
          if (state.token.isNotEmpty) {
            g.appDio?.options.headers['Authorization'] =
                'Bearer ${state.token}';
            await TokenStore.save(
              token: state.token,
              role: state.roleIndex == 1 ? 'business' : 'user',
            );
            if (state.roleIndex == 1 && state.businessId > 0) {
              await BusinessContext.set(state.businessId);
            }
            if (!mounted) return;
            final appRole = state.roleIndex == 1
                ? AppRole.business
                : AppRole.user;
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/shell',
              (r) => false,
              arguments: ShellRouteArgs(
                role: appRole,
                token: state.token,
                businessId: state.businessId,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>();
          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Logo(),
                      const SizedBox(height: 24),
                      Text(
                        t.loginTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onBackground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.loginInstruction,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            .75,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RoleSelector(
                        value: state.roleIndex,
                        onChanged: (i) => bloc.add(LoginRoleChanged(i)),
                      ),
                      const SizedBox(height: 24),
                      if (state.usePhone)
                        PhoneInput(
                          initialIso: 'CA',
                          submittedOnce: false,
                          onChanged: (e164, _, __) =>
                              bloc.add(LoginPhoneChanged(e164)),
                          onSwapToEmail: () => bloc.add(LoginToggleMethod()),
                        )
                      else
                        EmailInput(
                          controller: _emailCtrl,
                          validator: (_) => null,
                          onSwapToPhone: () => bloc.add(LoginToggleMethod()),
                        ),
                      const SizedBox(height: 8),
                      PasswordInput(
                        controller: _pwdCtrl,
                        obscure: true,
                        onToggleObscure: () {},
                      ),
                      const SizedBox(height: 12),
                      PrimaryActions(
                        onLogin: () {
                          bloc.add(LoginEmailChanged(_emailCtrl.text.trim()));
                          bloc.add(LoginPasswordChanged(_pwdCtrl.text.trim()));
                          bloc.add(LoginSubmitted());
                        },
                        onForgot: () => showTopToast(
                          context,
                          'coming soon',
                          type: ToastType.info,
                        ),
                      ),
                      if (state.roleIndex == 0) ...[
                        const SizedBox(height: 8),
                        GoogleButton(onPressed: () => _handleGoogle(context)),
                      ],
                      const SizedBox(height: 16),
                      RegisterFooter(
                        onRegister: () =>
                            Navigator.of(context).pushNamed(Routes.register),
                      ),
                    ],
                  ),
                ),
                if (state.loading)
                  Container(
                    color: Colors.black.withOpacity(.12),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/Logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            'HS',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );
  }
}
