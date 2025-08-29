// ===== Flutter 3.35.x =====
// NavBootstrap: load theme → decide navigation type (bottom/top/drawer)
// → build the matching shell and PASS role + token + businessId.

import 'package:flutter/material.dart'; // core UI widgets
import 'package:hobby_sphere/features/activities/common/data/services/theme_service.dart'; // get active theme json

import '../app/router/nav_type.dart'; // enum: bottom / top / drawer
import '../app/router/nav_from_theme.dart'; // parser: json → AppNavType
import '../core/constants/app_role.dart'; // enum: user / business / guest

import 'shell_bottom.dart'; // bottom tabs shell (needs role, token, businessId)
import 'shell_top.dart'; // top tabs shell (needs role, token, businessId)
import 'shell_drawer.dart'; // drawer shell (needs role, token, businessId)

class NavBootstrap extends StatefulWidget {
  final AppRole role; // current role (decides which pages to show)
  final String token; // JWT token (BusinessHomeScreen needs it)
  final int businessId; // business id (BusinessHomeScreen needs it)

  const NavBootstrap({
    super.key, // widget key
    required this.role, // pass role from login
    required this.token, // pass token from login
    required this.businessId, // pass business id from login
  });

  @override
  State<NavBootstrap> createState() => _NavBootstrapState(); // create state
}

class _NavBootstrapState extends State<NavBootstrap> {
  final _themeService = ThemeService(); // service to fetch active theme
  late final Future<AppNavType> _future; // will hold nav type from backend

  @override
  void initState() {
    super.initState(); // base init
    _future = _load(); // start loading nav type once
  }

  Future<AppNavType> _load() async {
    try {
      // ask backend for active mobile theme json
      final json = await _themeService.getActiveMobileTheme(); // GET
      // parse to AppNavType (bottom/top/drawer)
      return navTypeFromTheme(json); // parse safely
    } catch (_) {
      // on error, use a safe default
      return AppNavType.bottom; // fallback to bottom tabs
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppNavType>(
      future: _future, // wait for nav type
      builder: (context, snap) {
        // while loading show simple spinner
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // loader
          );
        }

        // get type or fallback
        final type = snap.data ?? AppNavType.bottom; // default bottom

        // build the right shell and PASS role + token + businessId
        switch (type) {
          case AppNavType.top:
            // top tabs shell
            return ShellTop(
              role: widget.role, // role down
              token: widget.token, // token down
              businessId: widget.businessId, // id down
            );

          case AppNavType.drawer:
            // drawer shell
            return ShellDrawer(
              role: widget.role, // role down
              token: widget.token, // token down
              businessId: widget.businessId, // id down
            );

          case AppNavType.bottom:
          default:
            // bottom tabs shell
            return ShellDrawer(
              role: widget.role, // role down
              token: widget.token, // token down
              businessId: widget.businessId, // id down
            );
        }
      },
    );
  }
}
