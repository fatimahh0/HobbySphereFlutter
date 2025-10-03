// Flutter 3.35.x — Clean, simple, and professional.
// Every line has a short, simple comment.

// ===== Imports =====
import 'dart:convert'; // for base64 + json decode (JWT payload)
import 'package:flutter/material.dart'; // base UI
import 'package:flutter/services.dart'; // PlatformException details
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC for state
import 'package:google_sign_in/google_sign_in.dart'; // Google sign-in SDK
// add near other imports
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart'
    as rt; // realtime

import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs, Routes; // app routes + args
import 'package:hobby_sphere/core/constants/app_role.dart'; // enum for app roles
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // shared Dio/global

import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/screens/forgot_password_page.dart';
import 'package:hobby_sphere/services/token_store.dart'; // save token locally
import 'package:hobby_sphere/core/business/business_context.dart'; // save biz id
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n texts
import 'package:hobby_sphere/shared/widgets/phone_input.dart';

import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast helper

import 'package:hobby_sphere/features/authentication/login&register/data/services/auth_service.dart'; // HTTP service
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/auth_repository_impl.dart'; // repo impl
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_user_email.dart'; // UC
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_user_phone.dart'; // UC
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_business_email.dart'; // UC
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_business_phone.dart'; // UC
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/login_google.dart'; // UC
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/login/reactivate_account.dart'; // UC

import '../bloc/login_bloc.dart'; // bloc
import '../bloc/login_event.dart'; // events
import '../bloc/login_state.dart'; // state

import '../widgets/role_selector.dart'; // role switcher UI

import '../widgets/email_input.dart'; // email field
import '../widgets/password_input.dart'; // password field
import '../widgets/primary_actions.dart'; // login/forgot buttons
import '../widgets/google_button.dart'; // Google button UI shell
import '../widgets/register_footer.dart'; // register footer

import 'package:hobby_sphere/core/auth/google_oauth.dart'; // kGoogleWebClientId (WEB client id)

// ===== Small helper to decode JWT payload (for diagnostics) =====
Map<String, dynamic> _decodeJwtPayload(String jwt) {
  // split into 3 parts (header.payload.signature)
  final parts = jwt.split('.');
  if (parts.length != 3) return {}; // invalid jwt
  // convert base64url -> base64
  var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/'); // normalize
  // pad with '=' until length % 4 == 0
  while (payload.length % 4 != 0) {
    payload += '='; // pad
  }
  try {
    // decode base64 to bytes then to string
    final jsonStr = utf8.decode(base64.decode(payload)); // json string
    // parse to map and return
    return Map<String, dynamic>.from(json.decode(jsonStr) as Map); // map
  } catch (_) {
    return {}; // if any error, return empty map
  }
}

// ===== Screen root =====
class LoginPage extends StatelessWidget {
  const LoginPage({super.key}); // simple ctor

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepositoryImpl(AuthService()); // create repo with service
    return BlocProvider(
      // provide bloc to subtree
      create: (_) => LoginBloc(
        // build bloc with all UCs
        loginUserEmail: LoginUserWithEmail(repo), // UC: user email
        loginUserPhone: LoginUserWithPhone(repo), // UC: user phone
        loginBizEmail: LoginBusinessWithEmail(repo), // UC: biz email
        loginBizPhone: LoginBusinessWithPhone(repo), // UC: biz phone
        loginGoogle: LoginWithGoogle(repo), // UC: Google login
        reactivateAccount: ReactivateAccount(repo), // UC: reactivate
      ),
      child: const _LoginView(), // actual UI
    );
  }
}

// ===== Stateful UI =====
class _LoginView extends StatefulWidget {
  const _LoginView(); // ctor
  @override
  State<_LoginView> createState() => _LoginViewState(); // create state
}

class _LoginViewState extends State<_LoginView> {
  // --- controllers for text fields ---
  final _emailCtrl = TextEditingController(); // email input controller
  final _pwdCtrl = TextEditingController(); // password input controller


  bool _pwdObscure = true; // start hidden

  @override
  void dispose() {
    _pwdCtrl.dispose(); // clean up
    super.dispose();
  }

  // --- GoogleSignIn instance with WEB client id (required for idToken) ---
  final _gsi = GoogleSignIn(
    scopes: const ['email', 'profile'], // request email + profile
    serverClientId: kGoogleWebClientId, // MUST be Web client ID
  );

  // --- flag to avoid opening multiple reactivation dialogs ---
  bool _reactivateOpen = false; // dialog guard

 

