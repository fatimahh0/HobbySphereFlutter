// Flutter 3.35.x — Login (go_router version)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // ✅ go_router
import 'package:google_sign_in/google_sign_in.dart';

import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;
import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs, Routes;
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/screens/forgot_password_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/token_store.dart';
import 'package:hobby_sphere/core/business/business_context.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/phone_input.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import 'package:hobby_sphere/features/authentication/login&register/data/services/auth_service.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/auth_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_user_email.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_user_phone.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_business_email.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_business_phone.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_google.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/reactivate_account.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

import '../widgets/role_selector.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/primary_actions.dart';
import '../widgets/google_button.dart';
import '../widgets/register_footer.dart';

import 'package:hobby_sphere/core/auth/google_oauth.dart'; // kGoogleWebClientId

Map<String, dynamic> _decodeJwtPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return {};
  try {
    final p = base64Url.normalize(parts[1]);
    final jsonStr = utf8.decode(base64Url.decode(p));
    final map = json.decode(jsonStr);
    return map is Map ? Map<String, dynamic>.from(map) : {};
  } catch (_) {
    return {};
  }
}

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
  bool _pwdObscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  final _gsi = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: kGoogleWebClientId,
  );

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
      await _gsi.signOut();
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
          'Missing Google ID token.',
          type: ToastType.error,
          haptics: true,
        );
        return;
      }
      final payload = _decodeJwtPayload(idToken);
      if (payload['aud'] != kGoogleWebClientId) {
        showTopToast(
          context,
          'Token audience mismatch.',
          type: ToastType.error,
          haptics: true,
        );
        return;
      }
      if (payload['email_verified'] == false) {
        showTopToast(
          context,
          'Google email not verified',
          type: ToastType.error,
        );
        return;
      }
      bloc.add(LoginGooglePressed(idToken));
    } on PlatformException catch (e) {
      showTopToast(
        context,
        'PlatformException code=${e.code}\n${e.message}\n${e.details}',
        type: ToastType.error,
        haptics: true,
      );
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

          // ✅ single success path
          if (state.token.isNotEmpty) {
            // attach token
            g.appDio?.options.headers['Authorization'] =
                'Bearer ${state.token}';
            g.token = state.token;
            await TokenStore.save(
              token: state.token,
              role: state.roleIndex == 1 ? 'business' : 'user',
            );
            if (state.roleIndex == 1 && state.businessId > 0) {
              await BusinessContext.set(state.businessId);
            }
            // optional: start realtime only for users
            if (state.roleIndex == 0) {
              await rt.startUserRealtime();
            }
            if (!mounted) return;

            final role = state.roleIndex == 1 ? AppRole.business : AppRole.user;

            // 🔁 use go_router by name, pass args via `extra`
            context.goNamed(
              Routes.shell,
              extra: ShellRouteArgs(
                role: role,
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
                        obscure: _pwdObscure,
                        onToggleObscure: () =>
                            setState(() => _pwdObscure = !_pwdObscure),
                      ),

                      const SizedBox(height: 12),

                      PrimaryActions(
                        onLogin: () {
                          bloc.add(LoginEmailChanged(_emailCtrl.text.trim()));
                          bloc.add(LoginPasswordChanged(_pwdCtrl.text.trim()));
                          bloc.add(LoginSubmitted());
                        },
                        onForgot: () {
                          final isBusiness =
                              context.read<LoginBloc>().state.roleIndex == 1;
                          context.pushNamed(
                            Routes.forgot, // ✅ go_router
                            extra: ForgotPasswordArgs(isBusiness: isBusiness),
                          );
                        },
                      ),

                      if (state.roleIndex == 0) ...[
                        const SizedBox(height: 8),
                        GoogleButton(onPressed: () => _handleGoogle(context)),
                      ],

                      const SizedBox(height: 16),

                      RegisterFooter(
                        onRegister: () =>
                            context.pushNamed(Routes.register), // ✅ go_router
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
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double size = 140;

    Widget circle(Widget child) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.10),
        shape: BoxShape.circle,
      ),
      child: ClipOval(child: child),
    );

    final url = g.appLogoUrlResolved.trim();
    final hasUrl = url.isNotEmpty;

    if (hasUrl) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          circle(
            Image.network(
              url,
              fit: BoxFit.cover,
              // lightweight placeholder while loading
              loadingBuilder: (context, child, evt) {
                if (evt == null) return child;
                return Container(color: cs.surfaceVariant.withOpacity(.5));
              },
              // if the URL fails → fallback to asset, then initials
              errorBuilder: (_, __, ___) => _assetOrInitials(context),
              // crisper rasterization
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
              cacheHeight: (size * MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            g.appName.isNotEmpty ? g.appName : 'Hobby Sphere',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // No URL → asset or initials
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle(_assetOrInitials(context)),
        const SizedBox(height: 10),
        Text(
          g.appName.isNotEmpty ? g.appName : 'Hobby Sphere',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _assetOrInitials(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Image.asset(
      'assets/images/Logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          _initialsOf(g.appName),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }

  String _initialsOf(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 'BA';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1).toString() +
            parts.last.characters.take(1).toString())
        .toUpperCase();
  }
}
