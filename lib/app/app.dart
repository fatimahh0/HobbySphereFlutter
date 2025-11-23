// lib/app.dart
// Hosts MaterialApp.router using your GoRouter builder, i18n, themes,
// a live connection banner, and a runtime ThemeCubit that loads remote theme.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;

// i18n + themes
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;


// GoRouter config (your builder)
import 'router/router.dart' as app_router;

// Connection banner infrastructure
import 'package:hobby_sphere/shared/network/connection_cubit.dart';
import 'package:hobby_sphere/shared/widgets/connection_banner.dart';

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

  @override
  void initState() {
    super.initState();
    _restorePrefs();
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

  @override
  Widget build(BuildContext context) {
    // Build your GoRouter with callbacks (theme/locale toggles if some screens need them).
    final routerConfig = app_router.AppRouter.build(
      enabledFeatures: const ['activity'],
      onToggleTheme: _toggleTheme,
      onChangeLocale: _changeLocale,
      getCurrentLocale: () => _locale,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectionCubit(serverProbeUrl: _serverProbeUrl),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(
            dio: g.appDio!, // uses Dio you built in main/init
            themeEndpoint: '/themes/active/mobile',
          )..loadRemoteTheme(), // fetch remote theme once
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Hobby Sphere',

            routerConfig: routerConfig,

            // i18n
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // theming from ThemeCubit
            themeMode: _themeMode,
            theme: themeState.themeData,
            darkTheme: AppTheme.dark(),

            // Keep a global connection banner on top of every page.
            builder: (context, child) {
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
