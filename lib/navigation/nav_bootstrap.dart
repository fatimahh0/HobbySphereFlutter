// ===== Flutter 3.35.x =====
// NavBootstrap: load theme → decide navigation type (bottom/top/drawer)
// → build the matching shell and PASS role + token + businessId + callbacks.

import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/common/data/services/theme_service.dart';

import '../app/router/nav_type.dart';
import '../app/router/nav_from_theme.dart';
import '../core/constants/app_role.dart';

import 'shell_bottom.dart';
import 'shell_top.dart';
import 'shell_drawer.dart';

class NavBootstrap extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;

  // 👇 NEW: callbacks injected from AppRouter
  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;

  const NavBootstrap({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale, // 👈 required
    required this.onToggleTheme, // 👈 required
  });

  @override
  State<NavBootstrap> createState() => _NavBootstrapState();
}

class _NavBootstrapState extends State<NavBootstrap> {
  final _themeService = ThemeService();
  late final Future<AppNavType> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AppNavType> _load() async {
    try {
      final json = await _themeService.getActiveMobileTheme();
      return navTypeFromTheme(json);
    } catch (_) {
      return AppNavType.bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppNavType>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final type = snap.data ?? AppNavType.bottom;

        switch (type) {
          case AppNavType.top:
            return ShellTop(
              role: widget.role,
              token: widget.token,
              businessId: widget.businessId,
              onChangeLocale: widget.onChangeLocale, // 👈 forward
              onToggleTheme: widget.onToggleTheme, // 👈 forward
            );

          case AppNavType.drawer:
            return ShellDrawer(
              role: widget.role,
              token: widget.token,
              businessId: widget.businessId,
              onChangeLocale: widget.onChangeLocale,
              onToggleTheme: widget.onToggleTheme,
            );

          case AppNavType.bottom:
          default:
            return ShellDrawer(
              role: widget.role,
              token: widget.token,
              businessId: widget.businessId,
              onChangeLocale: widget.onChangeLocale,
              onToggleTheme: widget.onToggleTheme,
            );
        }
      },
    );
  }
}
