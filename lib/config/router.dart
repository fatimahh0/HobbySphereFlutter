// config/router.dart
import 'package:flutter/material.dart';

// existing imports
import 'package:hobby_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:hobby_sphere/features/presentation/pages/OnboardingScreen.dart';
import 'package:hobby_sphere/features/presentation/pages/onboarding_page.dart';
import 'package:hobby_sphere/features/presentation/pages/splash_page.dart';
import 'package:hobby_sphere/features/presentation/pages/UserHome.dart';
import 'package:hobby_sphere/features/presentation/pages/BusinessHome.dart';

class AppRouter {
  final VoidCallback onToggleTheme; // theme toggle
  final void Function(Locale) onChangeLocale; // language change
  final Locale Function() getCurrentLocale; // get locale

  AppRouter({
    required this.onToggleTheme,
    required this.onChangeLocale,
    required this.getCurrentLocale,
  });

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case '/onboardingScreen':
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onToggleTheme: onToggleTheme,
            onChangeLocale: onChangeLocale,
            currentLocale: getCurrentLocale(),
          ),
        );

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      //  NEW ROUTES
      case '/user/home':
        return MaterialPageRoute(builder: (_) => const UserHome());

      case '/business/home':
        return MaterialPageRoute(builder: (_) => const BusinessHome());

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
