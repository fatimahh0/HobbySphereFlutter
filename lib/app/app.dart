// lib/app.dart — accept ApiConfig and give ConnectionCubit a health URL

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;
import 'router/router.dart';

// ⬇️ use the cubit + banner
import 'package:hobby_sphere/shared/network/connection_cubit.dart';
import 'package:hobby_sphere/shared/widgets/connection_banner.dart';

// ⬇️ import ApiConfig to get serverRoot (from hostIp.json)
import 'package:hobby_sphere/core/network/api_config.dart';

class App extends StatefulWidget {
  // ⬅️ NEW: take the config instance
  final ApiConfig config; // has baseUrl + serverRoot
  const App({super.key, required this.config}); // require it

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _kThemeKey = 'themeMode';
  static const _kLocaleKey = 'locale';

  ThemeMode _themeMode = ThemeMode.light; // current theme
  Locale _locale = const Locale('en'); // current locale

  late final AppRouter _router; // classic Navigator 1.0 router

  // ⬅️ NEW: build server health URL once (adjust the path if different)
  late final String _serverProbeUrl =
      '${widget.config.serverRoot}/actuator/health'; // e.g. http://192.168.1.3:8080/actuator/health

  @override
  void initState() {
    super.initState();
    _router = AppRouter(
      onToggleTheme: _toggleTheme,
      onChangeLocale: _changeLocale,
      getCurrentLocale: () => _locale,
    );
    _restorePrefs(); // load saved theme + locale
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kThemeKey);
    final l = sp.getString(_kLocaleKey);
    if (t != null)
      _themeMode = (t == 'dark') ? ThemeMode.dark : ThemeMode.light;
    if (l != null) _locale = Locale(l);
    if (mounted) setState(() {}); // rebuild
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
    // ⬇️ Provide ConnectionCubit globally WITH the server health URL
    return BlocProvider(
      create: (_) => ConnectionCubit(serverProbeUrl: _serverProbeUrl),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hobby Sphere',
        navigatorKey: navigatorKey,
        initialRoute: Routes.splash,
        onGenerateRoute: _router.onGenerateRoute,
        themeMode: _themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child, // page behind
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ConnectionBanner(), // global banner
              ),
            ],
          );
        },
      ),
    );
  }
}
