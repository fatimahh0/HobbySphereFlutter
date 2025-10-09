// Dynamic nav chooser (feature-agnostic)
// 1) fetch remote theme json
// 2) extract nav type (bottom/top/drawer)
// 3) call the right shell builder passed by the feature

import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/features/activities/common/data/services/theme_service.dart';
// your theme API service
import '../app/router/nav_type.dart'; // enum
import '../app/router/nav_from_theme.dart'; // json -> enum
import '../core/constants/app_role.dart'; // AppRole

// Reusable builders signature so each feature can render its own tabs/screens
typedef BuildShell =
    Widget Function(
      BuildContext context, // context
      AppRole role, // user/business
      String token, // jwt or ''
      int businessId, // business id (0 if not used)
      void Function(Locale) onChangeLocale, // i18n callback
      VoidCallback onToggleTheme, // theme callback
    );

class NavBootstrap extends StatefulWidget {
  final AppRole role; // role
  final String token; // jwt
  final int businessId; // business id
  final void Function(Locale) onChangeLocale; // i18n
  final VoidCallback onToggleTheme; // theme toggle

  // 3 builders injected by the feature (Activity / Product / etc.)
  final BuildShell buildBottom; // bottom shell
  final BuildShell buildTop; // top shell
  final BuildShell buildDrawer; // drawer shell

  const NavBootstrap({
    super.key, // key
    required this.role, // role
    required this.token, // token
    required this.businessId, // businessId
    required this.onChangeLocale, // i18n
    required this.onToggleTheme, // theme
    required this.buildBottom, // bottom builder
    required this.buildTop, // top builder
    required this.buildDrawer, // drawer builder
  });

  @override
  State<NavBootstrap> createState() => _NavBootstrapState(); // state
}

class _NavBootstrapState extends State<NavBootstrap> {
  final _themeService = ThemeService(); // api service
  late final Future<AppNavType> _future; // future nav type

  @override
  void initState() {
    super.initState(); // init
    _future = _load(); // kick off fetch
  }

  Future<AppNavType> _load() async {
    try {
      final json = await _themeService
          .getActiveMobileTheme(); // fetch theme json
      return navTypeFromTheme(json); // parse to enum
    } catch (_) {
      return AppNavType.bottom; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppNavType>(
      // wait for enum
      future: _future, // future
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          // still loading?
          return const Scaffold(
            // minimal loader
            body: Center(child: CircularProgressIndicator()), // spinner
          );
        }

        final nav = snap.data ?? AppNavType.bottom; // resolved or fallback

        // call the proper shell builder (feature decides its pages)
        switch (nav) {
          case AppNavType.top:
            return widget.buildTop(
              context,
              widget.role,
              widget.token,
              widget.businessId,
              widget.onChangeLocale,
              widget.onToggleTheme, // pass callbacks
            );
          case AppNavType.drawer:
            return widget.buildDrawer(
              context,
              widget.role,
              widget.token,
              widget.businessId,
              widget.onChangeLocale,
              widget.onToggleTheme,
            );
          case AppNavType.bottom:
          default:
            return widget.buildBottom(
              context,
              widget.role,
              widget.token,
              widget.businessId,
              widget.onChangeLocale,
              widget.onToggleTheme,
            );
        }
      },
    );
  }
}
