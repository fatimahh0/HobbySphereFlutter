// lib/features/authentication/presentation/login/screen/login_page.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/utils/validators_auto.dart';
import 'package:hobby_sphere/app/router/router.dart' show ShellRouteArgs;
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/services/token_store.dart';
import 'package:hobby_sphere/core/business/business_context.dart';

import 'package:hobby_sphere/features/authentication/domain/entities/auth_result.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login_user_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login_user_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login_business_email.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login_business_phone.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/login_google.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/auth_service.dart';

import '../widgets/role_selector.dart';
import '../widgets/phone_input.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/primary_actions.dart';
import '../widgets/google_button.dart';
import '../widgets/register_footer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  int _roleIndex = 0; // 0 user / 1 business
  bool _usePhone = true;
  bool _obscure = true;
  bool _loading = false;
  bool _submittedOnce = false;

  String _initialIso = 'CA';
  String? _phoneE164;
  String? _nationalDisplay;

  late final AuthRepositoryImpl _repo;
  late final LoginUserWithEmail _loginUserEmail;
  late final LoginUserWithPhone _loginUserPhone;
  late final LoginBusinessWithEmail _loginBizEmail;
  late final LoginBusinessWithPhone _loginBizPhone;
  late final LoginWithGoogle _loginGoogle;
  final _gsi = GoogleSignIn(scopes: ['email']);

  @override
  void initState() {
    super.initState();
    _repo = AuthRepositoryImpl(AuthService());
    _loginUserEmail = LoginUserWithEmail(_repo);
    _loginUserPhone = LoginUserWithPhone(_repo);
    _loginBizEmail = LoginBusinessWithEmail(_repo);
    _loginBizPhone = LoginBusinessWithPhone(_repo);
    _loginGoogle = LoginWithGoogle(_repo);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _setLoading(bool v) => setState(() => _loading = v);

  String? _validateEmail(String? v) => validateEmailAuto(
    input: v,
    allowedDomains: {
      'gmail.com',
      'hotmail.com',
      'outlook.com',
      'yahoo.com',
      'icloud.com',
      'live.com',
      'msn.com',
    },
  );

  Future<void> _handleLoginResult(AuthResult r) async {
    final t = AppLocalizations.of(context)!;
    if (!r.ok) {
      final msg = r.error?.isNotEmpty == true
          ? r.error!
          : (r.message ?? t.loginErrorFailed);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    g.appDio?.options.headers['Authorization'] = 'Bearer ${r.token}';
    await TokenStore.save(token: r.token, role: r.role);
    if (r.role == 'business' && r.businessId > 0) {
      await BusinessContext.set(r.businessId);
    }
    if (!mounted) return;
    final appRole = r.role == 'business' ? AppRole.business : AppRole.user;
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/shell',
      (rte) => false,
      arguments: ShellRouteArgs(
        role: appRole,
        token: r.token,
        businessId: r.businessId,
      ),
    );
  }

  Future<void> _submit() async {
    _submittedOnce = true;
    final t = AppLocalizations.of(context)!;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.loginErrorRequired)));
      return;
    }
    final role = _roleIndex == 1 ? 'business' : 'user';
    if (_usePhone && (_phoneE164 == null || _phoneE164!.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.loginPhone)));
      return;
    }
    _setLoading(true);
    try {
      late AuthResult res;
      if (role == 'user') {
        res = _usePhone
            ? await _loginUserPhone(_phoneE164!.trim(), _pwdCtrl.text.trim())
            : await _loginUserEmail(
                _emailCtrl.text.trim(),
                _pwdCtrl.text.trim(),
              );
      } else {
        res = _usePhone
            ? await _loginBizPhone(_phoneE164!.trim(), _pwdCtrl.text.trim())
            : await _loginBizEmail(
                _emailCtrl.text.trim(),
                _pwdCtrl.text.trim(),
              );
      }
      await _handleLoginResult(res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t.loginErrorFailed}: $e')));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _googleSignInFlow() async {
    if (_roleIndex == 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in is for users only')),
      );
      return;
    }
    _setLoading(true);
    try {
      final acc = await _gsi.signIn();
      if (acc == null) return;
      final auth = await acc.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ID token is missing')),
        );
        return;
      }
      final res = await _loginGoogle(idToken);
      await _handleLoginResult(res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      _setLoading(false);
    }
  }

  void _toggleMode() => setState(() => _usePhone = !_usePhone);

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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Logo(),
                    const SizedBox(height: 24),
                    Text(
                      t.loginTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.loginInstruction,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          .75,
                        ),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),

                    RoleSelector(
                      value: _roleIndex,
                      onChanged: (i) => setState(() => _roleIndex = i),
                      
                    ),
                    const SizedBox(height: 24),

                    if (_usePhone)
                      PhoneInput(
                        initialIso: _initialIso,
                        onChanged: (e164, national, iso) {
                          setState(() {
                            _phoneE164 = e164;
                            _nationalDisplay = national;
                            _initialIso = iso;
                          });
                          if (_submittedOnce) _formKey.currentState?.validate();
                        },
                        onSwapToEmail: _toggleMode,
                        submittedOnce: _submittedOnce,
                      )
                    else
                      EmailInput(
                        controller: _emailCtrl,
                        validator: _validateEmail,
                        onSwapToPhone: _toggleMode,
                      ),

                    const SizedBox(height: 8),
                    PasswordInput(
                      controller: _pwdCtrl,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 12),

                    PrimaryActions(
                      onLogin: _submit,
                      onForgot: () {}, // TODO
                    ),

                    if (_roleIndex == 0) ...[
                      const SizedBox(height: 8),
                      GoogleButton(onPressed: _googleSignInFlow),
                    ],

                    const SizedBox(height: 16),
                    RegisterFooter(onRegister: () {}), // TODO
                  ],
                ),
              ),
            ),
          ),

          if (_loading) const _LoadingOverlay(),
        ],
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.12),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
