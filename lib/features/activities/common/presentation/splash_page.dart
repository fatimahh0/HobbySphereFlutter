// splash_page.dart — Flutter 3.35.x
// Clean splash that waits for internet WITHOUT showing "Connecting...".
// Shows an offline card only when there is no internet.
// After online, it checks token/role, decides next route, and navigates once.

import 'dart:convert' as convert; // base64Url + utf8 + json decode
import 'package:flutter/material.dart'; // core UI
import 'package:flutter_bloc/flutter_bloc.dart'; // for reading cubits
import 'package:shared_preferences/shared_preferences.dart'; // simple local storage

import 'package:hobby_sphere/core/constants/app_role.dart'; // enum AppRole
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // AppColors/AppTypography

import 'package:hobby_sphere/services/token_store.dart'; // TokenStore (read/clear)
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // global Dio client
import 'package:hobby_sphere/core/business/business_context.dart'; // business id holder
import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs; // route args

import 'package:hobby_sphere/shared/network/connection_cubit.dart'; // ConnectionCubit + states
// import 'package:hobby_sphere/shared/bootstrap/bootstrap_cubit.dart'; // optional warm-up

class SplashPage extends StatefulWidget {
  const SplashPage({super.key}); // const constructor
  @override
  State<SplashPage> createState() => _SplashPageState(); // create state
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // === Animations (progress + pulsing bg) ===
  late final AnimationController _progressCtrl; // progress controller
  late final AnimationController _bgPulseCtrl; // background pulse controller
  late final Animation<double> _progress; // eased 0..1

  double _pageOpacity = 1.0; // fade out value when navigating
  bool _navigated = false; // ensure we navigate only once

