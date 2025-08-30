// ===== Flutter 3.35.x =====
// config/router.dart
// Central place for all routes.
// Adds: /business/activity/create (with full DI wiring).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hobby_sphere/core/constants/app_role.dart'; // role enum

// ===== existing pages =====
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/navigation/nav_bootstrap.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/screen/login_page.dart';

// ===== Create Activity feature (paths per your structure) =====
import 'package:hobby_sphere/features/activities/Business/createActivity/data/services/business_create_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/data/repositories/create_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/create_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/get_activity_types.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/state/create_business_activity_controller.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/screen/create_business_activity_screen.dart';

// ===== small args holders =====
class BusinessHomeRouteArgs {
  final String token;
  final int businessId;
  final VoidCallback? onCreateOverride;

  const BusinessHomeRouteArgs({
    required this.token,
    required this.businessId,
    this.onCreateOverride,
  });
}

class ShellRouteArgs {
  final AppRole role;
  final String token;
  final int businessId;

  const ShellRouteArgs({
    required this.role,
    required this.token,
    required this.businessId,
  });
}

class CreateActivityRouteArgs {
  final String token;
  final int businessId;

  const CreateActivityRouteArgs({
    required this.token,
    required this.businessId,
  });
}

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
    final name = settings.name;
    final args = settings.arguments;

    switch (name) {
      // ===== splash =====
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());

      // ===== onboarding (static) =====
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      // ===== onboarding (animated) =====
      case '/onboardingScreen':
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onToggleTheme: onToggleTheme,
            onChangeLocale: onChangeLocale,
            currentLocale: getCurrentLocale(),
          ),
        );

      // ===== login =====
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      // ===== user home =====
      case '/user/home':
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());

      // ===== business home =====
      case '/business/home':
        {
          final data = args is BusinessHomeRouteArgs ? args : null;
          if (data == null) {
            return _error(
              'Missing BusinessHomeRouteArgs (token + businessId).',
            );
          }
          return MaterialPageRoute(
            builder: (ctx) => BusinessHomeScreen(
              token: data.token,
              businessId: data.businessId,
              onCreate:
                  data.onCreateOverride ??
                  () {
                    Navigator.pushNamed(
                      ctx,
                      '/business/activity/create',
                      arguments: CreateActivityRouteArgs(
                        token: data.token,
                        businessId: data.businessId,
                      ),
                    );
                  },
            ),
          );
        }

      // ===== create activity =====
      case '/business/activity/create':
        {
          final data = args is CreateActivityRouteArgs ? args : null;
          if (data == null) {
            return _error(
              'Missing CreateActivityRouteArgs (token + businessId).',
            );
          }

          // DI wiring
          final service = BusinessCreateActivityService();
          final repo = CreateActivityRepositoryImpl(service);
          final createUsecase = CreateBusinessActivity(repo);
          final getTypesUsecase = GetActivityTypes(repo);

          return MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => CreateBusinessActivityController(
                createUsecase: createUsecase,
                getTypesUsecase: getTypesUsecase,
              ),
              child: CreateBusinessActivityScreen(
                businessId: data.businessId,
                token: data.token,
              ),
            ),
            settings: RouteSettings(
              name: '/business/activity/create',
              arguments: data,
            ),
          );
        }

      // ===== role-aware shell =====
      case '/shell':
        {
          final data = args is ShellRouteArgs ? args : null;
          if (data == null) {
            return _error(
              'Missing ShellRouteArgs (role + token + businessId).',
            );
          }
          return MaterialPageRoute(
            builder: (_) => NavBootstrap(
              role: data.role,
              token: data.token,
              businessId: data.businessId,
            ),
          );
        }

      // ===== default =====
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }

  // tiny helper
  MaterialPageRoute _error(String message) {
    return MaterialPageRoute(builder: (_) => _RouteErrorPage(message: message));
  }
}

class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Routing Error'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
