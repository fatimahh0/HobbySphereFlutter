// ===== Flutter 3.35.x =====
// Robust Splash → decide next → navigate once.

import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/auth/app_role.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/theme/app_theme.dart';

import 'package:hobby_sphere/core/auth/token_store.dart';
import 'package:hobby_sphere/core/network/api_client.dart';

// for passing args to the shell route
import 'package:hobby_sphere/config/router.dart' show ShellRouteArgs;

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

    // progress animation (cosmetic)
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    // bg pulse animation (cosmetic)
    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // 1) fire logic right after first frame (doesn't wait the 3s)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideAndNavigate(); // start deciding
    });

    // 2) also keep your old fade when progress completes (just in case)
    _progressCtrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted || _navigated) return;
        setState(() => _pageOpacity = 0.0);
      }
    });
  }

  Future<void> _decideAndNavigate() async {
    // small artificial splash delay so UI shows (adjust if you want)
    final splashDelay = Future<void>.delayed(const Duration(milliseconds: 900));

    // compute next route in parallel
    final next = _computeNext(); // Future<_RouteTarget>

    // wait for both to finish (min splash time + decision)
    final target = await Future.wait([
      splashDelay,
      next,
    ]).then((list) => list[1] as _RouteTarget);

    if (!mounted || _navigated) return;
    _navigated = true; // block further calls

    try {
      // fade quickly
      setState(() => _pageOpacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      // go!
      Navigator.of(context).pushNamedAndRemoveUntil(
        target.name, // '/shell' or onboarding routes
        (r) => false,
        arguments: target.args, // null for onboarding
      );
    } catch (e) {
      // if navigation fails (route missing), show a simple fallback
      debugPrint('Splash navigation error: $e');
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/onboarding', (r) => false);
    }
  }

  // Decide where to go and which arguments to pass
  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read(); // (token, role, maybe extras)
      final token = saved.token?.trim();
      final roleStr = (saved.role ?? 'user').trim().toLowerCase();

      if (token != null && token.isNotEmpty) {
        ApiClient().setToken(token); // set bearer

        // If you don’t store businessId yet → keep 0 (safe)
        final int businessId = 0;

        final appRole = roleStr == 'business' ? AppRole.business : AppRole.user;

        return _RouteTarget(
          name: '/shell', // must exist in AppRouter
          args: ShellRouteArgs(
            role: appRole,
            token: token,
            businessId: businessId,
          ),
        );
      }

      // no token → check onboarding flag
      final sp = await SharedPreferences.getInstance();
      final seen = sp.getBool('seen_onboarding') ?? false;
      return _RouteTarget(name: seen ? '/onboardingScreen' : '/onboarding');
    } catch (e) {
      debugPrint('Splash decision error: $e');
      return _RouteTarget(name: '/onboarding'); // safe fallback
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _bgPulseCtrl.dispose();
    super.dispose();
  }

  Color _adjustLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = AppColors.primary;
    final lighter = _adjustLightness(primary, 0.14);
    final darker = _adjustLightness(primary, -0.14);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOpacity(
        opacity: _pageOpacity,
        duration: const Duration(milliseconds: 240),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
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
  final Object? args; // optional arguments
  _RouteTarget({required this.name, this.args});
}
