// app.dart — theme/locale prefs + classic Navigator 1.0 (onGenerateRoute)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/theme/app_theme.dart' show AppTheme;
import 'router/router.dart'; // AppRouter + Routes + navigatorKey

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _kThemeKey = 'themeMode'; // 'light' | 'dark'
  static const _kLocaleKey = 'locale'; // 'en' | 'ar' | ...

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(
      onToggleTheme: _toggleTheme,
      onChangeLocale: _changeLocale,
      getCurrentLocale: () => _locale,
    );
    _restorePrefs();
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance();
    final themeStr = sp.getString(_kThemeKey);
    final localeStr = sp.getString(_kLocaleKey);

    if (themeStr != null) {
      _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    if (localeStr != null) {
      _locale = Locale(localeStr);
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hobby Sphere',
      navigatorKey: navigatorKey, // optional global key
      initialRoute: Routes.splash, // '/'
      onGenerateRoute: _router.onGenerateRoute, // Navigator 1.0
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
