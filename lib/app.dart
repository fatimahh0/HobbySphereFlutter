// app.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/theme/app_theme.dart' show AppTheme;
import 'config/router.dart'; // we'll pass callbacks to it

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _kThemeKey =
      'themeMode'; // light|dark|system (we’ll use light/dark)
  static const _kLocaleKey = 'locale'; // en|ar|fr

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  late AppRouter _router; // needs callbacks from here

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

  // ===== callbacks given to OnboardingScreen via router =====
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
      // IMPORTANT: use the stateful values (not ThemeMode.system)
      themeMode: _themeMode,
      theme: AppTheme.light, // your light theme
      darkTheme: AppTheme.dark, // your dark theme
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Use router that can inject the callbacks into screens
      onGenerateRoute: _router.onGenerateRoute,
      initialRoute: '/', // Splash or whatever you use
    );
  }
}
