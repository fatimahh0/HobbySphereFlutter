// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // core UI
import 'package:flutter/services.dart'; // (kept if you add other formatters)
import 'package:intl_phone_field/intl_phone_field.dart'; // phone field
import 'package:intl_phone_field/country_picker_dialog.dart'; // phone picker dialog
import 'package:hobby_sphere/l10n/app_localizations.dart'; // 🔸 l10n strings
import 'package:hobby_sphere/ui/widgets/app_button.dart'; // reusable button
import 'package:hobby_sphere/ui/widgets/app_text_field.dart'; // reusable input
import 'package:hobby_sphere/shared/utils/validators_auto.dart'; // email validator

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // ctor
  @override
  State<LoginPage> createState() => _LoginPageState(); // create state
}

class _LoginPageState extends State<LoginPage> {
  // controllers
  final _emailCtrl = TextEditingController(); // email text
  final _pwdCtrl = TextEditingController(); // password text

  // form key
  final _formKey = GlobalKey<FormState>(); // form key

  // ui state
  int _roleIndex = 0; // 0 user, 1 business
  bool _usePhone = true; // phone mode first
  bool _obscure = true; // hide password

  // phone state (intl_phone_field manages validation/formatting)
  String _initialIso = 'CA'; // default country
  String? _phoneE164; // +E.164 value
  String? _nationalDisplay; // national view (optional)

