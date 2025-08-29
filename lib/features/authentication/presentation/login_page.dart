// ===== Flutter 3.35.x =====
// login_page.dart — Full login with backend + Google Sign-In.

import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/core/constants/app_role.dart'; // enum
import 'package:hobby_sphere/core/network/globals.dart' as g; // Dio
import 'package:hobby_sphere/features/activities/data/services/common/auth_service.dart'; // auth API
import 'package:intl_phone_field/intl_phone_field.dart'; // phone
import 'package:intl_phone_field/country_picker_dialog.dart'; // picker
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // btn
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // input
import 'package:hobby_sphere/shared/utils/validators_auto.dart'; // email val

import 'package:google_sign_in/google_sign_in.dart'; // GSI
import 'package:hobby_sphere/services/token_store.dart'; // save token
import 'package:hobby_sphere/core/network/api_client.dart'; // bearer
import 'package:hobby_sphere/app/router/router.dart' show ShellRouteArgs; // args
import 'package:shared_preferences/shared_preferences.dart'; // prefs
import 'package:hobby_sphere/core/business/business_context.dart'; // 👈 NEW

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController(); // email txt
  final _pwdCtrl = TextEditingController(); // pwd txt
  final _formKey = GlobalKey<FormState>(); // form key

  int _roleIndex = 0; // 0 user/1 biz
  bool _usePhone = true; // phone mode
  bool _obscure = true; // hide pwd
  bool _loading = false; // overlay
  bool _submittedOnce = false; // tried

  String _initialIso = 'CA'; // ISO2
  String? _phoneE164; // +E.164
  String? _nationalDisplay; // local num

  final _auth = AuthService(); // service
  final _gsi = GoogleSignIn(scopes: ['email']); // google

  double _clamp(double v, double a, double b) =>
      v < a ? a : (v > b ? b : v); // clamp util
  void _setLoading(bool v) => setState(() => _loading = v); // toggle

  void _goHomeByRole({
    required String role, // "user"/"business"
    required String token, // JWT
    required int businessId, // id (0 ok)
  }) {
    if (!mounted) return; // guard
    final appRole = (role == 'business')
        ? AppRole.business
        : AppRole.user; // map
    Navigator.of(context).pushNamedAndRemoveUntil(
      // to shell
      '/shell',
      (r) => false,
      arguments: ShellRouteArgs(
        role: appRole,
        token: token,
        businessId: businessId,
      ),
    );
  }

  String? _validateEmail(String? v) => validateEmailAuto(
    // email val
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

  @override
  void dispose() {
    _emailCtrl.dispose(); // clean
    _pwdCtrl.dispose(); // clean
    super.dispose();
  }

  Future<void> _handleLoginResponse(
    Map<String, dynamic> res, // response
    String role, // role str
  ) async {
    final t = AppLocalizations.of(context)!; // i18n

    if (res['error'] != null) {
      // backend error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${res['error']}')));
      return;
    }

    final int status = res['_status'] is int
        ? res['_status'] as int
        : 200; // code

    // normal success → must have token
    final token = '${res['token'] ?? res['jwt'] ?? ''}'.trim(); // token str
    if (token.isNotEmpty) {
      g.appDio?.options.headers['Authorization'] = 'Bearer $token'; // bearer
      await TokenStore.save(token: token, role: role); // persist

      // extract businessId (for business role)
      final int businessId = switch (role) {
        'business' => (() {
          final b = res['business'] ?? res; // nested or root
          final id = (b is Map && b['id'] != null)
              ? b['id']
              : (res['businessId'] ?? res['id'] ?? res['userId']); // fallbacks
          return (id is int) ? id : int.tryParse('$id') ?? 0; // to int
        })(),
        _ => 0, // user
      };

      if (role == 'business' && businessId > 0) {
        await BusinessContext.set(businessId); // 👈 save id
      }

      if (mounted) {
        _goHomeByRole(
          // go to shell
          role: role,
          token: token,
          businessId: businessId,
        );
      }
      return;
    }

    // token missing → show message
    final msg = '${res['message'] ?? t.loginErrorFailed}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$msg ($status)')));
  }

  Future<void> _submit() async {
    _submittedOnce = true; // tried submit
    final t = AppLocalizations.of(context)!; // i18n
    final ok = _formKey.currentState?.validate() ?? false; // validate
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.loginErrorRequired)));
      return;
    }

    final role = _roleIndex == 1 ? 'business' : 'user'; // role str
    if (_usePhone && (_phoneE164 == null || _phoneE164!.trim().isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.loginPhone)));
      return;
    }

    _setLoading(true); // show loader
    try {
      Map<String, dynamic> res; // response

      if (role == 'user') {
        res = _usePhone
            ? await _auth.loginWithPhonePassword(
                phoneNumber: _phoneE164!,
                password: _pwdCtrl.text.trim(),
              )
            : await _auth.loginWithEmailPassword(
                email: _emailCtrl.text.trim(),
                password: _pwdCtrl.text.trim(),
              );
      } else {
        res = _usePhone
            ? await _auth.loginBusinessWithPhone(
                phoneNumber: _phoneE164!,
                password: _pwdCtrl.text.trim(),
              )
            : await _auth.loginBusiness(
                email: _emailCtrl.text.trim(),
                password: _pwdCtrl.text.trim(),
              );
      }

      // optional debug print:
      // print('Login response: $res');

      await _handleLoginResponse(res, role); // handle
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t.loginErrorFailed}: $e')));
    } finally {
      _setLoading(false); // hide loader
    }
  }

  Future<void> _googleSignInFlow() async {
    if (_roleIndex == 1) {
      // block for biz
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in is for users only')),
      );
      return;
    }

    _setLoading(true);
    try {
      final acc = await _gsi.signIn(); // pick account
      if (acc == null) return; // cancelled
      final auth = await acc.authentication; // tokens
      final idToken = auth.idToken; // ID token
      if (idToken == null || idToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ID token is missing')),
        );
        return;
      }
      final res = await _auth.loginWithGoogle(idToken); // backend
      await _handleLoginResponse(res, 'user'); // treat as user
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      _setLoading(false);
    }
  }

  void _toggleMode() => setState(() => _usePhone = !_usePhone); // swap mode

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // scheme
    final size = MediaQuery.sizeOf(context); // screen
    final w = size.width, h = size.height; // dims

    final side = _clamp(w * 0.06, 16, 28); // paddings
    final logoDia = _clamp(w * 0.34, 110, 160); // logo size
    final pillH = _clamp(h * 0.052, 38, 48); // pill h
    final pillR = _clamp(w * 0.06, 18, 28); // pill r
    final gapS = _clamp(h * 0.012, 8, 14); // gap s
    final gapM = _clamp(h * 0.02, 12, 22); // gap m
    final gapL = _clamp(h * 0.03, 18, 30); // gap l

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, 8, side, side),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // logo
                      width: logoDia,
                      height: logoDia,
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
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: gapL),
                    Text(
                      // title
                      t.loginTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: .2,
                      ),
                    ),
                    SizedBox(height: _clamp(h * 0.006, 4, 8)),
                    Text(
                      // sub
                      t.loginInstruction,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          .75,
                        ),
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: gapM),
                    Row(
                      // role pills
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RolePill(
                          label: t.loginUser,
                          selected: _roleIndex == 0,
                          height: pillH,
                          radius: pillR,
                          onTap: () => setState(() => _roleIndex = 0),
                        ),
                        SizedBox(width: _clamp(w * 0.03, 10, 16)),
                        _RolePill(
                          label: t.loginBusiness,
                          selected: _roleIndex == 1,
                          height: pillH,
                          radius: pillR,
                          onTap: () => setState(() => _roleIndex = 1),
                        ),
                      ],
                    ),
                    SizedBox(height: gapL),
                    if (_usePhone) ...[
                      Material(
                        // phone input
                        color: cs.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                          side: BorderSide(color: cs.outlineVariant, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: IntlPhoneField(
                            initialCountryCode: _initialIso,
                            autovalidateMode: AutovalidateMode.disabled,
                            disableLengthCheck: true,
                            decoration: InputDecoration(
                              hintText: t.loginPhone,
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            pickerDialogStyle: PickerDialogStyle(
                              searchFieldInputDecoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: t.searchPlaceholder,
                              ),
                            ),
                            invalidNumberMessage: t.loginPhoneInvalid,
                            onChanged: (p) {
                              setState(() {
                                _phoneE164 = p.completeNumber;
                                _nationalDisplay = p.number;
                                _initialIso = p.countryISOCode;
                              });
                              if (_submittedOnce) {
                                _formKey.currentState?.validate();
                              }
                            },
                            onCountryChanged: (c) =>
                                setState(() => _initialIso = c.code),
                            validator: (p) =>
                                (p == null || p.number.trim().isEmpty)
                                ? t.loginErrorRequired
                                : null,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            t.loginUseEmailInstead,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      AppTextField(
                        // email input
                        controller: _emailCtrl,
                        label: t.email,
                        hint: t.loginEmail,
                        prefix: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        size: AppInputSize.md,
                        margin: EdgeInsets.only(bottom: gapS),
                        borderRadius: 22,
                        filled: false,
                        validator: _validateEmail,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            t.loginUsePhoneInstead,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    AppTextField(
                      // password
                      controller: _pwdCtrl,
                      label: t.loginPassword,
                      hint: '••••••••',
                      prefix: const Icon(Icons.lock_outline),
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      obscure: _obscure,
                      textInputAction: TextInputAction.done,
                      size: AppInputSize.md,
                      borderRadius: 22,
                      validator: (v) => (v == null || v.length < 6)
                          ? t.registerErrorLength
                          : null,
                    ),
                    SizedBox(height: gapS),
                    AppButton(
                      // login btn
                      onPressed: _submit,
                      type: AppButtonType.primary,
                      size: AppButtonSize.lg,
                      expand: true,
                      label: t.loginLogin,
                    ),
                    SizedBox(height: gapS),
                    TextButton(
                      // forgot
                      onPressed: () {}, // TODO
                      child: Text(
                        t.loginForgetPassword,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            .8,
                          ),
                        ),
                      ),
                    ),
                    if (_roleIndex == 0) // google only for users
                      AppButton(
                        onPressed: _googleSignInFlow,
                        type: AppButtonType.outline,
                        size: AppButtonSize.md,
                        expand: true,
                        leading: Image.asset(
                          'assets/icons/google.png',
                          width: _clamp(w * 0.055, 18, 22),
                          height: _clamp(w * 0.055, 18, 22),
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.g_mobiledata),
                        ),
                        label: t.loginGoogleSignIn,
                        borderRadius: 22,
                      ),
                    SizedBox(height: gapM),
                    Wrap(
                      // register
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          '${t.loginNoAccount} ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {}, // TODO
                          child: Text(
                            t.loginRegister,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading) // overlay
            Container(
              color: Colors.black.withOpacity(0.12),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// Small role pill widget (User / Business)
class _RolePill extends StatelessWidget {
  final String label; // text
  final bool selected; // selected?
  final double height; // h
  final double radius; // r
  final VoidCallback onTap; // tap

  const _RolePill({
    required this.label,
    required this.selected,
    required this.height,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final bg = selected ? cs.primary.withOpacity(.25) : cs.surface; // bg
    final fg = selected ? cs.primary : cs.onSurface.withOpacity(.8); // text
    final br = selected ? Colors.transparent : cs.outlineVariant; // border

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: br, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height, minWidth: 96),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
