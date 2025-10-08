// lib/app.dart
// Hosts MaterialApp.router using your GoRouter builder, i18n, themes,
// a live connection banner, and a runtime color Palette fetched once.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;

// i18n + themes
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;

// GoRouter config (your builder)
import 'router/router.dart' as app_router;

// Connection banner infrastructure
import 'package:hobby_sphere/shared/network/connection_cubit.dart';
import 'package:hobby_sphere/shared/widgets/connection_banner.dart';

// Runtime theme palette loader (optional)
import 'package:hobby_sphere/features/activities/common/data/services/theme_service.dart';
import 'package:hobby_sphere/shared/theme/palette.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _kThemeKey = 'themeMode';
  static const _kLocaleKey = 'locale';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  // Server health probe for ConnectionCubit (strip trailing /api).
  late final String _serverProbeUrl =
      (g.appServerRoot).replaceFirst(RegExp(r'/api/?$'), '') +
      '/actuator/health';

  // Optional: fetch a server-provided palette once.
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _restorePrefs();
    _loadThemeFromBackendOnce();
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kThemeKey);
    final l = sp.getString(_kLocaleKey);
    if (t != null) {
      _themeMode = (t == 'dark') ? ThemeMode.dark : ThemeMode.light;
    }
    if (l != null) {
      _locale = Locale(l);
    }
    if (mounted) setState(() {});
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> _persistLocale(Locale locale) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLocaleKey, locale.languageCode);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    _persistTheme(_themeMode);
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
    _persistLocale(locale);
  }

  Future<void> _loadThemeFromBackendOnce() async {
    try {
      final json = await _themeService.getActiveMobileTheme();
      Palette.I.applyMobileThemeJson(json); // triggers AnimatedBuilder rebuild
    } catch (_) {
      // Swallow quietly: keep defaults on failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build your GoRouter with callbacks (theme/locale toggles if some screens need them).
    final routerConfig = app_router.AppRouter.build(
      enabledFeatures: const ['activity'],
      onToggleTheme: _toggleTheme,
      onChangeLocale: _changeLocale,
      getCurrentLocale: () => _locale,
    );

    return BlocProvider(
      create: (_) => ConnectionCubit(serverProbeUrl: _serverProbeUrl),
      // Rebuild MaterialApp when the runtime palette changes.
      child: AnimatedBuilder(
        animation: Palette.I,
        builder: (_, __) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Hobby Sphere',

            routerConfig: routerConfig, // GoRouter config
            // i18n
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // theming
            themeMode: _themeMode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,

            // Keep a global connection banner on top of every page.
            builder: (context, child) {
              // OPTIONAL: If you’re still migrating old LegacyNav.pushNamed(...)
              // screens, you can wrap `child` with LegacyNavHost to forward
              // those calls to GoRouter without rewriting every screen at once:
              //
              // return LegacyNavHost(child: Stack(
              //   children: [
              //     if (child != null) child,
              //     const Positioned(top: 0, left: 0, right: 0, child: ConnectionBanner()),
              //   ],
              // ));
              //
              // If you don’t need that bridge, keep the plain Stack below.

              return Stack(
                children: [
                  if (child != null) child,
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ConnectionBanner(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
