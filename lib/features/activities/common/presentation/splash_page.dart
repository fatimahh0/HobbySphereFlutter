// ===== Flutter 3.35.x =====
// Robust Splash → check token expiry → decide next → navigate once.

import 'dart:convert'; // for JWT decode
import 'package:flutter/material.dart'; // UI core
import 'package:shared_preferences/shared_preferences.dart'; // local store
import 'package:hobby_sphere/core/constants/app_role.dart'; // enum
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // theme

import 'package:hobby_sphere/services/token_store.dart'; // saved token/role
import 'package:hobby_sphere/core/network/globals.dart' as g; // shared Dio
import 'package:hobby_sphere/core/business/business_context.dart'; // business id keeper
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
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideAndNavigate();
    });

    _progressCtrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted || _navigated) return;
        setState(() => _pageOpacity = 0.0);
      }
    });
  }

  /// Decode JWT and check expiry
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < now;
    } catch (_) {
      return true; // treat as expired if decode fails
    }
  }

  void _attachTokenToGlobalDio(String token) {
    if (g.appDio == null) return;
    g.appDio!.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<int> _resolveBusinessId(String token) async {
    _attachTokenToGlobalDio(token);
    final id = await BusinessContext.ensureId();
    return id;
  }

  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read();
      final token = saved.token?.trim();
      final roleStr = (saved.role ?? 'user').trim().toLowerCase();

      if (token != null && token.isNotEmpty) {
        // ✅ check if expired
        if (_isTokenExpired(token)) {
          await TokenStore.clear(); // remove expired token
          return _RouteTarget(name: '/login'); // or '/onboarding'
        }

        _attachTokenToGlobalDio(token);

        final businessId = await _resolveBusinessId(token);
        final appRole = roleStr == 'business' ? AppRole.business : AppRole.user;

        if (appRole == AppRole.business && businessId > 0) {
          await BusinessContext.set(businessId);
        }

        return _RouteTarget(
          name: '/shell',
          args: ShellRouteArgs(
            role: appRole,
            token: token,
            businessId: businessId,
          ),
        );
      }

      final sp = await SharedPreferences.getInstance();
      final seen = sp.getBool('seen_onboarding') ?? false;
      return _RouteTarget(name: seen ? '/onboardingScreen' : '/onboarding');
    } catch (e) {
      debugPrint('Splash decision error: $e');
      return _RouteTarget(name: '/onboarding');
    }
  }

  Future<void> _decideAndNavigate() async {
    final splashDelay = Future<void>.delayed(const Duration(milliseconds: 900));
    final next = _computeNext();

    final target = await Future.wait([
      splashDelay,
      next,
    ]).then((list) => list[1] as _RouteTarget);

    if (!mounted || _navigated) return;
    _navigated = true;

    try {
      setState(() => _pageOpacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        target.name,
        (r) => false,
        arguments: target.args,
      );
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/onboarding', (r) => false);
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _bgPulseCtrl.dispose();
    super.dispose();
  }

  Color _adjustLightness(Color c, double d) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + d).clamp(0.0, 1.0)).toColor();
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
  final String name;
  final Object? args;
  _RouteTarget({required this.name, this.args});
}