  @override
  void initState() {
    super.initState(); // parent init

    // progress bar animation (3s)
    _progressCtrl = AnimationController(
      vsync: this, // ticker provider
      duration: const Duration(seconds: 3), // total duration
    )..forward(); // start anim

    // wrap with curve for smoother feel
    _progress = CurvedAnimation(
      parent: _progressCtrl, // base controller
      curve: Curves.easeInOut, // nice curve
    );

    // pulsing background controller (infinite)
    _bgPulseCtrl = AnimationController(
      vsync: this, // ticker provider
      duration: const Duration(milliseconds: 1800), // speed
    )..repeat(reverse: true); // loop back and forth

    // loop progress while waiting (only if not yet navigated)
    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _progressCtrl.forward(from: 0.0); // restart loop
      }
    });

    // kick main flow after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideAndNavigate(); // start the logic
    });
  }

  // ========== TOKEN HELPERS ==========

  /// Decode JWT payload and check if 'exp' is in the past.
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.'); // header.payload.signature
      if (parts.length != 3) return true; // invalid token => treat as expired
      final payloadStr = _b64UrlToUtf8(parts[1]); // decode payload
      final payload =
          convert.json.decode(payloadStr) as Map<String, dynamic>; // to map
      final exp = payload['exp'] as int?; // expiry (unix seconds)
      if (exp == null) return true; // missing exp => expired
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // now (s)
      return exp < now; // true if expired
    } catch (_) {
      return true; // any error => treat as expired
    }
  }

  /// Base64url normalize + decode to utf8 string.
  String _b64UrlToUtf8(String input) {
    final norm = convert.base64Url.normalize(input); // fix padding
    final bytes = convert.base64Url.decode(norm); // bytes
    return convert.utf8.decode(bytes); // utf8 string
  }

  /// Attach bearer token to global Dio (for authenticated API calls).
  void _attachTokenToGlobalDio(String token) {
    if (g.appDio == null) return; // guard if not ready yet
    g.appDio!.options.headers['Authorization'] = 'Bearer $token'; // header
  }

  /// Ensure we have business id when role is business.
  Future<int> _resolveBusinessId(String token) async {
    _attachTokenToGlobalDio(token); // ensure header
    final id = await BusinessContext.ensureId(); // fetch id (0 if none)
    return id; // result
  }

  // ========== DECISION FLOW ==========

  /// Decide the next route based on token/role/onboarding.
  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read(); // read saved token/role
      final token = saved.token?.trim(); // token string
      final roleStr = (saved.role ?? 'user').trim().toLowerCase(); // role

      if (token != null && token.isNotEmpty) {
        // check expiry
        if (_isTokenExpired(token)) {
          await TokenStore.clear(); // clear expired
          return _RouteTarget(name: '/login'); // go login
        }

        // set auth header
        _attachTokenToGlobalDio(token); // add bearer

        // resolve business id if needed
        final businessId = await _resolveBusinessId(token); // get id
        final appRole = roleStr == 'business'
            ? AppRole.business
            : AppRole.user; // enum

        // store business id for business role
        if (appRole == AppRole.business && businessId > 0) {
          await BusinessContext.set(businessId); // remember id
        }

        // go to main shell with args
        return _RouteTarget(
          name: '/shell', // main route
          args: ShellRouteArgs(
            role: appRole, // role
            token: token, // jwt
            businessId: businessId, // id or 0
          ),
        );
      }

      // no token => choose onboarding path
      final sp = await SharedPreferences.getInstance(); // prefs
      final seen = sp.getBool('seen_onboarding') ?? false; // seen flag
      return _RouteTarget(
        name: seen ? '/onboardingScreen' : '/onboarding', // route
      );
    } catch (e) {
      debugPrint('Splash decision error: $e'); // log error
      return _RouteTarget(name: '/onboarding'); // fallback
    }
  }

  /// Wait until ConnectionCubit reports CONNECTED (blocks on Splash).
  Future<void> _waitForInternet() async {
    final cubit = context.read<ConnectionCubit>(); // connectivity cubit
    if (cubit.state == ConnectionStateX.connected) {
      return; // already online → proceed
    }
    // wait for the first CONNECTED emission
    await cubit.stream.firstWhere(
      (s) => s == ConnectionStateX.connected,
    ); // suspend
  }

  /// Main flow: small delay → wait internet → (optional warm-up) → compute route → navigate.
  Future<void> _decideAndNavigate() async {
    // tiny visual delay to let animations breathe
    await Future<void>.delayed(const Duration(milliseconds: 600)); // ~0.6s

    // wait until we are connected (no "Connecting..." UI is shown on splash)
    await _waitForInternet(); // block here

    // OPTIONAL: run warm-up (preload caches/images) before navigating
    // try { await context.read<BootstrapCubit>().start(); } catch (_) {}

    // compute where to go
    final target = await _computeNext(); // decide

    // ensure single navigation + widget still mounted
    if (!mounted || _navigated) return; // guard
    _navigated = true; // lock navigation

    try {
      setState(() => _pageOpacity = 0.0); // start fade out
      await Future.delayed(const Duration(milliseconds: 180)); // small fade
      if (!mounted) return; // safety

      // navigate and clear back stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        target.name, // route name
        (r) => false, // remove all previous
        arguments: target.args, // pass args
      );
    } catch (e) {
      debugPrint('Splash navigation error: $e'); // log
      if (!mounted) return; // safety
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/onboarding', (r) => false); // fallback
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose(); // dispose progress controller
    _bgPulseCtrl.dispose(); // dispose pulse controller
    super.dispose(); // parent dispose
  }

  // ========== UI HELPERS ==========

  /// Lighten/darken a color by delta (HSL space).
  Color _adjustLightness(Color c, double d) {
    final hsl = HSLColor.fromColor(c); // to HSL
    return hsl
        .withLightness((hsl.lightness + d).clamp(0.0, 1.0))
        .toColor(); // back to Color
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // localization strings
    final primary = AppColors.primary; // main brand color
    final lighter = _adjustLightness(primary, 0.14); // lighter shade
    final darker = _adjustLightness(primary, -0.14); // darker shade

    // read connectivity to decide ONLY the offline card; treat CONNECTING like CONNECTED
    final conn = context
        .watch<ConnectionCubit>()
        .state; // current connection state

    // block back button on splash
    return WillPopScope(
      onWillPop: () async => false, // no back on splash
      child: Scaffold(
        backgroundColor: AppColors.background, // themed background
        body: AnimatedOpacity(
          opacity: _pageOpacity, // fade when leaving
          duration: const Duration(milliseconds: 240), // fade duration
          child: Stack(
            fit: StackFit.expand, // full screen
            children: [
              // pulsing gradient background
              AnimatedBuilder(
                animation: _bgPulseCtrl, // listen to pulse controller
                builder: (context, _) {
                  final t = _bgPulseCtrl.value; // 0..1
                  final c1 = Color.lerp(primary, lighter, t)!; // blend 1
                  final c2 = Color.lerp(primary, darker, 1 - t)!; // blend 2
                  final begin = Alignment(-0.8 + t * 0.6, -0.9); // start align
                  final end = Alignment(0.8 - t * 0.6, 0.9); // end align
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: begin, // gradient start
                        end: end, // gradient end
                        colors: [c1, c2], // colors
                      ),
                    ),
                  );
                },
              ),

              // center content
              Center(
                child: Builder(
                  builder: (context) {
                    // OFFLINE → show card with Try again
                    if (conn == ConnectionStateX.offline) {
                      final cs = Theme.of(context).colorScheme; // M3 colors
                      return Card(
                        color: cs.errorContainer, // alert background
                        margin: const EdgeInsets.all(24), // outer margin
                        child: Padding(
                          padding: const EdgeInsets.all(20), // inner padding
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // wrap content
                            children: [
                              Text(
                                l10n.splashNoConnectionTitle, // "No internet connection"
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                      color:
                                          cs.onErrorContainer, // readable text
                                      fontWeight: FontWeight.w700, // bold
                                    ),
                                textAlign: TextAlign.center, // center align
                              ),
                              const SizedBox(height: 8), // space
                              Text(
                                l10n.splashNoConnectionDesc, // "Please check Wi-Fi or data and try again."
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onErrorContainer, // readable
                                    ),
                                textAlign: TextAlign.center, // center align
                              ),
                              const SizedBox(height: 16), // space
                              FilledButton(
                                onPressed: () => context
                                    .read<ConnectionCubit>()
                                    .retryNow(), // force re-check
                                child: Text(
                                  l10n.connectionTryAgain,
                                ), // "Try again"
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // CONNECTING or CONNECTED → show your original logo/title (no "Connecting…" text)
                    return Column(
                      mainAxisSize: MainAxisSize.min, // compact column
                      children: [
                        Container(
                          width: 112,
                          height: 112, // circle size
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withOpacity(
                              0.12,
                            ), // soft fill
                            shape: BoxShape.circle, // circle shape
                            border: Border.all(
                              color: AppColors.onPrimary.withOpacity(
                                0.28,
                              ), // ring
                              width: 1.4, // ring width
                            ),
                          ),
                          child: Icon(
                            Icons.sports_soccer, // placeholder icon
                            size: 56, // icon size
                            color: AppColors.onPrimary, // contrast on primary
                          ),
                        ),
                        const SizedBox(height: 18), // spacing
                        Text(
                          l10n.appTitle, // app name
                          textAlign: TextAlign.center, // center
                          style: AppTypography.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.onPrimary, // readable
                                fontWeight: FontWeight.w700, // bold
                                letterSpacing: 0.4, // subtle tracking
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // bottom progress % + bar (just visual, loops while waiting)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0, // stick to bottom
                child: AnimatedBuilder(
                  animation: _progress, // listen to progress
                  builder: (context, _) {
                    final percent = (_progress.value * 100).toInt(); // 0..100
                    return Column(
                      mainAxisSize: MainAxisSize.min, // compact
                      children: [
                        Text(
                          "$percent%", // show %
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary, // readable
                            fontWeight: FontWeight.w600, // semi-bold
                          ),
                        ),
                        LinearProgressIndicator(
                          value: _progress.value, // 0..1
                          minHeight: 8, // thickness
                          backgroundColor: AppColors.onPrimary.withOpacity(
                            0.22,
                          ), // track
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.onPrimary, // bar color
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// simple route target holder
class _RouteTarget {
  final String name; // route name
  final Object? args; // optional arguments
  _RouteTarget({required this.name, this.args}); // constructor
}
