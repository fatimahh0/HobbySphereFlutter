// ===== Flutter 3.35.x =====
// config/router.dart
// Build all app routes in one place.
// Pass token + businessId to BusinessHomeScreen.
// Provide a shell route (NavBootstrap) that picks bottom/top/drawer from theme.

import 'package:flutter/material.dart'; // core UI
import 'package:hobby_sphere/core/constants/app_role.dart';

// ===== existing pages =====

import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart'; // business home (needs params)
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart'; // animated onboarding
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart'; // user home
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart'; // static onboarding
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/navigation/nav_bootstrap.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/screen/login_page.dart'; // splash

// ===== small args holders (type-safe route arguments) =====

// Arguments for BusinessHomeScreen
class BusinessHomeRouteArgs {
  final String token; // JWT token from login
  final int businessId; // business id from login / profile
  final VoidCallback? onCreateOverride; // optional custom create action

  const BusinessHomeRouteArgs({
    required this.token, // required token
    required this.businessId, // required id
    this.onCreateOverride, // optional (defaults to route push)
  });
}

// Arguments for NavBootstrap (shell that picks bottom/top/drawer)
class ShellRouteArgs {
  final AppRole role; // user or business
  final String token; // for business home usage
  final int businessId; // for business home usage

  const ShellRouteArgs({
    required this.role, // role to build correct pages
    required this.token, // JWT for API
    required this.businessId, // current business id
  });
}

class AppRouter {
  // callbacks you already use in onboarding screen
  final VoidCallback onToggleTheme; // switch theme (light/dark)
  final void Function(Locale) onChangeLocale; // change language
  final Locale Function() getCurrentLocale; // read current locale

  AppRouter({
    required this.onToggleTheme, // save theme callback
    required this.onChangeLocale, // save language callback
    required this.getCurrentLocale, // save getter
  });

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // name of the incoming route
    final name = settings.name; // e.g., '/login'
    // dynamic args payload (we cast safely per case)
    final args = settings.arguments; // may be null

    switch (name) {
      // ===== splash as start =====
      case '/':
        // show splash first
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // ===== onboarding (static) =====
      case '/onboarding':
        // simple onboarding page
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      // ===== onboarding (animated, needs callbacks) =====
      case '/onboardingScreen':
        // pass theme + language callbacks
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onToggleTheme: onToggleTheme, // toggle theme
            onChangeLocale: onChangeLocale, // change language
            currentLocale: getCurrentLocale(), // show current locale
          ),
        );

      // ===== login =====
      case '/login':
        // login page (no args)
        return MaterialPageRoute(builder: (_) => const LoginPage());

      // ===== user home (simple) =====
      case '/user/home':
        // direct user home screen
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());

      // ===== business home (DIRECT screen) =====
      // Use this if you only want the BusinessHomeScreen without shells.
      case '/business/home':
        {
          // cast args to our type-safe holder
          final data = args is BusinessHomeRouteArgs ? args : null; // safe cast
          if (data == null) {
            // if missing args, show a friendly error page
            return MaterialPageRoute(
              builder: (_) => _RouteErrorPage(
                message:
                    'Missing BusinessHomeRouteArgs (token + businessId required).',
              ),
            );
          }

          // build the business home and pass parameters
          return MaterialPageRoute(
            builder: (ctx) => BusinessHomeScreen(
              token: data.token, // pass JWT
              businessId: data.businessId, // pass id
              onCreate:
                  data.onCreateOverride ??
                  () {
                    // default: go to create activity route
                    Navigator.pushNamed(
                      ctx,
                      '/business/activity/create', // define this route in your app
                    );
                  },
              // bottomBar is NOT passed here to avoid duplicate bars
            ),
          );
        }

      // ===== universal shell route (RECOMMENDED) =====
      // This builds the role-aware shell (bottom/top/drawer) from theme.
      case '/shell':
        {
          // cast args to ShellRouteArgs
          final data = args is ShellRouteArgs ? args : null; // safe cast
          if (data == null) {
            // if missing, show friendly error
            return MaterialPageRoute(
              builder: (_) => _RouteErrorPage(
                message:
                    'Missing ShellRouteArgs (role + token + businessId required).',
              ),
            );
          }

          // Build NavBootstrap that forwards role + token + businessId
          return MaterialPageRoute(
            builder: (_) => NavBootstrap(
              role: data.role, // user/business
              token: data.token, // JWT (used by business home)
              businessId: data.businessId, // business id
            ),
          );
        }

      // ===== default fallback =====
      default:
        // unknown route → back to splash
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}

// ===== tiny error page (clean message when args are missing) =====
class _RouteErrorPage extends StatelessWidget {
  final String message; // what went wrong
  const _RouteErrorPage({required this.message}); // ctor

  @override
  Widget build(BuildContext context) {
    // use theme colors for a clean look
    final scheme = Theme.of(context).colorScheme; // colors
    final text = Theme.of(context).textTheme; // fonts

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routing Error'), // title
        centerTitle: true, // center
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24), // spacing
          child: Container(
            padding: const EdgeInsets.all(16), // inner padding
            decoration: BoxDecoration(
              color: scheme.errorContainer, // soft error bg
              borderRadius: BorderRadius.circular(12), // rounded
            ),
            child: Text(
              message, // the error text
              textAlign: TextAlign.center, // center text
              style: text.bodyMedium?.copyWith(
                color: scheme.onErrorContainer, // readable color
                fontWeight: FontWeight.w600, // semi-bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
