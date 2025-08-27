// ===== Flutter 3.35.x =====
// login_page.dart — Full login screen integrated with backend + Google Sign-In.

import 'package:flutter/material.dart'; // UI widgets
import 'package:hobby_sphere/core/services/auth_service.dart'; // auth api service (your path)
import 'package:intl_phone_field/intl_phone_field.dart'; // phone input
import 'package:intl_phone_field/country_picker_dialog.dart'; // phone picker
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/ui/widgets/app_button.dart'; // button
import 'package:hobby_sphere/ui/widgets/app_text_field.dart'; // text field
import 'package:hobby_sphere/shared/utils/validators_auto.dart'; // email validator

import 'package:google_sign_in/google_sign_in.dart'; // google sdk
import 'package:hobby_sphere/core/auth/token_store.dart'; // save token
import 'package:hobby_sphere/core/network/api_client.dart'; // set bearer

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // ctor
  @override
  State<LoginPage> createState() => _LoginPageState(); // state
}

class _LoginPageState extends State<LoginPage> {
  // controllers
  final _emailCtrl = TextEditingController(); // email text
  final _pwdCtrl = TextEditingController(); // password text

  // form key
  final _formKey = GlobalKey<FormState>(); // validate form

  // ui state
  int _roleIndex = 0; // 0 user, 1 business
  bool _usePhone = true; // start with phone
  bool _obscure = true; // hide password
  bool _loading = false; // show loader
  bool _submittedOnce = false; // validate after user taps "Log In"

  // phone state
  String _initialIso = 'CA'; // default country
  String? _phoneE164; // +E.164 phone
  String? _nationalDisplay; // national display (optional)

  // services
  final _auth = AuthService(); // api layer
  final _gsi = GoogleSignIn(scopes: ['email']); // google sign-in

