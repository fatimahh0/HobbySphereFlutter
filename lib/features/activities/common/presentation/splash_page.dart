// Flutter 3.35.x
// lib/features/activities/common/presentation/splash_page.dart
// Waits until internet + server are reachable, then routes once via GoRouter.

import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/app/router/router.dart'
    show Routes, ShellRouteArgs;
import 'package:hobby_sphere/shared/network/connection_cubit.dart';

import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/core/business/business_context.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/token_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _bgPulseCtrl;
  late final Animation<double> _progress;
  double _pageOpacity = 1.0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
    _progressCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_navigated) {
        _progressCtrl.forward(from: 0.0);
      }
    });

    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _decideAndNavigate());
  }

  // ========== JWT helpers ==========
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payloadStr = _b64UrlToUtf8(parts[1]);
      final payload = convert.json.decode(payloadStr) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < now;
    } catch (_) {
      return true;
    }
  }

  String _b64UrlToUtf8(String s) {
    final norm = convert.base64Url.normalize(s);
    final bytes = convert.base64Url.decode(norm);
    return convert.utf8.decode(bytes);
  }

  void _attachTokenToGlobalDio(String token) {
    final dio = g.appDio;
    if (dio == null) return;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<int> _resolveBusinessId(String token) async {
    _attachTokenToGlobalDio(token);
    return BusinessContext.ensureId(); // returns 0 if none
  }

  // ========== decide next route ==========
  Future<_RouteTarget> _computeNext() async {
    try {
      final saved = await TokenStore.read();
      final token = saved.token?.trim();
      final roleStr = (saved.role ?? 'user').trim().toLowerCase();

      if (token != null && token.isNotEmpty) {
        if (_isTokenExpired(token)) {
          await TokenStore.clear();
          return _RouteTarget(name: Routes.login);
        }

        _attachTokenToGlobalDio(token);
        final bizId = await _resolveBusinessId(token);
        final appRole = roleStr == 'business' ? AppRole.business : AppRole.user;

        if (appRole == AppRole.business && bizId > 0) {
          await BusinessContext.set(bizId);
        }

        return _RouteTarget(
          name: Routes.shell,
          args: ShellRouteArgs(role: appRole, token: token, businessId: bizId),
        );
      }

      final sp = await SharedPreferences.getInstance();
      final seen = sp.getBool('seen_onboarding') ?? false;
      return _RouteTarget(
        name: seen ? Routes.onboardingScreen : Routes.onboarding,
      );
    } catch (e) {
      debugPrint('Splash decision error: $e');
      return _RouteTarget(name: Routes.onboarding);
    }
  }

  // ========== wait for connectivity ==========
  Future<void> _waitReady() async {
    final cubit = context.read<ConnectionCubit>();
    if (cubit.state == ConnectionStateX.connected) return;
    await cubit.stream.firstWhere((s) => s == ConnectionStateX.connected);
  }

  // ========== main flow ==========
  Future<void> _decideAndNavigate() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _waitReady();

    final target = await _computeNext();

    if (!mounted || _navigated) return;
    _navigated = true;

    try {
      setState(() => _pageOpacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      // ✅ GoRouter navigation (replace stack)
      context.goNamed(target.name, extra: target.args);
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      if (!mounted) return;
      context.goNamed(Routes.onboarding);
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

    final conn = context.watch<ConnectionCubit>().state;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedOpacity(
          opacity: _pageOpacity,
          duration: const Duration(milliseconds: 240),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // pulsing gradient bg
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

              // center content
              Center(
                child: Builder(
                  builder: (context) {
                    if (conn == ConnectionStateX.offline) {
                      final cs = Theme.of(context).colorScheme;
                      return Card(
                        color: cs.errorContainer,
                        margin: const EdgeInsets.all(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.splashNoConnectionTitle,
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                      color: cs.onErrorContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.splashNoConnectionDesc,
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: cs.onErrorContainer),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () =>
                                    context.read<ConnectionCubit>().retryNow(),
                                child: Text(l10n.connectionTryAgain),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (conn == ConnectionStateX.serverDown) {
                      final cs = Theme.of(context).colorScheme;
                      return Card(
                        color: cs.surfaceContainerHighest,
                        margin: const EdgeInsets.all(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.splashServerDownTitle,
                                style: AppTypography.textTheme.titleLarge
                                    ?.copyWith(
                                      color: cs.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.splashServerDownDesc,
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: cs.onSurface),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () =>
                                    context.read<ConnectionCubit>().retryNow(),
                                child: Text(l10n.connectionTryAgain),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // connecting/connected → logo
                    return Column(
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

              // bottom progress
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
                          backgroundColor: AppColors.onPrimary.withOpacity(
                            0.22,
                          ),
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
      ),
    );
  }
}

class _RouteTarget {
  final String name; // must be a GoRouter route name (Routes.*)
  final Object? args; // will be passed in extra:
  _RouteTarget({required this.name, this.args});
}
