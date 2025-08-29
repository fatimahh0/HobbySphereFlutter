// ===== Flutter 3.35.x =====
// Robust Splash → decide next → navigate once.

import 'package:flutter/material.dart'; // UI core
import 'package:shared_preferences/shared_preferences.dart'; // local store
import 'package:intl/intl.dart'; // (optional)
import 'package:hobby_sphere/core/constants/app_role.dart'; // enum
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // theme

import 'package:hobby_sphere/services/token_store.dart'; // saved token/role
import 'package:hobby_sphere/core/network/globals.dart' as g; // shared Dio
import 'package:hobby_sphere/core/network/api_fetch.dart'; // http wrapper
import 'package:hobby_sphere/core/network/api_methods.dart'; // HttpMethod
import 'package:hobby_sphere/core/business/business_context.dart'; // 👈 NEW: business id keeper

import 'package:hobby_sphere/app/router/router.dart'
    show ShellRouteArgs; // route args

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl; // progress timer
  late final AnimationController _bgPulseCtrl; // bg pulse
  late final Animation<double> _progress; // eased progress
  double _pageOpacity = 1.0; // fade out
  bool _navigated = false; // ensure single navigation

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      // create progress anim
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward(); // start it now
    _progress = CurvedAnimation(
      // ease curve
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    _bgPulseCtrl = AnimationController(
      // create bg pulse
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true); // loop pulse

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // after 1st frame
      _decideAndNavigate(); // run logic
    });

    _progressCtrl.addStatusListener((status) async {
      // cosmetic fade
      if (status == AnimationStatus.completed) {
        if (!mounted || _navigated) return; // guard
        setState(() => _pageOpacity = 0.0); // fade out
      }
    });
  }

  void _attachTokenToGlobalDio(String token) {
    if (g.appDio == null) return; // Dio not ready
    g.appDio!.options.headers['Authorization'] = // set bearer
        'Bearer $token';
  }

  // Resolve businessId using the central context.
  Future<int> _resolveBusinessId(String token) async {
    _attachTokenToGlobalDio(token); // ensure bearer set
    final id = await BusinessContext.ensureId(); // memory/prefs/server
    return id; // may be 0 if unknown
  }

  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read(); // read saved auth
      final token = saved.token?.trim(); // token string
      final roleStr =
          (saved.role ?? 'user') // role string
              .trim()
              .toLowerCase();

      if (token != null && token.isNotEmpty) {
        // logged in?
        _attachTokenToGlobalDio(token); // attach bearer

        final businessId = await _resolveBusinessId(
          // get businessId
          token,
        ); // may be 0

        final appRole =
            roleStr ==
                'business' // map role
            ? AppRole.business
            : AppRole.user;

        if (appRole == AppRole.business && businessId > 0) {
          await BusinessContext.set(businessId); // 👈 keep ready
        }

        return _RouteTarget(
          // go to shell
          name: '/shell',
          args: ShellRouteArgs(
            role: appRole,
            token: token,
            businessId: businessId, // pass id (0 ok)
          ),
        );
      }

      // not logged in → onboarding / first-run
      final sp = await SharedPreferences.getInstance(); // prefs
      final seen = sp.getBool('seen_onboarding') ?? false; // flag
      return _RouteTarget(name: seen ? '/onboardingScreen' : '/onboarding');
    } catch (e) {
      debugPrint('Splash decision error: $e'); // log
      return _RouteTarget(name: '/onboarding'); // safe default
    }
  }

  Future<void> _decideAndNavigate() async {
    final splashDelay = Future<void>.delayed(
      const Duration(milliseconds: 900),
    ); // small wait
    final next = _computeNext(); // compute

    final target =
        await Future.wait([splashDelay, next]) // wait both
            .then((list) => list[1] as _RouteTarget); // take route

    if (!mounted || _navigated) return; // guard
    _navigated = true; // lock

    try {
      setState(() => _pageOpacity = 0.0); // fade
      await Future.delayed(const Duration(milliseconds: 180)); // tiny wait
      if (!mounted) return; // guard

      Navigator.of(context).pushNamedAndRemoveUntil(
        // navigate
        target.name,
        (r) => false,
        arguments: target.args,
      );
    } catch (e) {
      debugPrint('Splash navigation error: $e'); // log
      if (!mounted) return; // guard
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/onboarding', (r) => false); // fallback
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose(); // cleanup
    _bgPulseCtrl.dispose(); // cleanup
    super.dispose();
  }

  Color _adjustLightness(Color c, double d) {
    // color util
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // strings
    final primary = AppColors.primary; // base color
    final lighter = _adjustLightness(primary, 0.14); // lighter
    final darker = _adjustLightness(primary, -0.14); // darker

    return Scaffold(
      backgroundColor: AppColors.background, // bg
      body: AnimatedOpacity(
        opacity: _pageOpacity, // fade val
        duration: const Duration(milliseconds: 240), // fade ms
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              // bg grad
              animation: _bgPulseCtrl,
              builder: (context, _) {
                final t = _bgPulseCtrl.value;
                final c1 = Color.lerp(primary, lighter, t)!;
                final c2 = Color.lerp(primary, darker, 1 - t)!;
                final begin = Alignment(-0.8 + t * 0.6, -0.9);
                final end = Alignment(0.8 - t * 0.6, 0.9);
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: begin,
                      end: end,
                      colors: [c1, c2],
                    ),
                  ),
                );
              },
            ),
            Center(
              // logo/title
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.onPrimary.withOpacity(0.28),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      size: 56,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              // bottom bar
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final percent = (_progress.value * 100).toInt();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$percent%",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 8,
                        backgroundColor: AppColors.onPrimary.withOpacity(0.22),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
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
    );
  }
}

class _RouteTarget {
  final String name; // route name
  final Object? args; // optional args
  _RouteTarget({required this.name, this.args});
}