  // helpers
  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v); // clamp
  void _setLoading(bool v) => setState(() => _loading = v); // toggle loader

  // helper: go to user or business home based on role
  void _goHomeByRole(String role) {
    // role = "user" or "business"
    if (!mounted) return; // safety: widget still on screen?
    final route =
        role ==
            'business' // choose route name
        ? '/business/home' // business home route
        : '/user/home'; // user home route

    Navigator.of(context).pushNamedAndRemoveUntil(
      // navigate & clear back stack
      route, // target route
      (r) => false, // remove all previous routes
    );
  }

  // email validator
  String? _validateEmail(String? v) => validateEmailAuto(
    input: v, // email text
    allowedDomains: {
      'gmail.com',
      'hotmail.com',
      'outlook.com',
      'yahoo.com',
      'icloud.com',
      'live.com',
      'msn.com',
    }, // optional allow-list
  );

  @override
  void dispose() {
    _emailCtrl.dispose(); // free email ctrl
    _pwdCtrl.dispose(); // free pwd ctrl
    super.dispose(); // parent
  }

  // ===== handle backend response: success / inactive / error =====
  Future<void> _handleLoginResponse(
    Map<String, dynamic> res, // full response map
    String role, // "user" or "business"
  ) async {
    final t = AppLocalizations.of(context)!; // i18n

    // 0) prefer explicit error first
    if (res['error'] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${res['error']}'))); // show error
      return; // stop
    }

    // 1) read flags commonly returned by our ApiFetch wrapper
    final bool okFlag = res['_ok'] == true; // true if 2xx
    final int status = res['_status'] is int
        ? res['_status'] as int
        : 200; // http status or 200

    // 2) nested objects (backend returns user/business objects)
    final userObj = res['user']; // may be map
    final bizObj = res['business']; // may be map

    // 3) extract id safely (for reactivation)
    final nestedId = (userObj is Map && userObj['id'] != null)
        ? userObj['id']
        : (bizObj is Map && bizObj['id'] != null)
        ? bizObj['id']
        : (res['id'] ?? res['userId'] ?? res['businessId']); // last fallback

    // 4) inactive branch
    final bool wasInactive = res['wasInactive'] == true; // inactive?
    if (wasInactive && nestedId != null) {
      final confirm =
          await showDialog<bool>(
            context: context, // host
            barrierDismissible: false, // must choose
            builder: (_) => AlertDialog(
              title: Text(t.loginInactiveTitle), // "Account Inactive"
              content: Text(
                // use the key we defined earlier; if you used different key, change here
                t.loginInactiveMessage, // "Your account is inactive. Would you like to reactivate it?"
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(t.cancel),
                ), // cancel
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(t.reactivate),
                ), // ok
              ],
            ),
          ) ??
          false; // default false if dismissed

      if (!confirm) return; // user refused

      _setLoading(true); // start spinner
      try {
        final react = await _auth.reactivateAccount(
          id: nestedId is int
              ? nestedId
              : int.tryParse('$nestedId') ?? 0, // to int
          role: role, // "user" | "business"
        ); // POST reactivate

        if (react['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${react['error']}')),
          ); // backend error
          return; // stop
        }

        final token = '${react['token'] ?? react['jwt'] ?? ''}'; // jwt
        if (token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Missing token after reactivation')),
          ); // guard
          return; // stop
        }

        ApiClient().setToken(token); // set bearer
        await TokenStore.save(token: token, role: role); // persist jwt+role
        if (mounted)
          _goHomeByRole(
            role,
          ); // role is already passed into _handleLoginResponse
      } finally {
        _setLoading(false); // stop spinner
      }
      return; // done inactive path
    }

    // 5) normal success → must have token
    final token = '${res['token'] ?? res['jwt'] ?? ''}'; // jwt
    if (token.isNotEmpty) {
      ApiClient().setToken(token); // set bearer
      await TokenStore.save(token: token, role: role); // save jwt+role
      if (mounted) _goHomeByRole(role); // go home
      return; // done
    }

    // 6) no token: show message (handles 401/403 with "message")
    final msg = '${res['message'] ?? t.loginErrorFailed}'; // fallback text
    // include status for quick debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$msg (${status.toString()})')),
    ); // show error
  }

  // ===== submit (email/phone × user/business) =====
  Future<void> _submit() async {
    _submittedOnce = true; // 👈 start validating
    final t = AppLocalizations.of(context)!;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.loginErrorRequired),
        ), // "Please fill required fields"
      );
      return;
    }

    final role = _roleIndex == 1 ? 'business' : 'user'; // role string

    // phone guard when needed
    if (_usePhone && (_phoneE164 == null || _phoneE164!.trim().isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.loginPhone))); // phone required
      return; // stop
    }

    _setLoading(true); // start loader
    try {
      Map<String, dynamic> res; // response map

      if (role == 'user') {
        // user flow
        if (_usePhone) {
          res = await _auth.loginWithPhonePassword(
            phoneNumber: _phoneE164!, // phone
            password: _pwdCtrl.text.trim(), // password
          ); // POST /api/auth/user/login-phone
        } else {
          res = await _auth.loginWithEmailPassword(
            email: _emailCtrl.text.trim(), // email
            password: _pwdCtrl.text.trim(), // password
          ); // POST /api/auth/user/login
        }
      } else {
        // business flow
        if (_usePhone) {
          res = await _auth.loginBusinessWithPhone(
            phoneNumber: _phoneE164!, // phone
            password: _pwdCtrl.text.trim(), // password
          ); // POST /api/auth/business/login-phone
        } else {
          res = await _auth.loginBusiness(
            email: _emailCtrl.text.trim(), // email
            password: _pwdCtrl.text.trim(), // password
          ); // POST /api/auth/business/login
        }
      }

      // debug line to console (helpful if something mismatches)
      // ignore: avoid_print
      print('Login response: $res'); // debug output

      await _handleLoginResponse(res, role); // unified handling
    } catch (e) {
      // show any network/parsing error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.loginErrorFailed}: $e')),
      ); // error
    } finally {
      _setLoading(false); // stop loader
    }
  }

  // ===== Google sign-in (users only) =====
  Future<void> _googleSignInFlow() async {
    // block for business role (per your requirement)
    if (_roleIndex == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in is for users only')),
      ); // info
      return; // stop
    }

    _setLoading(true); // start loader
    try {
      final acc = await _gsi.signIn(); // open picker
      if (acc == null) return; // canceled

      final auth = await acc.authentication; // tokens
      final idToken = auth.idToken; // google id token
      if (idToken == null || idToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google ID token is missing')),
        ); // guard
        return; // stop
      }

      final res = await _auth.loginWithGoogle(
        idToken,
      ); // POST /api/auth/google (ensure backend exists)
      await _handleLoginResponse(res, 'user'); // handle like normal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      ); // error
    } finally {
      _setLoading(false); // stop loader
    }
  }

  // toggle email/phone
  void _toggleMode() => setState(() => _usePhone = !_usePhone); // flip

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // strings
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors
    final size = MediaQuery.sizeOf(context); // screen size
    final w = size.width, h = size.height; // w/h

    // responsive tokens
    final side = _clamp(w * 0.06, 16, 28); // side pad
    final logoDia = _clamp(w * 0.34, 110, 160); // logo size
    final pillH = _clamp(h * 0.052, 38, 48); // pill height
    final pillR = _clamp(w * 0.06, 18, 28); // pill radius
    final gapS = _clamp(h * 0.012, 8, 14); // small gap
    final gapM = _clamp(h * 0.02, 12, 22); // medium gap
    final gapL = _clamp(h * 0.03, 18, 30); // large gap

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // same bg
      ),
      body: Stack(
        children: [
          // main content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, 8, side, side), // pad
              child: Form(
                key: _formKey, // form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // center col
                  children: [
                    // logo
                    Container(
                      width: logoDia, // size
                      height: logoDia, // size
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(.18), // tint
                        shape: BoxShape.circle, // circle
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/Logo.png', // asset path
                          fit: BoxFit.contain, // fit
                          errorBuilder: (_, __, ___) => Text(
                            'HS', // fallback
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: cs.primary, // brand
                              fontWeight: FontWeight.w800, // bold
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gapL), // gap
                    // title
                    Text(
                      t.loginTitle, // "Welcome Back"
                      textAlign: TextAlign.center, // center
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800, // heavy
                        letterSpacing: .2, // track
                      ),
                    ),

                    SizedBox(height: _clamp(h * 0.006, 4, 8)), // tiny gap
                    // subtitle
                    Text(
                      t.loginInstruction, // "Please log in..."
                      textAlign: TextAlign.center, // center
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          .75,
                        ), // soft
                        height: 1.35, // line
                      ),
                    ),

                    SizedBox(height: gapM), // gap
                    // role pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // center
                      children: [
                        _RolePill(
                          label: t.loginUser, // "User"
                          selected: _roleIndex == 0, // selected?
                          height: pillH, // height
                          radius: pillR, // round
                          onTap: () => setState(() => _roleIndex = 0), // select
                        ),
                        SizedBox(width: _clamp(w * 0.03, 10, 16)), // gap
                        _RolePill(
                          label: t.loginBusiness, // "Business"
                          selected: _roleIndex == 1, // selected?
                          height: pillH, // height
                          radius: pillR, // round
                          onTap: () => setState(() => _roleIndex = 1), // select
                        ),
                      ],
                    ),

                    SizedBox(height: gapL), // gap
                    // phone or email
                    if (_usePhone) ...[
                      // phone field
                      Material(
                        color: cs.surface, // bg
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22), // corners
                          side: BorderSide(
                            color: cs.outlineVariant,
                            width: 1,
                          ), // border
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ), // inner pad
                          child: IntlPhoneField(
                            initialCountryCode: _initialIso, // default country
                            autovalidateMode: AutovalidateMode
                                .disabled, // ❌ no live validation
                            disableLengthCheck:
                                true, // ❌ don't validate length while typing
                            decoration: InputDecoration(
                              hintText: t.loginPhone, // "Phone Number"
                              border: InputBorder.none, // no border
                              counterText: '', // hide counter
                            ),
                            pickerDialogStyle: PickerDialogStyle(
                              searchFieldInputDecoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                ), // search icon
                                hintText: t.searchPlaceholder, // "Search"
                              ),
                            ),
                            // ⚠️ don't show "login failed" here; use a specific message or leave empty
                            invalidNumberMessage: t
                                .loginPhoneInvalid, // e.g. "Invalid phone number"
                            onChanged: (p) {
                              setState(() {
                                _phoneE164 =
                                    p.completeNumber; // +E.164 (e.g., +961...)
                                _nationalDisplay = p.number; // local part
                                _initialIso =
                                    p.countryISOCode; // ISO2 (e.g., "LB")
                              });
                              if (_submittedOnce) {
                                // optional: re-validate only after the user tapped login once
                                _formKey.currentState
                                    ?.validate(); // re-check form
                              }
                            },
                            onCountryChanged: (c) => setState(
                              () => _initialIso = c.code,
                            ), // update ISO2
                            // ✅ our own validator runs only on submit (because autovalidate is disabled)
                            validator: (p) =>
                                (p == null || p.number.trim().isEmpty)
                                ? t
                                      .loginErrorRequired // "Required"
                                : null,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight, // right
                        child: TextButton(
                          onPressed: _toggleMode, // switch
                          child: Text(
                            t.loginUseEmailInstead, // "Use Email Instead"
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary, // brand
                              fontWeight: FontWeight.w600, // semi
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // email field
                      AppTextField(
                        controller: _emailCtrl, // ctrl
                        label: t.email, // "Email"
                        hint: t.loginEmail, // hint
                        prefix: const Icon(Icons.email_outlined), // icon
                        keyboardType: TextInputType.emailAddress, // kb
                        textInputAction: TextInputAction.next, // next
                        size: AppInputSize.md, // size
                        margin: EdgeInsets.only(bottom: gapS), // gap
                        borderRadius: 22, // corners
                        filled: false, // outline
                        validator: _validateEmail, // validate
                      ),
                      Align(
                        alignment: Alignment.centerRight, // right
                        child: TextButton(
                          onPressed: _toggleMode, // switch
                          child: Text(
                            t.loginUsePhoneInstead, // "Use Phone Instead"
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary, // brand
                              fontWeight: FontWeight.w600, // semi
                            ),
                          ),
                        ),
                      ),
                    ],

                    // password
                    AppTextField(
                      controller: _pwdCtrl, // ctrl
                      label: t.loginPassword, // "Password"
                      hint: '••••••••', // bullets
                      prefix: const Icon(Icons.lock_outline), // icon
                      suffix: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ), // eye
                        onPressed: () =>
                            setState(() => _obscure = !_obscure), // toggle
                      ),
                      obscure: _obscure, // hide chars
                      textInputAction: TextInputAction.done, // done
                      size: AppInputSize.md, // size
                      borderRadius: 22, // corners
                      validator: (v) => (v == null || v.length < 6)
                          ? t.registerErrorLength
                          : null, // >=6
                    ),

                    SizedBox(height: gapS), // gap
                    // login button
                    AppButton(
                      onPressed: _submit, // submit
                      type: AppButtonType.primary, // style
                      size: AppButtonSize.lg, // big
                      expand: true, // full width
                      label: t.loginLogin, // "Log In"
                    ),

                    SizedBox(height: gapS), // gap
                    // forgot password
                    TextButton(
                      onPressed: () {
                        // TODO: navigate to forgot
                      }, // action
                      child: Text(
                        t.loginForgetPassword, // label
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            .8,
                          ), // soft
                        ),
                      ),
                    ),

                    SizedBox(height: gapS), // gap
                    // google (users only)
                    if (_roleIndex == 0)
                      AppButton(
                        onPressed: _googleSignInFlow, // google flow
                        type: AppButtonType.outline, // outline
                        size: AppButtonSize.md, // medium
                        expand: true, // full width
                        leading: Image.asset(
                          'assets/icons/google.png', // google icon
                          width: _clamp(w * 0.055, 18, 22), // w
                          height: _clamp(w * 0.055, 18, 22), // h
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.g_mobiledata), // fallback
                        ),
                        label: t.loginGoogleSignIn, // label
                        borderRadius: 22, // round
                      ),

                    SizedBox(height: gapM), // gap
                    // register row
                    Wrap(
                      alignment: WrapAlignment.center, // center
                      children: [
                        Text(
                          '${t.loginNoAccount} ',
                          style: theme.textTheme.bodyMedium,
                        ), // text
                        GestureDetector(
                          onTap: () {
                            // TODO: navigate to register
                          }, // action
                          child: Text(
                            t.loginRegister, // "Register"
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.primary, // brand
                              fontWeight: FontWeight.w700, // boldish
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

          // loader overlay
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.12), // dim
              child: const Center(
                child: CircularProgressIndicator(),
              ), // spinner
            ),
        ],
      ),
    );
  }
}

// small pill widget
class _RolePill extends StatelessWidget {
  final String label; // text
  final bool selected; // state
  final double height; // height
  final double radius; // radius
  final VoidCallback onTap; // tap
  const _RolePill({
    required this.label, // ctor
    required this.selected, // ctor
    required this.height, // ctor
    required this.radius, // ctor
    required this.onTap, // ctor
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final bg = selected ? cs.primary.withOpacity(.25) : cs.surface; // bg
    final fg = selected ? cs.primary : cs.onSurface.withOpacity(.8); // fg
    final br = selected ? Colors.transparent : cs.outlineVariant; // border
    return Material(
      color: bg, // fill
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius), // corners
        side: BorderSide(color: br, width: 1), // stroke
      ),
      child: InkWell(
        onTap: onTap, // action
        borderRadius: BorderRadius.circular(radius), // ripple
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height, minWidth: 96), // min
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // pad
            child: Center(
              child: Text(
                label, // label
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg, // color
                  fontWeight: FontWeight.w700, // weight
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
