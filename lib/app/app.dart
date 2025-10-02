// lib/app.dart — minimal additions to load backend colors and rebuild UI.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// your i18n and routing (unchanged)
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;
import 'router/router.dart';

// connection banner (unchanged)
import 'package:hobby_sphere/shared/network/connection_cubit.dart';
import 'package:hobby_sphere/shared/widgets/connection_banner.dart';

// server config (unchanged)
import 'package:hobby_sphere/core/network/api_config.dart';

// >>> NEW: imports for theme fetch + palette <<<
import 'package:hobby_sphere/features/activities/common/data/services/theme_service.dart'; // fetch JSON
import 'package:hobby_sphere/shared/theme/palette.dart'; // Palette.I (runtime colors)

class App extends StatefulWidget {
  final ApiConfig config; // has baseUrl + serverRoot
  const App({super.key, required this.config});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _kThemeKey = 'themeMode'; // saved theme
  static const _kLocaleKey = 'locale'; // saved locale

  ThemeMode _themeMode = ThemeMode.light; // default
  Locale _locale = const Locale('en'); // default

  late final AppRouter _router = AppRouter(
    onToggleTheme: _toggleTheme, // pass toggle
    onChangeLocale: _changeLocale, // pass change
    getCurrentLocale: () => _locale, // pass getter
  );

  late final String _serverProbeUrl =
      '${widget.config.serverRoot}/actuator/health'; // for ConnectionCubit

  // >>> NEW: create service once <<<
  final _themeService = ThemeService(); // backend theme service

  @override
  void initState() {
    super.initState(); // base init
    _restorePrefs(); // keep your prefs
    _loadThemeFromBackendOnce(); // >>> NEW: fetch and apply colors
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance(); // prefs
    final t = sp.getString(_kThemeKey); // theme saved
    final l = sp.getString(_kLocaleKey); // locale saved
    if (t != null)
      _themeMode = (t == 'dark') ? ThemeMode.dark : ThemeMode.light; // restore
    if (l != null) _locale = Locale(l); // restore
    if (mounted) setState(() {}); // rebuild
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance(); // prefs
    await sp.setString(
      _kThemeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    ); // save
  }

  Future<void> _persistLocale(Locale locale) async {
    final sp = await SharedPreferences.getInstance(); // prefs
    await sp.setString(_kLocaleKey, locale.languageCode); // save
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light; // flip
    });
    _persistTheme(_themeMode); // save
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale); // set
    _persistLocale(locale); // save
  }

  // >>> NEW: call backend and apply to Palette.I
  Future<void> _loadThemeFromBackendOnce() async {
    try {
      final json = await _themeService.getActiveMobileTheme(); // GET
      Palette.I.applyMobileThemeJson(json); // update colors
      // MaterialApp will rebuild thanks to AnimatedBuilder below.
    } catch (_) {
      // ignore errors: keep safe defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provide ConnectionCubit globally (your existing logic)
    return BlocProvider(
      create: (_) => ConnectionCubit(serverProbeUrl: _serverProbeUrl),
      // >>> NEW: AnimatedBuilder listens to Palette.I; rebuilds MaterialApp when colors change
      child: AnimatedBuilder(
        animation: Palette.I, // listen to runtime color changes
        builder: (_, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false, // clean
            title: 'Hobby Sphere', // app title
            navigatorKey: navigatorKey, // router key
            initialRoute: Routes.splash, // start route
            onGenerateRoute: _router.onGenerateRoute, // routing
            themeMode: _themeMode, // user pref
            theme: AppTheme.light, // uses runtime AppColors
            darkTheme: AppTheme.dark, // dark theme
            locale: _locale, // current language
            localizationsDelegates:
                AppLocalizations.localizationsDelegates, // i18n
            supportedLocales: AppLocalizations.supportedLocales, // i18n
            builder: (context, child) {
              // keep your connection banner on top
              return Stack(
                children: [
                  if (child != null) child, // current page
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ConnectionBanner(), // server status banner
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
