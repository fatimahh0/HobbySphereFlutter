// config/router.dart
import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/auth/presentation/pages/login_page.dart';
import 'package:hobby_sphere/features/onboarding/presentation/pages/OnboardingScreen.dart';

import 'package:hobby_sphere/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hobby_sphere/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  final VoidCallback onToggleTheme;
  final void Function(Locale) onChangeLocale;
  final Locale Function() getCurrentLocale;

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
      
        return MaterialPageRoute(
          builder: (_) => OnboardingPage(
           
          ),
        );

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

      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
