// app.dart — theme/locale prefs + classic Navigator 1.0 + global connection banner

import 'package:flutter/material.dart'; // core UI
import 'package:shared_preferences/shared_preferences.dart'; // local prefs
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc provider/builder

import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'
    show AppTheme; // light/dark themes

import 'router/router.dart'; // AppRouter + Routes + navigatorKey

// === connection cubit & banner (add these files from previous step) ===
import 'package:hobby_sphere/shared/network/connection_cubit.dart'; // Cubit for online/offline/connecting
import 'package:hobby_sphere/shared/widgets/connection_banner.dart'; // Top banner widget

class App extends StatefulWidget {
  const App({super.key}); // const ctor
  @override
  State<App> createState() => _AppState(); // stateful app
}

class _AppState extends State<App> {
  // keys to store theme + locale in SharedPreferences
  static const _kThemeKey = 'themeMode'; // 'light' | 'dark'
  static const _kLocaleKey = 'locale'; // 'en' | 'ar' | 'fr' ...

  // current theme + locale in memory
  ThemeMode _themeMode = ThemeMode.light; // default light
  Locale _locale = const Locale('en'); // default English

  // router that knows how to generate routes
  late final AppRouter _router; // initialized in initState

  @override
  void initState() {
    super.initState(); // call parent
    // create router and give it callbacks to change theme/locale
    _router = AppRouter(
      onToggleTheme: _toggleTheme, // lets screens toggle theme
      onChangeLocale: _changeLocale, // lets screens change locale
      getCurrentLocale: () => _locale, // provide current locale
    );
    _restorePrefs(); // load saved theme/locale from SharedPreferences
  }

  Future<void> _restorePrefs() async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    final themeStr = sp.getString(_kThemeKey); // read theme string
    final localeStr = sp.getString(_kLocaleKey); // read locale code

    if (themeStr != null) {
      _themeMode = themeStr == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light; // apply theme
    }
    if (localeStr != null) {
      _locale = Locale(localeStr); // apply locale
    }
    if (mounted) setState(() {}); // rebuild UI
  }

  Future<void> _persistTheme(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.setString(
      _kThemeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    ); // save theme string
  }

  Future<void> _persistLocale(Locale locale) async {
    final sp = await SharedPreferences.getInstance(); // open prefs
    await sp.setString(_kLocaleKey, locale.languageCode); // save locale code
  }

  void _toggleTheme() {
    // switch between light/dark
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light; // flip mode
    });
    _persistTheme(_themeMode); // save to prefs
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale); // update locale in state
    _persistLocale(locale); // save to prefs
  }

  @override
  Widget build(BuildContext context) {
    // Provide ConnectionCubit once for the whole app
    return BlocProvider(
      create: (_) => ConnectionCubit(), // start monitoring connectivity
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // hide debug banner
        title: 'Hobby Sphere', // app title
        navigatorKey: navigatorKey, // optional global key (from your router)
        initialRoute: Routes.splash, // first screen route
        onGenerateRoute: _router.onGenerateRoute, // classic Navigator 1.0
        themeMode: _themeMode, // current theme mode
        theme: AppTheme.light, // your light theme
        darkTheme: AppTheme.dark, // your dark theme
        locale: _locale, // current locale
        localizationsDelegates:
            AppLocalizations.localizationsDelegates, // i18n delegates
        supportedLocales:
            AppLocalizations.supportedLocales, // supported locales
        // builder lets us wrap ALL pages with a global top banner that has theme + l10n context
        builder: (context, child) {
          // child = the current routed page
          return Stack(
            children: [
              if (child != null) child, // place actual page behind
              const Positioned(
                top: 0,
                left: 0,
                right: 0, // stick to top edge
                child:
                    ConnectionBanner(), // show connecting/offline banner globally
              ),
            ],
          );
        },
      ),
    );
  }
}
