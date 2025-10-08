import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef ToggleTheme = void Function();
typedef ChangeLocale = void Function(Locale);
typedef GetLocale = Locale Function();

abstract class FeatureModule {
  String get key; // e.g. 'activity', 'auth', 'payment'

  // IMPORTANT: RouteBase so you can return GoRoute OR ShellRoute.
  List<RouteBase> routes({
    required ToggleTheme onToggleTheme,
    required ChangeLocale onChangeLocale,
    required GetLocale getCurrentLocale,
  });

  void registerDI() {}
}
