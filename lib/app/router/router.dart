// ===== Flutter 3.35.x =====
// router.dart — central app router (Navigator 1.0, onGenerateRoute)
// This version HARD-WIRES the repos for the Create Item route
// so you DON'T need Provider for ItemTypeRepository / CurrencyRepository.

import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';

// ---------- screens you already have ----------
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/screen/login_page.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/navigation/nav_bootstrap.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';

// ---------- new Create Item (BLoC) page ----------
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/screen/create_item_page.dart';

// ---------- domain usecases ----------
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// ---------- data layer: services + repositories impl (ADJUST PATHS if needed) ----------

import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';

/// Named routes
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const onboardingScreen = '/onboardingScreen';
  static const login = '/login';
  static const userHome = '/user/home';
  static const businessHome = '/business/home';
  static const createBusinessActivity = '/business/activity/create';
  static const shell = '/shell';
}

/// Business Home args
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

/// Shell args
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

/// Create Item args — we only pass businessId (token is read by BLoC via TokenStore)
class CreateActivityRouteArgs {
  final int businessId;
  const CreateActivityRouteArgs({required this.businessId});
}

/// Optional navigator key (useful for programmatic navigation)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
      // Splash
      case Routes.splash:
        return _page(const SplashPage(), settings);

      // Static onboarding
      case Routes.onboarding:
        return _page(const OnboardingPage(), settings);

      // Animated onboarding
      case Routes.onboardingScreen:
        return _page(
          OnboardingScreen(
            onToggleTheme: onToggleTheme,
            onChangeLocale: onChangeLocale,
            currentLocale: getCurrentLocale(),
          ),
          settings,
        );

      // Login
      case Routes.login:
        return _page(const LoginPage(), settings);

      // User home
      case Routes.userHome:
        return _page(const UserHomeScreen(), settings);

      // Business home
      case Routes.businessHome:
        {
          final data = args is BusinessHomeRouteArgs ? args : null;
          if (data == null)
            return _error(
              'Missing BusinessHomeRouteArgs (token + businessId).',
            );

          return _page(
            BusinessHomeScreen(
              token: data.token,
              businessId: data.businessId,
              onCreate:
                  data.onCreateOverride ??
                  () {
                    final ctx = navigatorKey.currentContext!;
                    Navigator.pushNamed(
                      ctx,
                      Routes.createBusinessActivity,
                      arguments: CreateActivityRouteArgs(
                        businessId: data.businessId,
                      ),
                    );
                  },
            ),
            settings,
          );
        }

      // Create Item (BLoC) — HARD-WIRED repos (no Provider required)
      case Routes.createBusinessActivity:
        {
          final data = args is CreateActivityRouteArgs ? args : null;
          if (data == null)
            return _error('Missing CreateActivityRouteArgs (businessId).');

          return MaterialPageRoute(
            settings: settings,
            builder: (_) {
              // Build services/repositories locally to avoid Provider
              final itemTypeSvc = ItemTypesService();
              final currencySvc = CurrencyService();
              final itemTypeRepo = ItemTypeRepositoryImpl(itemTypeSvc);
              final currencyRepo = CurrencyRepositoryImpl(currencySvc);

              // Usecases
              final getItemTypes = GetItemTypes(itemTypeRepo);
              final getCurrency = GetCurrentCurrency(currencyRepo);

              return CreateItemPage(
                businessId: data.businessId,
                getItemTypes: getItemTypes,
                getCurrentCurrency: getCurrency,
              );
            },
          );
        }

      // Role-aware shell
      case Routes.shell:
        {
          final data = args is ShellRouteArgs ? args : null;
          if (data == null)
            return _error(
              'Missing ShellRouteArgs (role + token + businessId).',
            );

          return _page(
            NavBootstrap(
              role: data.role,
              token: data.token,
              businessId: data.businessId,
            ),
            settings,
          );
        }

      // Fallback → splash
      default:
        return _page(const SplashPage(), settings);
    }
  }

  MaterialPageRoute _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);

  MaterialPageRoute _error(String message) =>
      MaterialPageRoute(builder: (_) => _RouteErrorPage(message: message));
}

class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Routing Error'), centerTitle: true),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
