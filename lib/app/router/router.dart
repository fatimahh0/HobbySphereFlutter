// ===== Flutter 3.35.x =====
// router.dart — central app router (Navigator 1.0, onGenerateRoute)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------- Common screens ----------
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/screen/login_page.dart';

// ---------- User ----------
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';

// ---------- Business ----------
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/edit_item_page.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/screen/create_item_page.dart';

// ---------- Business Bookings ----------
import '../../features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import '../../features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import '../../features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import '../../features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import '../../features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import '../../features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import '../../features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart';

// ---------- Core ----------
import 'package:hobby_sphere/navigation/nav_bootstrap.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';

// ---------- Domain usecases ----------
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

// ---------- Data layer ----------
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';

/// Named routes
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const onboardingScreen = '/onboardingScreen';
  static const login = '/login';
  static const userHome = '/user/home';
  static const businessHome = '/business/home';
  static const createBusinessActivity = '/business/activity/create';
  static const editBusinessActivity = '/business/activity/edit';
  static const businessBookings = '/business/bookings';
  static const shell = '/shell';
}

// ===== Route Args =====
class EditActivityRouteArgs {
  final int itemId;
  final int businessId;
  const EditActivityRouteArgs({required this.itemId, required this.businessId});
}

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
  final int businessId;
  const CreateActivityRouteArgs({required this.businessId});
}

/// Global navigator key (for programmatic navigation)
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
      // ===== Common =====
      case Routes.splash:
        return _page(const SplashPage(), settings);

      case Routes.onboarding:
        return _page(const OnboardingPage(), settings);

      case Routes.onboardingScreen:
        return _page(
          OnboardingScreen(
            onToggleTheme: onToggleTheme,
            onChangeLocale: onChangeLocale,
            currentLocale: getCurrentLocale(),
          ),
          settings,
        );

      case Routes.login:
        return _page(const LoginPage(), settings);

      // ===== Business Bookings =====
      case Routes.businessBookings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final repo = BusinessBookingRepositoryImpl(
              BusinessBookingService(),
            );
            return BlocProvider(
              create: (ctx) => BusinessBookingBloc(
                getBookings: GetBusinessBookings(repo),
                updateStatus: UpdateBookingStatus(repo),
              )..add(BusinessBookingBootstrap()), // bootstrap fetch
              child: const BusinessBookingScreen(),
            );
          },
        );

      // ===== User =====
      case Routes.userHome:
        return _page(const UserHomeScreen(), settings);

      // ===== Business Home =====
      case Routes.businessHome:
        final data = args is BusinessHomeRouteArgs ? args : null;
        if (data == null) {
          return _error('Missing BusinessHomeRouteArgs (token + businessId).');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BusinessHomeScreen(
            token: data.token,
            businessId: data.businessId,
            onCreate: (ctx, bid) {
              navigatorKey.currentState?.pushNamed(
                Routes.createBusinessActivity,
                arguments: CreateActivityRouteArgs(businessId: bid),
              );
            },
          ),
        );

      // ===== Create Activity =====
      case Routes.createBusinessActivity:
        final data = args is CreateActivityRouteArgs ? args : null;
        if (data == null) return _error("Missing CreateActivityRouteArgs");

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateItemPage(
            businessId: data.businessId,
            getItemTypes: GetItemTypes(
              ItemTypeRepositoryImpl(ItemTypesService()),
            ),
            getCurrentCurrency: GetCurrentCurrency(
              CurrencyRepositoryImpl(CurrencyService()),
            ),
          ),
        );

      // ===== Edit Activity =====
      case Routes.editBusinessActivity:
        final data = args is EditActivityRouteArgs ? args : null;
        if (data == null) {
          return _error('Missing EditActivityRouteArgs (itemId + businessId).');
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final itemTypeRepo = ItemTypeRepositoryImpl(ItemTypesService());
            final currencyRepo = CurrencyRepositoryImpl(CurrencyService());
            final getItemTypes = GetItemTypes(itemTypeRepo);
            final getCurrency = GetCurrentCurrency(currencyRepo);

            final activityRepo = BusinessActivityRepositoryImpl(
              BusinessActivityService(),
            );
            final getOne = GetBusinessActivityById(activityRepo);

            return EditItemPage(
              itemId: data.itemId,
              businessId: data.businessId,
              getItemTypes: getItemTypes,
              getCurrentCurrency: getCurrency,
              getItemById: getOne,
            );
          },
        );

      // ===== Role-aware shell =====
      case Routes.shell:
        final data = args is ShellRouteArgs ? args : null;
        if (data == null) {
          return _error('Missing ShellRouteArgs (role + token + businessId).');
        }
        return _page(
          NavBootstrap(
            role: data.role,
            token: data.token,
            businessId: data.businessId,
          ),
          settings,
        );

      // ===== Fallback =====
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