  // small helper for responsive tokens
  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v); // clamp

  @override
  void dispose() {
    _emailCtrl.dispose(); // free
    _pwdCtrl.dispose(); // free
    super.dispose(); // parent
  }

  // email validator using your helper (domain whitelist included)
  String? _validateEmail(String? v) => validateEmailAuto(
    input: v, // email text
    allowedDomains: {
      // whitelist (optional)
      'gmail.com', 'hotmail.com', 'outlook.com', 'yahoo.com',
      'icloud.com', 'live.com', 'msn.com',
    },
  );

  // submit action
  void _submit() {
    final t = AppLocalizations.of(context)!; // strings
    final ok = _formKey.currentState?.validate() ?? false; // validate
    if (!ok) {
      // invalid → show msg
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.loginErrorRequired),
        ), // "All fields are required"
      );
      return; // stop
    }

    final roleStr = _roleIndex == 1
        ? t.loginBusiness
        : t.loginUser; // role label

    if (_usePhone) {
      // phone mode
      if (_phoneE164 == null || _phoneE164!.isEmpty) {
        // guard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.loginPhone)), // hint message
        );
        return;
      }

      // TODO: call API login with phone/password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.loginLoading}  ($roleStr, $_phoneE164)')),
      );
    } else {
      // email mode
      // TODO: call API login with email/password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${t.loginLoading}  ($roleStr, ${_emailCtrl.text.trim()})',
          ),
        ),
      );
    }
  }

  // toggle between email / phone modes
  void _toggleMode() => setState(() => _usePhone = !_usePhone); // flip

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // 🔸 strings
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors
    final size = MediaQuery.sizeOf(context); // screen size
    final w = size.width, h = size.height; // width/height

    // responsive tokens
    final side = _clamp(w * 0.06, 16, 28); // side padding
    final logoDia = _clamp(w * 0.34, 110, 160); // logo circle
    final pillH = _clamp(h * 0.052, 38, 48); // pill height
    final pillR = _clamp(w * 0.06, 18, 28); // pill radius
    final gapS = _clamp(h * 0.012, 8, 14); // small gap
    final gapM = _clamp(h * 0.02, 12, 22); // medium gap
    final gapL = _clamp(h * 0.03, 18, 30); // large gap

    return Scaffold(
      appBar: AppBar(
        // top app bar
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // same bg
   
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // scroll on small screens
          padding: EdgeInsets.fromLTRB(side, 8, side, side), // screen padding
          child: Form(
            key: _formKey, // form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // center column
              children: [
                // logo circle
                Container(
                  width: logoDia, // size
                  height: logoDia, // size
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.18), // tinted bg
                    shape: BoxShape.circle, // circle
                  ),
                  child: Center(
                    child: Image.asset(
                      // your logo
                      'assets/images/Logo.png', // path
                      fit: BoxFit.contain, // fit
                      errorBuilder: (_, __, ___) => Text(
                        // fallback text
                        'HS',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: cs.primary, // brand color
                          fontWeight: FontWeight.w800, // heavy
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
                    fontWeight: FontWeight.w800, // bold
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
                    ), // softer
                    height: 1.35, // line height
                  ),
                ),

                SizedBox(height: gapM), // gap
                // role pills (User / Business)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // center
                  children: [
                    _RolePill(
                      label: t.loginUser, // "User"
                      selected: _roleIndex == 0, // state
                      height: pillH, // size
                      radius: pillR, // corners
                      onTap: () => setState(() => _roleIndex = 0), // select
                    ),
                    SizedBox(width: _clamp(w * 0.03, 10, 16)), // gap
                    _RolePill(
                      label: t.loginBusiness, // "Business"
                      selected: _roleIndex == 1, // state
                      height: pillH, // size
                      radius: pillR, // corners
                      onTap: () => setState(() => _roleIndex = 1), // select
                    ),
                  ],
                ),

                SizedBox(height: gapL), // gap
                // ===== phone or email area =====
                if (_usePhone) ...[
                  // phone input (intl_phone_field handles format/validation)
                  Material(
                    color: cs.surface, // field bg
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22), // corners
                      side: BorderSide(color: cs.outlineVariant, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IntlPhoneField(
                        initialCountryCode: _initialIso, // 'CA','LB',...
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        disableLengthCheck: false, // keep checks
                        decoration: InputDecoration(
                          hintText: t.loginPhone, // "Phone Number"
                          border: InputBorder.none, // no border
                          counterText: '', // hide counter
                        ),
                        pickerDialogStyle: PickerDialogStyle(
                          searchFieldInputDecoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search), // icon
                            hintText: t.searchPlaceholder, // "Search"
                          ),
                        ),
                        invalidNumberMessage:
                            t.loginErrorFailed, // generic error text
                        onChanged: (phone) {
                          // value change
                          setState(() {
                            _phoneE164 = phone.completeNumber; // +E.164
                            _nationalDisplay = phone.number; // national
                            _initialIso = phone.countryISOCode; // keep ISO2
                          });
                        },
                        onCountryChanged: (c) {
                          // country change
                          setState(() => _initialIso = c.code); // store ISO2
                        },
                        validator: (phone) {
                          // simple required
                          if (phone == null || phone.number.trim().isEmpty) {
                            return t
                                .loginErrorRequired; // "All fields are required"
                          }
                          return null; // ok
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight, // align right
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
                    controller: _emailCtrl, // controller
                    label: t.email, // "Email"
                    hint: t.loginEmail, // "Email Address"
                    prefix: const Icon(Icons.email_outlined), // icon
                    keyboardType: TextInputType.emailAddress, // email kb
                    textInputAction: TextInputAction.next, // next
                    size: AppInputSize.md, // size
                    margin: EdgeInsets.only(bottom: gapS), // gap
                    borderRadius: 22, // corners
                    filled: false, // outline style
                    validator: _validateEmail, // validator
                  ),
                  Align(
                    alignment: Alignment.centerRight, // align right
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

                // password field
                AppTextField(
                  controller: _pwdCtrl, // controller
                  label: t.loginPassword, // "Password"
                  hint: '••••••••', // bullets
                  prefix: const Icon(Icons.lock_outline), // icon
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure), // toggle
                  ),
                  obscure: _obscure, // hide
                  textInputAction: TextInputAction.done, // done
                  size: AppInputSize.md, // size
                  borderRadius: 22, // corners
                  validator: (v) => (v == null || v.length < 6)
                      ? t
                            .registerErrorLength // "Password must be at least 8..." (you can adjust)
                      : null, // ok
                ),

                SizedBox(height: gapS), // gap
                // login button
                AppButton(
                  onPressed: _submit, // action
                  type: AppButtonType.primary, // style
                  size: AppButtonSize.lg, // size
                  expand: true, // full width
                  label: t.loginLogin, // "Log In"
                ),

                SizedBox(height: gapS), // gap
                // forgot password
                TextButton(
                  onPressed: () {
                    /* TODO: route to forgot */
                  }, // action
                  child: Text(
                    t.loginForgetPassword, // "Forgot your password?"
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        .8,
                      ), // softer
                    ),
                  ),
                ),

                SizedBox(height: gapS), // gap
                // google button (user only)
                if (_roleIndex == 0)
                  AppButton(
                    onPressed: () {
                      /* TODO: google sign-in */
                    }, // action
                    type: AppButtonType.outline, // outline
                    size: AppButtonSize.md, // size
                    expand: true, // full width
                    leading: Image.asset(
                      // google icon
                      'assets/icons/google.png', // path
                      width: _clamp(w * 0.055, 18, 22), // size
                      height: _clamp(w * 0.055, 18, 22), // size
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.g_mobiledata),
                    ),
                    label: t.loginGoogleSignIn, // "Continue with Google"
                    borderRadius: 22, // corners
                  ),

                SizedBox(height: gapM), // gap
                // register row
                Wrap(
                  alignment: WrapAlignment.center, // center
                  children: [
                    Text(
                      '${t.loginNoAccount} ', // "Don't have an account?"
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        /* TODO: go to register */
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
    );
  }
}

// ===== small pill widget (User / Business) =====
class _RolePill extends StatelessWidget {
  final String label; // text
  final bool selected; // state
  final double height; // height
  final double radius; // corners
  final VoidCallback onTap; // tap cb
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
        borderRadius: BorderRadius.circular(radius), // ripple mask
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            minWidth: 96,
          ), // min size
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // pad
            child: Center(
              child: Text(
                label, // text
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
