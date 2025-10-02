// Flutter 3.35.x
// splash_page.dart — waits until internet + server are reachable.
// Shows Offline / Server Down cards, else logo. Navigates once when connected.

import 'dart:convert' as convert; // base64 + json
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // read cubit
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart'; // prefs

import 'package:hobby_sphere/core/constants/app_role.dart'; // AppRole
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // AppColors/AppTypography

import 'package:hobby_sphere/services/token_store.dart'; // TokenStore
import 'package:hobby_sphere/core/network/globals.dart' as g; // Dio
import 'package:hobby_sphere/core/business/business_context.dart'; // business id
import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs; // args

import 'package:hobby_sphere/shared/network/connection_cubit.dart'; // ConnectionCubit

class SplashPage extends StatefulWidget {
  const SplashPage({super.key}); // const
  @override
  State<SplashPage> createState() => _SplashPageState(); // state
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // animations
  late final AnimationController _progressCtrl; // progress loop
  late final AnimationController _bgPulseCtrl; // bg pulse
  late final Animation<double> _progress; // 0..1
  double _pageOpacity = 1.0; // fade out
  bool _navigated = false; // single navigation guard

  @override
  void initState() {
    super.initState(); // base

    // progress
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward(); // start
    _progress = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    ); // smooth
    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_navigated) {
        _progressCtrl.forward(from: 0.0); // loop
      }
    });

    // pulsing bg
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true); // loop

    // start the logic
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideAndNavigate());
  }

  // ===== helpers: JWT expiry =====
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.'); // header.payload.signature
      if (parts.length != 3) return true; // invalid
      final payloadStr = _b64UrlToUtf8(parts[1]); // decode payload
      final payload =
          convert.json.decode(payloadStr) as Map<String, dynamic>; // map
      final exp = payload['exp'] as int?; // seconds
      if (exp == null) return true; // missing
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000; // now(s)
      return exp < now; // expired?
    } catch (_) {
      return true; // on error, treat expired
    }
  }

  String _b64UrlToUtf8(String s) {
    final norm = convert.base64Url.normalize(s); // pad
    final bytes = convert.base64Url.decode(norm); // bytes
    return convert.utf8.decode(bytes); // string
  }

  void _attachTokenToGlobalDio(String token) {
    if (g.appDio == null) return; // guard
    g.appDio!.options.headers['Authorization'] = 'Bearer $token'; // header
  }

  Future<int> _resolveBusinessId(String token) async {
    _attachTokenToGlobalDio(token); // ensure header
    return BusinessContext.ensureId(); // 0 if none
  }

  // ===== route decision =====
  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read(); // token + role
      final token = saved.token?.trim(); // string
      final roleStr = (saved.role ?? 'user')
          .trim()
          .toLowerCase(); // default user

      if (token != null && token.isNotEmpty) {
        if (_isTokenExpired(token)) {
          await TokenStore.clear(); // remove expired
          return _RouteTarget(name: '/login'); // go login
        }

        _attachTokenToGlobalDio(token); // bearer
        final bizId = await _resolveBusinessId(token); // maybe 0
        final appRole = roleStr == 'business'
            ? AppRole.business
            : AppRole.user; // enum

        if (appRole == AppRole.business && bizId > 0) {
          await BusinessContext.set(bizId); // cache id
        }

        return _RouteTarget(
          name: '/shell', // home shell
          args: ShellRouteArgs(
            role: appRole,
            token: token,
            businessId: bizId,
          ), // args
        );
      }

      final sp = await SharedPreferences.getInstance(); // prefs
      final seen = sp.getBool('seen_onboarding') ?? false; // flag
      return _RouteTarget(
        name: seen ? '/onboardingScreen' : '/onboarding',
      ); // next
    } catch (e) {
      debugPrint('Splash decision error: $e'); // log
      return _RouteTarget(name: '/onboarding'); // fallback
    }
  }

  // ===== wait until fully connected =====
  Future<void> _waitReady() async {
    final cubit = context.read<ConnectionCubit>(); // read once
    if (cubit.state == ConnectionStateX.connected) return; // already OK
    await cubit.stream.firstWhere(
      (s) => s == ConnectionStateX.connected,
    ); // wait
  }

  // ===== main flow =====
  Future<void> _decideAndNavigate() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 600),
    ); // small pause
    await _waitReady(); // block until internet+server OK

    final target = await _computeNext(); // decide route

    if (!mounted || _navigated) return; // guard
    _navigated = true; // lock

    try {
      setState(() => _pageOpacity = 0.0); // fade out
      await Future.delayed(const Duration(milliseconds: 180)); // short fade
      if (!mounted) return; // safety

      Navigator.of(context).pushNamedAndRemoveUntil(
        target.name,
        (r) => false,
        arguments: target.args, // navigate
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
    _progressCtrl.dispose(); // cleanup
    _bgPulseCtrl.dispose(); // cleanup
    super.dispose(); // base
  }

  // ===== small color helper =====
  Color _adjustLightness(Color c, double d) {
    final hsl = HSLColor.fromColor(c); // to HSL
    return hsl
        .withLightness((hsl.lightness + d).clamp(0.0, 1.0))
        .toColor(); // back
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // strings
    final primary = AppColors.primary; // brand
    final lighter = _adjustLightness(primary, 0.14); // lighter
    final darker = _adjustLightness(primary, -0.14); // darker

    final conn = context.watch<ConnectionCubit>().state; // connection state

    return WillPopScope(
      onWillPop: () async => false, // disable back
      child: Scaffold(
        backgroundColor: AppColors.background, // bg
        body: AnimatedOpacity(
          opacity: _pageOpacity, // fade on leave
          duration: const Duration(milliseconds: 240), // fade dur
          child: Stack(
            fit: StackFit.expand, // full
            children: [
              // pulsing gradient bg
              AnimatedBuilder(
                animation: _bgPulseCtrl, // pulse driver
                builder: (context, _) {
                  final t = _bgPulseCtrl.value; // 0..1
                  final c1 = Color.lerp(primary, lighter, t)!; // blend
                  final c2 = Color.lerp(primary, darker, 1 - t)!; // blend
                  final begin = Alignment(-0.8 + t * 0.6, -0.9); // start
                  final end = Alignment(0.8 - t * 0.6, 0.9); // end
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: begin,
                        end: end,
                        colors: [c1, c2],
                      ), // bg
                    ),
                  );
                },
              ),

              // center content: cards or logo
              Center(
                child: Builder(
                  builder: (context) {
                    // OFFLINE card
                    if (conn == ConnectionStateX.offline) {
                      final cs = Theme.of(context).colorScheme; // colors
                      return Card(
                        color: cs.errorContainer, // alert bg
                        margin: const EdgeInsets.all(24), // margin
                        child: Padding(
                          padding: const EdgeInsets.all(20), // padding
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // wrap
                            children: [
                              Text(
                                l10n.splashNoConnectionTitle, // title
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                      color: cs.onErrorContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center, // center
                              ),
                              const SizedBox(height: 8), // gap
                              Text(
                                l10n.splashNoConnectionDesc, // desc
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: cs.onErrorContainer),
                                textAlign: TextAlign.center, // center
                              ),
                              const SizedBox(height: 16), // gap
                              FilledButton(
                                onPressed: () => context
                                    .read<ConnectionCubit>()
                                    .retryNow(), // re-check
                                child: Text(l10n.connectionTryAgain), // button
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // SERVER DOWN card
                    if (conn == ConnectionStateX.serverDown) {
                      final cs = Theme.of(context).colorScheme; // colors
                      return Card(
                        color: cs.surfaceContainerHighest, // neutral bg
                        margin: const EdgeInsets.all(24), // margin
                        child: Padding(
                          padding: const EdgeInsets.all(20), // padding
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // wrap
                            children: [
                              Text(
                                l10n.splashServerDownTitle, // title
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center, // center
                              ),
                              const SizedBox(height: 8), // gap
                              Text(
                                l10n.splashServerDownDesc, // desc
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: cs.onSurface),
                                textAlign: TextAlign.center, // center
                              ),
                              const SizedBox(height: 16), // gap
                              FilledButton(
                                onPressed: () => context
                                    .read<ConnectionCubit>()
                                    .retryNow(), // retry
                                child: Text(l10n.connectionTryAgain), // button
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // CONNECTING or brief CONNECTED → logo only
                    return Column(
                      mainAxisSize: MainAxisSize.min, // compact
                      children: [
                        Container(
                          width: 112,
                          height: 112, // circle
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withOpacity(
                              0.12,
                            ), // soft fill
                            shape: BoxShape.circle, // circle
                            border: Border.all(
                              color: AppColors.onPrimary.withOpacity(
                                0.28,
                              ), // ring
                              width: 1.4, // width
                            ),
                          ),
                          child: Icon(
                            Icons.sports_soccer, // your logo/icon
                            size: 56, // size
                            color: AppColors.onPrimary, // contrast
                          ),
                        ),
                        const SizedBox(height: 18), // gap
                        Text(
                          l10n.appTitle, // app name
                          textAlign: TextAlign.center, // center
                          style: AppTypography.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // bottom progress (visual only)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0, // stick bottom
                child: AnimatedBuilder(
                  animation: _progress, // listen
                  builder: (context, _) {
                    final percent = (_progress.value * 100).toInt(); // 0..100
                    return Column(
                      mainAxisSize: MainAxisSize.min, // compact
                      children: [
                        Text(
                          "$percent%", // percent
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        LinearProgressIndicator(
                          value: _progress.value, // 0..1
                          minHeight: 8, // thickness
                          backgroundColor: AppColors.onPrimary.withOpacity(
                            0.22,
                          ), // track
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.onPrimary,
                          ), // bar
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

// simple holder for route and args
class _RouteTarget {
  final String name; // route name
  final Object? args; // args
  _RouteTarget({required this.name, this.args}); // ctor
}
