// lib/app/router/router.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// lib/app/router/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/PrivacyPolicyScreen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/features/activities/routes_activity.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/screens/forgot_password_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/screen/login_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_email_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_page.dart';


abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const onboardingScreen = '/onboardingScreen';
  static const login = '/login';
  static const register = '/register';
  static const registerEmail = '/register/email';
  static const userHome = '/user/home';
  static const businessHome = '/business/home';
  static const userTicketsCalendar = '/user/tickets/calendar';
  static const createBusinessActivity = '/business/activity/create';
  static const editBusinessActivity = '/business/activity/edit';
  static const businessBookings = '/business/bookings';
  static const businessAnalytics = '/business/analytics';
  static const shell = '/shell';
  static const businessReviews = '/business/reviews';
  static const businessActivities = '/business/activities';
  static const privacyPolicy = '/privacy-policy';
  static const editBusiness = '/business/edit';
  static const businessProfile = '/business/profile';
  static const businessNotifications = '/business/notifications';
  static const reopenItem = '/business/reopenitem';
  static const businessActivityDetails = '/business/activity/details';
  static const businessInsights = '/business/insights';
  static const businessUsers = '/business/businessUser';
  static const inviteManager = '/business/invite-manager';
  static const userActivityDetail = '/user/activity/details';
  static const editUserProfile = '/user/edit-profile';
  static const editInterests = '/user/edit-interests';
  static const userNotifications = '/user-notifications';
  // Community / Social
  static const community = '/community';
  static const createPost = '/community/create';
  static const commentPost = '/community/comments';
  static const addFriend = '/community/add-friend';
  static const myPosts = '/community/myposts';
  static const friendship = '/community/chat';
  static const forgot = '/forgot';
}

// ====== نفس الـ Args classes تبعك (copy) ======
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

class MyPostsRouteArgs {
  final String token;
  final int userId;
  final String? imageBaseUrl;
  const MyPostsRouteArgs({
    required this.token,
    required this.userId,
    this.imageBaseUrl,
  });
}

class BusinessProfileRouteArgs {
  final String token;
  final int businessId;
  const BusinessProfileRouteArgs({
    required this.token,
    required this.businessId,
  });
}

class BusinessActivityDetailsRouteArgs {
  final String token;
  final int activityId;
  const BusinessActivityDetailsRouteArgs({
    required this.token,
    required this.activityId,
  });
}

class EditInterestsRouteArgs {
  final String token;
  final int userId;
  const EditInterestsRouteArgs({required this.token, required this.userId});
}

typedef TicketsLoader = Future<List<BookingEntity>> Function();

class CalendarTicketsRouteArgs {
  final TicketsLoader loadTickets;
  const CalendarTicketsRouteArgs({required this.loadTickets});
}

class RegisterEmailRouteArgs {
  final int initialRoleIndex;
  const RegisterEmailRouteArgs({this.initialRoleIndex = 0});
}

class BusinessInsightsRouteArgs {
  final String token;
  final int businessId;
  final int itemId;
  const BusinessInsightsRouteArgs({
    required this.token,
    required this.businessId,
    required this.itemId,
  });
}

class BusinessUsersRouteArgs {
  final String token;
  final int businessId;
  final int itemId;
  final List<int>? enrolledUserIds;
  const BusinessUsersRouteArgs({
    required this.token,
    required this.businessId,
    required this.itemId,
    this.enrolledUserIds,
  });
}

class CreateActivityRouteArgs {
  final int businessId;
  final String token;
  const CreateActivityRouteArgs({
    required this.businessId,
    required this.token,
  });
}

class BusinessNotificationsRouteArgs {
  final String token;
  final int businessId;
  const BusinessNotificationsRouteArgs({
    required this.token,
    required this.businessId,
  });
}

class BusinessActivitiesRouteArgs {
  final String token;
  final int businessId;
  const BusinessActivitiesRouteArgs({
    required this.token,
    required this.businessId,
  });
}

class EditBusinessRouteArgs {
  final String token;
  final int businessId;
  const EditBusinessRouteArgs({required this.token, required this.businessId});
}

