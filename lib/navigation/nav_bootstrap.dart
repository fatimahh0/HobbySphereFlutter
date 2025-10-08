// lib/navigation/nav_bootstrap.dart
// Loads remote theme / chooses nav type (bottom/top/drawer), then builds the shell.
// Receives real callbacks from AppRouter and forwards them to the shell widgets.

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

  // callbacks injected from router
  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;

  const NavBootstrap({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale,
    required this.onToggleTheme,
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
              onChangeLocale: widget.onChangeLocale,
              onToggleTheme: widget.onToggleTheme,
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
            return ShellBottom(
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