  // --- Google sign-in handler (with diagnostics) ---
  Future<void> _handleGoogle(BuildContext context) async {
    final bloc = context.read<LoginBloc>(); // get bloc
    if (bloc.state.roleIndex == 1) {
      // if business role selected
      showTopToast(
        // show info toast
        context,
        'Google sign-in is for users only', // simple text
        type: ToastType.info, // info style
      );
      return; // stop here
    }

    debugPrint('🔎 [Google] start'); // log start
    try {
      debugPrint('🔎 [Google] signOut()'); // log step
      await _gsi.signOut(); // clear cached account (prevents stale errors)

      debugPrint('🔎 [Google] signIn()'); // log step
      final acct = await _gsi.signIn(); // open Google picker
      if (acct == null) {
        // user canceled
        showTopToast(
          context,
          'Google sign-in canceled',
          type: ToastType.info,
        ); // toast
        debugPrint('⛔ [Google] canceled'); // log cancel
        return; // stop
      }

      debugPrint('✅ [Google] account: ${acct.email}'); // log email

      final auth = await acct.authentication; // get tokens
      final idToken = auth.idToken; // backend needs this token
      final accessToken = auth.accessToken; // optional
      debugPrint(
        '🔎 [Google] idToken: ${idToken == null ? 'NULL' : 'SET'} / accessToken: ${accessToken == null ? 'NULL' : 'SET'}',
      ); // log tokens

      if (idToken == null || idToken.isEmpty) {
        // guard
        showTopToast(
          // show error
          context,
          'Missing Google ID token (check Web client ID & SHA-1/SHA-256).', // hint
          type: ToastType.error, // red
          haptics: true, // vibrate
        );
        debugPrint('⛔ [Google] idToken null/empty'); // log
        return; // stop
      }

      // --- decode token to verify 'aud' against kGoogleWebClientId ---
      final payload = _decodeJwtPayload(idToken); // decode
      final aud = payload['aud']; // audience (must equal WEB client id)
      final email = payload['email']; // email claim
      final emailVerified = payload['email_verified']; // verified flag
      final iss = payload['iss']; // issuer (Google)
      debugPrint(
        '🧾 [Google] payload: aud=$aud | email=$email | email_verified=$emailVerified | iss=$iss',
      ); // log payload

      if (aud != kGoogleWebClientId) {
        // mismatch -> wrong project/client
        showTopToast(
          context,
          'Token audience mismatch.\nExpected:\n$kGoogleWebClientId\nGot:\n$aud', // show expected vs got
          type: ToastType.error, // red
          haptics: true, // vibrate
        );
        debugPrint('⛔ [Google] AUD mismatch'); // log mismatch
        return; // stop
      }

      if (emailVerified == false) {
        // optional strict check
        showTopToast(
          context,
          'Google email not verified',
          type: ToastType.error,
        ); // toast
        debugPrint('⛔ [Google] email not verified'); // log
        return; // stop
      }

      debugPrint('🚀 [Google] dispatch LoginGooglePressed'); // log dispatch
      bloc.add(LoginGooglePressed(idToken)); // dispatch google login event
    } on PlatformException catch (e) {
      // show exact native error (very helpful)
      showTopToast(
        context,
        'PlatformException code=${e.code}\nmsg=${e.message}\ndet=${e.details}', // details
        type: ToastType.error, // red
        haptics: true, // vibrate
      );
      debugPrint(
        '⛔ [Google][Platform] code=${e.code} msg=${e.message} det=${e.details}',
      ); // log
    } catch (e, st) {
      // any other error
      showTopToast(
        context,
        'Google sign-in failed: $e', // show reason
        type: ToastType.error, // red
        haptics: true, // vibrate
      );
      debugPrint('⛔ [Google][Unknown] $e\n$st'); // log
    } finally {
      debugPrint('🏁 [Google] end'); // log end
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // translator
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Scaffold(
      // page shell
      appBar: AppBar(
        // top bar
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // match bg
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        // listen + build
        listenWhen: (p, c) => p != c, // only when state changes
        listener: (context, state) async {
          // --- show error toast if any ---
          if (state.error?.isNotEmpty == true) {
            showTopToast(
              context,
              state.error!, // message from bloc
              type: ToastType.error, // red
              haptics: true, // vibrate
            );
          }

          // --- show info toast if any and not in reactivate flow ---
          if (state.info?.isNotEmpty == true &&
              !state.showReactivate &&
              state.token.isEmpty) {
            showTopToast(context, state.info!, type: ToastType.info); // info
          }

          // --- show reactivate dialog once if needed ---
          // --- after successful login (we have token) ---
          if (state.token.isNotEmpty) {
            g.appDio?.options.headers['Authorization'] =
                'Bearer ${state.token}'; // set header
            await TokenStore.save(
              token: state.token,
              role: state.roleIndex == 1 ? 'business' : 'user',
            ); // persist
            if (state.roleIndex == 1 && state.businessId > 0) {
              await BusinessContext.set(state.businessId); // save biz id
            }
            // keep globals aligned (some parts read these)
            g.token = state.token; // store jwt
            // if you have appServerRoot set earlier, keep it; realtime needs httpBase w/o /api

            // ✅ start realtime for USER role only (you said this socket is for user side)
            if (state.roleIndex == 0) {
              await rt.startUserRealtime(); // connect + listen
            }

            if (!mounted) return; // safety

            final appRole = state.roleIndex == 1
                ? AppRole.business
                : AppRole.user; // role

            // navigate as before
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

          // --- after successful login (we have token) ---
          if (state.token.isNotEmpty) {
            g.appDio?.options.headers['Authorization'] =
                'Bearer ${state.token}'; // set auth header
            await TokenStore.save(
              // persist token + role
              token: state.token, // jwt
              role: state.roleIndex == 1 ? 'business' : 'user', // role
            );
            if (state.roleIndex == 1 && state.businessId > 0) {
              await BusinessContext.set(state.businessId); // save biz id
            }
            if (!mounted) return; // safety

            // map index to enum (0=user, 1=business)
            final appRole = state.roleIndex == 1
                ? AppRole.business
                : AppRole.user; // choose role

            // go to shell and clear back stack
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/shell', // shell route (kept as string to match your router)
              (r) => false, // remove all previous routes
              arguments: ShellRouteArgs(
                // pass args
                role: appRole, // role
                token: state.token, // jwt
                businessId: state.businessId, // biz id if any
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginBloc>(); // get bloc for events
          return SafeArea(
            // avoid notches
            child: Stack(
              // allow loading overlay
              children: [
                SingleChildScrollView(
                  // page scroll
                  padding: const EdgeInsets.all(16), // outer padding
                  child: Column(
                    // vertical layout
                    children: [
                      _Logo(), // app logo
                      const SizedBox(height: 24), // space
                      Text(
                        // big title
                        t.loginTitle, // i18n title
                        textAlign: TextAlign.center, // center
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700, // bold
                          color: cs.onBackground, // text color
                        ),
                      ),
                      const SizedBox(height: 6), // tiny space
                      Text(
                        // subtitle
                        t.loginInstruction, // i18n helper text
                        textAlign: TextAlign.center, // center
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35, // line height
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            .75,
                          ), // soft color
                        ),
                      ),
                      const SizedBox(height: 16), // space
                      RoleSelector(
                        // user/business switch
                        value: state.roleIndex, // current role index
                        onChanged: (i) =>
                            bloc.add(LoginRoleChanged(i)), // event
                      ),
                      const SizedBox(height: 24), // space
                      // --- email or phone input depending on method ---
                      if (state.usePhone)
                        PhoneInput(
                          // phone widget
                          initialIso: 'CA', // default country
                          submittedOnce: false, // validation flag
                          onChanged: (e164, _, __) =>
                              bloc.add(LoginPhoneChanged(e164)), // event
                          onSwapToEmail: () =>
                              bloc.add(LoginToggleMethod()), // switch method
                        )
                      else
                        EmailInput(
                          // email widget
                          controller: _emailCtrl, // controller
                          validator: (_) => null, // no local validation
                          onSwapToPhone: () =>
                              bloc.add(LoginToggleMethod()), // switch method
                        ),

                      const SizedBox(height: 8), // space
                      // --- password field ---
                      PasswordInput(
  controller: _pwdCtrl,       // pass controller
  obscure: _pwdObscure,       // pass current state
  onToggleObscure: () {       // eye tap handler
    setState(() {
      _pwdObscure = !_pwdObscure; // flip show/hide
    });
  },
),

                      const SizedBox(height: 12), // space
                      // --- actions row (login + forgot) ---
                      PrimaryActions(
                        onLogin: () {
                          // login press
                          bloc.add(
                            LoginEmailChanged(
                              _emailCtrl.text.trim(),
                            ), // set email
                          );
                          bloc.add(
                            LoginPasswordChanged(
                              _pwdCtrl.text.trim(),
                            ), // set pwd
                          );
                          bloc.add(LoginSubmitted()); // submit
                        },
                        onForgot: () {
                          // read current role index from bloc (0 = user, 1 = business)
                          final isBusiness =
                              context.read<LoginBloc>().state.roleIndex ==
                              1; // role
                          // navigate to forgot page with role preselected
                          Navigator.of(context).pushNamed(
                            Routes.forgot, // route name
                            arguments: ForgotPasswordArgs(
                              isBusiness: isBusiness,
                            ), // pass role
                          ); // push
                        },
                      ),

                      // --- Google Sign-In (users only) ---
                      if (state.roleIndex == 0) ...[
                        const SizedBox(height: 8), // small space
                        GoogleButton(
                          // wrapper button UI
                          onPressed: () => _handleGoogle(context), // handler
                        ),
                      ],

                      const SizedBox(height: 16), // space
                      // --- register link ---
                      RegisterFooter(
                        onRegister:
                            () => // navigate to register
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.register),
                      ),
                    ],
                  ),
                ),

                // --- loading overlay ---
                if (state.loading)
                  Container(
                    // semi-transparent layer
                    color: Colors.black.withOpacity(.12), // dim bg
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ), // spinner
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===== Simple logo widget =====
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return Container(
      width: 140, // size
      height: 140, // size
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.18), // light primary circle
        shape: BoxShape.circle, // circle shape
      ),
      child: Center(
        // center child
        child: Image.asset(
          'assets/images/Logo.png', // logo path
          fit: BoxFit.contain, // keep ratio
          errorBuilder: (_, __, ___) => Text(
            // fallback if missing
            'HS', // initials
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: cs.primary, // primary text
              fontWeight: FontWeight.w800, // heavy
              letterSpacing: .5, // spacing
            ),
          ),
        ),
      ),
    );
  }
}