class UserHomeRouteArgs {
  final String token;
  final int userId;
  final String? firstName;
  final String? lastName;
  const UserHomeRouteArgs({
    required this.token,
    required this.userId,
    this.firstName,
    this.lastName,
  });
}

class EditUserProfileRouteArgs {
  final String token;
  final int userId;
  const EditUserProfileRouteArgs({required this.token, required this.userId});
}

class UserActivityDetailRouteArgs {
  final int itemId;
  final String? token;
  final String? currencyCode;
  final String? imageBaseUrl;
  const UserActivityDetailRouteArgs({
    required this.itemId,
    this.token,
    this.currencyCode,
    this.imageBaseUrl,
  });
}

class ReopenItemRouteArgs {
  final int businessId;
  final BusinessActivity oldItem;
  const ReopenItemRouteArgs({required this.businessId, required this.oldItem});
}

class BusinessReviewsRouteArgs {
  final int businessId;
  final String token;
  const BusinessReviewsRouteArgs({
    required this.businessId,
    required this.token,
  });
}

class RegisterRouteArgs {
  final int initialRoleIndex;
  const RegisterRouteArgs({this.initialRoleIndex = 0});
}

class UserNotificationsRouteArgs {
  final String token;
  const UserNotificationsRouteArgs({required this.token});
}

class ConversationRouteArgs {
  final int myId;
  final UserMin peer;
  const ConversationRouteArgs({required this.myId, required this.peer});
}


final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

typedef LocaleGetter = Locale Function();

class AppRouter {
  static GoRouter build({
    required List<String> enabledFeatures,
    required VoidCallback onToggleTheme,
    required void Function(Locale) onChangeLocale,
    required LocaleGetter getCurrentLocale,
  }) {
    
    final commonRoutes = _commonRoutes(
      onToggleTheme: onToggleTheme,
      onChangeLocale: onChangeLocale,
      getCurrentLocale: getCurrentLocale,
    );

    final activityRoutes = enabledFeatures.contains('activity')
        ? buildActivityRoutes(
            onToggleTheme: onToggleTheme,
            onChangeLocale: onChangeLocale,
            getCurrentLocale: getCurrentLocale,
          )
        : <RouteBase>[];

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: Routes.splash,
      routes: [...commonRoutes, ...activityRoutes],
      errorBuilder: (_, state) => _RouteErrorPage(
        message: state.error?.toString() ?? 'Unknown route error',
      ),
    );
  }
}


List<RouteBase> _commonRoutes({
  required VoidCallback onToggleTheme,
  required void Function(Locale) onChangeLocale,
  required LocaleGetter getCurrentLocale,
}) {
  return [
    GoRoute(
      path: Routes.splash,
      name: Routes.splash,
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: Routes.onboarding,
      name: Routes.onboarding,
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(
      path: Routes.onboardingScreen,
      name: Routes.onboardingScreen,
      builder: (_, __) => OnboardingScreen(
        onToggleTheme: onToggleTheme,
        onChangeLocale: onChangeLocale,
        currentLocale: getCurrentLocale(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      name: Routes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: Routes.register,
      name: Routes.register,
      builder: (_, __) {
        final dio = g.appDio ?? Dio();
        return RegisterPage(service: RegistrationService(dio));
      },
    ),
    GoRoute(
      path: Routes.registerEmail,
      name: Routes.registerEmail,
      builder: (_, state) {
        final data = state.extra is RegisterEmailRouteArgs
            ? state.extra as RegisterEmailRouteArgs
            : null;
        final dio = g.appDio ?? Dio();
        return RegisterEmailPage(
          service: RegistrationService(dio),
          initialRoleIndex: data?.initialRoleIndex ?? 0,
        );
      },
    ),
    GoRoute(
      path: Routes.forgot,
      name: Routes.forgot,
      builder: (_, state) =>
          ForgotPasswordPage(args: state.extra as ForgotPasswordArgs?),
    ),
    GoRoute(
      path: Routes.privacyPolicy,
      name: Routes.privacyPolicy,
      builder: (_, __) => const PrivacyPolicyScreen(),
    ),
  ];
}


class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message, super.key});

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
