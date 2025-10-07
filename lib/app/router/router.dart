import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/BusinessActivityDetails/presentation/screen/business_activity_details_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/presentation/screens/business_insights_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessReviews/presentation/screens/business_reviews_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/presentation/screens/business_users_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/screens/business_notification_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart'
    as bprof_repo;
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart'
    as bprof_svc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/create_stripe_connect_link.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/create_stripe_connect_link.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/ReopenItemPage.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/data/repositories/edit_business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/data/services/edit_business_service.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_banner.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_logo.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/update_business.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/update_status.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/presentation/bloc/edit_business_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/presentation/screens/edit_business_screen.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';
import 'package:hobby_sphere/features/activities/common/presentation/PrivacyPolicyScreen.dart';

// ---------- Common screens ----------
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/repositories/edit_user_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/services/edit_user_service.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_account_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_edit_user_image.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/get_edit_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/update_edit_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/bloc/edit_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/bloc/edit_profile_event.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/screens/edit_profile_screen.dart';
import 'package:hobby_sphere/features/activities/user/interests/presentation/screens/edit_interests_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/data/repositories/chat_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/social/data/repositories/friends_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/social/data/services/friends_service.dart';
import 'package:hobby_sphere/features/activities/user/social/data/services/message_service.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/usecases/chat_usecases.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/usecases/friends_usecases.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/chat/chat_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/chat/chat_event.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/add_friend_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/chat_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/conversation_screen.dart';
import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/calendar_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/data/repositories/user_activity_detail_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/data/services/user_activity_detail_service.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/check_user_availability.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/confirm_user_booking.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/get_user_activity_detail.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/presentation/screens/user_activity_detail_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/community_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/my_posts_screen.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart'
    show GetInterestBasedItems;
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/presentation/screens/user_notification_screen.dart';

import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/screens/forgot_password_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart';

// ---------- User ----------
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';

// ---------- Business ----------
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/edit_item_page.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/screen/create_item_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart';

import 'package:hobby_sphere/features/authentication/login&register/presentation/login/screen/login_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_email_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_page.dart';

// ---------- Business Bookings ----------
import '../../features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import '../../features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import '../../features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import '../../features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import '../../features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import '../../features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import '../../features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart'
    hide BusinessBookingBloc;

// ---------- Business Analytics ----------
import '../../features/activities/Business/BusinessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import '../../features/activities/Business/BusinessAnalytics/data/services/business_analytics_service.dart';
import '../../features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import '../../features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import '../../features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import '../../features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';

// ---------- Invite Manager (NEW) ----------
import 'package:hobby_sphere/features/activities/Business/BusinessUserInvite/presentation/screens/invite_manager_screen.dart';

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

import '../../features/authentication/login&register/data/services/registration_service.dart';

/// Named routes
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const onboardingScreen = '/onboardingScreen';
  static const login = '/login';
  static const register = '/register';
  static const registerEmail = '/register/email';
  static const userHome = '/user/home';
  static const businessHome = '/business/home';
  static const userTicketsCalendar = '/user/tickets/calendar'; // user calendar
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
  static const userActivityDetail = '/user/activity/details'; // user detail
  static const editUserProfile = '/user/edit-profile';
  static const editInterests = '/user/edit-interests'; // edit interests screen
  static const userNotifications = '/user-notifications';
  // Community / Social
  static const community = '/community';
  static const createPost = '/community/create';
  static const commentPost = '/community/comments';
  static const addFriend = '/community/add-friend'; // placeholder
  static const myPosts = '/community/myposts'; // placeholder
  static const friendship = '/community/chat'; // placeholder
  static const forgot = '/forgot';
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

class MyPostsRouteArgs {
  final String token; // jwt token
  final int userId; // current user id
  final String? imageBaseUrl; // optional base for relative images
  const MyPostsRouteArgs({
    required this.token, // required token
    required this.userId, // required id
    this.imageBaseUrl, // optional base url
  });
}

// Put with the other *RouteArgs classes
class BusinessProfileRouteArgs {
  final String token; // bearer JWT for API
  final int businessId; // current business id
  const BusinessProfileRouteArgs({
    required this.token, // pass token
    required this.businessId, // pass id
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

// args for Edit Interests screen
class EditInterestsRouteArgs {
  final String token; // bearer token (raw ok)
  final int userId; // numeric user id
  const EditInterestsRouteArgs({
    required this.token, // set token
    required this.userId, // set id
  });
}

/// Loader typedef — same signature your Tickets screen already uses
typedef TicketsLoader =
    Future<List<BookingEntity>> Function(); // returns all tickets

/// Args for Calendar Tickets route — inject the SAME loader used by Tickets screen
class CalendarTicketsRouteArgs {
  final TicketsLoader loadTickets; // callback to fetch tickets
  const CalendarTicketsRouteArgs({required this.loadTickets}); // require it
}

class RegisterEmailRouteArgs {
  final int initialRoleIndex;
  const RegisterEmailRouteArgs({this.initialRoleIndex = 0});
}

class BusinessInsightsRouteArgs {
  final String token;
  final int businessId;
  final int itemId;

  BusinessInsightsRouteArgs({
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
  const CreateActivityRouteArgs({required this.businessId});
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

// >>> UPDATED: use first/last name (no username)
class UserHomeRouteArgs {
  final String token; // user jwt
  final int userId; // numeric user id
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
  // args model
  final int itemId; // item id
  final String? token; // bearer token (optional for guest)
  final String? currencyCode; // currency (e.g. CAD)
  final String? imageBaseUrl; // server base for relative images
  const UserActivityDetailRouteArgs({
    // ctor
    required this.itemId, // set id
    this.token, // set token
    this.currencyCode, // set currency
    this.imageBaseUrl, // set base
  });
}

class ReopenItemRouteArgs {
  final int businessId;
  final BusinessActivity oldItem;

  ReopenItemRouteArgs({required this.businessId, required this.oldItem});
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
  /// 0 = user, 1 = business
  final int initialRoleIndex;
  const RegisterRouteArgs({this.initialRoleIndex = 0});
}

class UserNotificationsRouteArgs {
  final String token;
  const UserNotificationsRouteArgs({required this.token});
}

// Open a single conversation with a peer.
// We pass *myId* so ChatBloc knows who is the sender.
class ConversationRouteArgs {
  final int myId; // current logged-in user id
  final UserMin peer; // the contact to chat with
  const ConversationRouteArgs({required this.myId, required this.peer});
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

      case Routes.register:
        {
          final dio = g.appDio ?? Dio();
          return _page(
            RegisterPage(service: RegistrationService(dio)),
            settings,
          );
        }

      case Routes.forgot:
        {
          // read typed args if provided (optional)
          final fpArgs = args is ForgotPasswordArgs ? args : null; // cast args
          // open page with DI included inside the page (already in the file)
          return _page(ForgotPasswordPage(args: fpArgs), settings); // go
        }

      case Routes.registerEmail:
        {
          final dio = g.appDio ?? Dio();
          final data = args is RegisterEmailRouteArgs ? args : null;
          return _page(
            RegisterEmailPage(
              service: RegistrationService(dio),
              initialRoleIndex: data?.initialRoleIndex ?? 0,
            ),
            settings,
          );
        }

      case Routes.businessReviews:
        final data = args is BusinessReviewsRouteArgs ? args : null;
        if (data == null) {
          return _error(
            "Missing BusinessReviewsRouteArgs (businessId + token).",
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BusinessReviewsScreen(
            businessId: data.businessId,
            token: data.token,
          ),
        );

      // Inside AppRouter.onGenerateRoute's switch(name)
      // Flutter 3.35.x
      // Open Business Profile with all DI (now includes CreateStripeConnectLink)
      case Routes.businessProfile: // route name
        {
          final data = args is BusinessProfileRouteArgs
              ? args
              : null; // safe cast
          if (data == null) {
            // guard missing args
            return _error(
              'Missing BusinessProfileRouteArgs (token + businessId).',
            ); // error page
          }

          return MaterialPageRoute(
            // build route
            settings: settings, // keep route settings
            builder: (_) {
              // 1) Service (HTTP)
              final svc = bprof_svc.BusinessService(); // low-level API service

              // 2) Repository (wraps service)
              final repo = bprof_repo.BusinessRepositoryImpl(svc); // repo impl

              // 3) Use cases (profile stack)
              final getOne = bprof_uc.GetBusinessById(repo); // load business
              final toggleVis = bprof_uc.UpdateBusinessVisibility(
                repo,
              ); // toggle public/private
              final updateStatus = bprof_uc.UpdateBusinessStatus(
                repo,
              ); // set active/inactive
              final deleteBiz = bprof_uc.DeleteBusiness(
                repo,
              ); // delete business
              final checkStripe = bprof_uc.CheckStripeStatus(
                repo,
              ); // check stripe status
              final createStripeLink = bprof_uc.CreateStripeConnectLink(
                repo,
              ); // NEW: create onboarding link

              // 4) Provide the BLoC and fire initial load
              return BlocProvider(
                create: (_) =>
                    BusinessProfileBloc(
                      getBusinessById: getOne, // inject usecase
                      updateBusinessVisibility: toggleVis, // inject usecase
                      updateBusinessStatus: updateStatus, // inject usecase
                      deleteBusiness: deleteBiz, // inject usecase
                      checkStripeStatus: checkStripe, // inject usecase
                      createStripeConnectLink:
                          createStripeLink, // NEW: inject usecase
                    )..add(
                      LoadBusinessProfile(data.token, data.businessId),
                    ), // initial load
                child: BusinessProfileScreen(
                  token: data.token, // pass token to screen
                  businessId: data.businessId, // pass id to screen
                  onChangeLocale: onChangeLocale, // keep language callback
                ),
              );
            },
          );
        }

      case Routes.login:
        return _page(const LoginPage(), settings);

      case Routes.privacyPolicy:
        return _page(const PrivacyPolicyScreen(), settings);

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
              )..add(BusinessBookingBootstrap()),
              child: const BusinessBookingScreen(),
            );
          },
        );

      case Routes.reopenItem:
        final rArgs = settings.arguments as ReopenItemRouteArgs;
        return MaterialPageRoute(
          builder: (_) => ReopenItemPage(
            businessId: rArgs.businessId,
            oldItem: rArgs.oldItem,
            getItemTypes: GetItemTypes(
              ItemTypeRepositoryImpl(ItemTypesService()),
            ),
            getCurrentCurrency: GetCurrentCurrency(
              CurrencyRepositoryImpl(CurrencyService()),
            ),
          ),
        );

      // ===== User Activity Detail (user) =====
      case Routes.userActivityDetail:
        final uaArgs = args is UserActivityDetailRouteArgs
            ? args
            : null; // read args
        if (uaArgs == null) {
          // guard
          return _error(
            'Missing UserActivityDetailRouteArgs (itemId).',
          ); // error page
        }
        return MaterialPageRoute(
          // build route
          settings: settings, // keep settings
          builder: (_) {
            // page builder
            // Simple local DI (service + repo + usecases)                 // DI note
            final repo = UserActivityDetailRepositoryImpl(
              // repo impl
              UserActivityDetailService(), // service
            );
            final getOne = GetUserActivityDetail(repo); // usecase
            final check = CheckUserAvailability(repo); // usecase
            final confirm = ConfirmUserBooking(repo); // usecase

            // Screen already wires the bloc internally using these UCs     // info
            return UserActivityDetailScreen(
              // screen
              itemId: uaArgs.itemId, // pass id
              imageBaseUrl: uaArgs.imageBaseUrl, // base
              currencyCode: uaArgs.currencyCode, // currency
              bearerToken: uaArgs.token, // token
            );
          },
        );

      // ===== User: Edit Profile =====
      case Routes.editUserProfile:
        final epArgs = args is EditUserProfileRouteArgs ? args : null;
        if (epArgs == null) {
          return _error('Missing EditUserProfileRouteArgs (token + userId).');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            // DI: service -> repo -> usecases -> bloc
            final repo = EditUserRepositoryImpl(EditUserService());
            final getUser = GetEditUser(repo);
            final update = UpdateEditUser(repo);
            final delAcc = DeleteAccountUser(repo);
            final removeImg = DeleteEditUserImage(repo);

            return BlocProvider(
              create: (ctx) => EditProfileBloc(
                getUser: getUser,
                updateUser: update,
                deleteAccount: delAcc,
                deleteImage: removeImg,
              )..add(LoadEditProfile(epArgs.token, epArgs.userId)),
              child: EditProfileScreen(
                token: epArgs.token,
                userId: epArgs.userId,
              ),
            );
          },
        );

      // ===== Edit Interests (user) =====
      case Routes.editInterests:
        {
          // read and validate args
          final ei = args is EditInterestsRouteArgs ? args : null; // cast
          if (ei == null) {
            return _error(
              'Missing EditInterestsRouteArgs (token + userId).',
            ); // guard
          }

          // --- simple local DI for old stack: RegistrationService -> InterestsRepositoryImpl -> GetActivityTypes
          final dio = g.appDio ?? Dio(); // shared Dio or new
          final regService = RegistrationService(
            dio,
          ); // service used to fetch activity types
          final interestsRepo = InterestsRepositoryImpl(regService); // repo
          final getTypes = GetActivityTypes(interestsRepo); // usecase

          // build screen and pass token/id + usecase
          return _page(
            EditInterestsScreen(
              token: ei.token, // pass token
              userId: ei.userId, // pass id
              getTypes: getTypes, // pass old usecase
            ),
            settings,
          );
        }

      // ===== Community / Social =====
      case Routes.community:
        {
          // token can arrive as String or via UserHomeRouteArgs (keep your logic)
          final token = (args is String)
              ? args
              : (args is UserHomeRouteArgs ? args.token : '');

          // derive image base one time (or pass null if you prefer)
          final imageBaseUrl = (g.appServerRoot ?? '').replaceFirst(
            RegExp(r'/api/?$'),
            '',
          );

          // IMPORTANT: we also need the current user id
          final uid = (args is UserHomeRouteArgs)
              ? args.userId
              : 0; // make sure you pass real id

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CommunityScreen(
              token: token, // pass token
              userId: uid, // ← pass user id here
              imageBaseUrl: imageBaseUrl, // pass image base
            ),
          );
        }

      case Routes.createPost:
        {
          final cp = args is CreatePostArgs ? args : null;
          if (cp == null) return _error('Missing CreatePostArgs (token).');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => CreatePostScreen(args: cp),
          );
        }

      // Optional stubs so header buttons don’t break navigation.
      // Swap these to your real screens when ready.
      case Routes.addFriend:
        {
          final meId =
              (args is int) // get my id from args if int
              ? args
              : (args is UserHomeRouteArgs
                    ? args.userId
                    : 0); // or from UserHomeRouteArgs, else 0

          final baseUrl =
              g.appServerRoot ?? ''; // server base (ex: https://host/api)

          final friendsService = FriendsService(
            baseUrl,
          ); // wire HTTP service (friends)
          final friendsRepo = FriendsRepositoryImpl(
            friendsService,
          ); // repo on top of service

          // build needed usecases for the screen
          final getAll = GetAllUsersUC(friendsRepo); // list all users
          final getSuggested = GetSuggestedUC(
            friendsRepo,
          ); // list suggested users
          final sendFriend = SendFriendUC(friendsRepo); // send request
          final cancelFriend = CancelFriendUC(friendsRepo); // cancel request
          final getReceived = GetReceivedUC(friendsRepo); // received requests
          final getSent = GetSentUC(friendsRepo); // sent requests
          final getFriends = GetFriendsUC(friendsRepo); // my friends
          final acceptUC = AcceptUC(friendsRepo); // accept request
          final rejectUC = RejectUC(friendsRepo); // reject request
          final unfriendUC = UnfriendUC(friendsRepo); // unfriend
          final blockUC = BlockUC(friendsRepo); // block user
          final unblockUC = UnblockUC(friendsRepo); // unblock user

          return MaterialPageRoute(
            // open page
            settings: settings, // keep route metadata
            builder: (_) => BlocProvider(
              // provide FriendsBloc
              create: (_) => FriendsBloc(
                getAll: getAll,
                getSuggested: getSuggested,
                sendFriend: sendFriend,
                cancelFriend: cancelFriend,
                getReceived: getReceived,
                getSent: getSent,
                getFriends: getFriends,
                acceptUC: acceptUC,
                rejectUC: rejectUC,
                unfriendUC: unfriendUC,
                blockUC: blockUC,
                unblockUC: unblockUC,
              ),
              child: AddFriendScreen(meId: meId), // target screen
            ),
          );
        }

      case Routes.myPosts:
        {
          // read args safely
          final mp = args is MyPostsRouteArgs ? args : null; // typed cast
          if (mp == null) {
            // guard
            return _error(
              'Missing MyPostsRouteArgs (token + userId).',
            ); // error page
          }

          // if caller didn’t pass imageBaseUrl, derive it from your app server root
          final base =
              mp.imageBaseUrl ??
              (g.appServerRoot ?? '').replaceFirst(
                RegExp(r'/api/?$'),
                '',
              ); // trim /api

          // build the page
          return MaterialPageRoute(
            settings: settings, // keep meta
            builder: (_) => MyPostsScreen(
              // screen
              args: MyPostsArgs(
                // strong args
                token: mp.token, // pass token
                userId: mp.userId, // pass id
                imageBaseUrl: base, // pass base
              ),
            ),
          );
        }

      case Routes.friendship:
        {
          final baseUrl = g.appServerRoot ?? ''; // API base for services

          // ---- A) Direct conversation mode (open dialog with one peer) ----
          if (args is ConversationRouteArgs) {
            final meId = args.myId; // my user id (required)
            final peer = args.peer; // who I'm chatting with

            // Wire repos/services
            final friendsRepo = FriendsRepositoryImpl(FriendsService(baseUrl));
            final chatRepo = ChatRepositoryImpl(
              MessageService(baseUrl),
              meId: meId,
            );

            // Friends UCs (optional header actions)
            final getFriends = GetFriendsUC(friendsRepo);
            final acceptUC = AcceptUC(friendsRepo);
            final rejectUC = RejectUC(friendsRepo);
            final unfriendUC = UnfriendUC(friendsRepo);

            // Chat UCs
            final conversation = ConversationUC(chatRepo);
            final send = SendMessageUC(chatRepo);
            final markRead = MarkReadUC(chatRepo);
            final deleteMsg = DeleteMessageUC(chatRepo);

            return MaterialPageRoute(
              settings: settings,
              builder: (_) => MultiBlocProvider(
                providers: [
                  // Friends (for block/unfriend in menu)
                  BlocProvider(
                    create: (_) => FriendsBloc(
                      getAll: GetAllUsersUC(friendsRepo),
                      getSuggested: GetSuggestedUC(friendsRepo),
                      sendFriend: SendFriendUC(friendsRepo),
                      cancelFriend: CancelFriendUC(friendsRepo),
                      getReceived: GetReceivedUC(friendsRepo),
                      getSent: GetSentUC(friendsRepo),
                      getFriends: getFriends,
                      acceptUC: acceptUC,
                      rejectUC: rejectUC,
                      unfriendUC: unfriendUC,
                      blockUC: BlockUC(friendsRepo),
                      unblockUC: UnblockUC(friendsRepo),
                    ),
                  ),
                  // Chat (NOW passes myId ✅)
                  BlocProvider(
                    create: (_) => ChatBloc(
                      myId: meId, // ✅ important
                      getConversation: conversation,
                      sendMessage: send,
                      markRead: markRead,
                      deleteMessage: deleteMsg,
                    )..add(LoadConversation(peer.id)), // load history
                  ),
                ],
                child: ConversationScreen(peer: peer), // the dialog UI
              ),
            );
          }

          // ---- B) Chat home mode (friends list / recent) ----
          final meId = (args is int)
              ? args
              : (args is UserHomeRouteArgs
                    ? args.userId
                    : 0); // try to read myId
          final friendsRepo = FriendsRepositoryImpl(FriendsService(baseUrl));
          final chatRepo = ChatRepositoryImpl(
            MessageService(baseUrl),
            meId: meId,
          );

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => FriendsBloc(
                    getAll: GetAllUsersUC(friendsRepo),
                    getSuggested: GetSuggestedUC(friendsRepo),
                    sendFriend: SendFriendUC(friendsRepo),
                    cancelFriend: CancelFriendUC(friendsRepo),
                    getReceived: GetReceivedUC(friendsRepo),
                    getSent: GetSentUC(friendsRepo),
                    getFriends: GetFriendsUC(friendsRepo),
                    acceptUC: AcceptUC(friendsRepo),
                    rejectUC: RejectUC(friendsRepo),
                    unfriendUC: UnfriendUC(friendsRepo),
                    blockUC: BlockUC(friendsRepo),
                    unblockUC: UnblockUC(friendsRepo),
                  ),
                ),
                // Chat home also needs myId for optimistic bubbles ✅
                BlocProvider(
                  create: (_) => ChatBloc(
                    myId: meId, // ✅ important
                    getConversation: ConversationUC(chatRepo),
                    sendMessage: SendMessageUC(chatRepo),
                    markRead: MarkReadUC(chatRepo),
                    deleteMessage: DeleteMessageUC(chatRepo),
                  ),
                ),
              ],
              child: ChatHomeScreen(meId: meId),
            ),
          );
        }

      case Routes.businessActivityDetails:
        final badArgs = args is BusinessActivityDetailsRouteArgs ? args : null;
        if (badArgs == null) {
          return _error(
            "Missing BusinessActivityDetailsRouteArgs (token + activityId).",
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final repo = BusinessActivityRepositoryImpl(
              BusinessActivityService(),
            );
            final getOne = GetBusinessActivityById(repo);

            final currencyRepo = CurrencyRepositoryImpl(CurrencyService());
            final getCurrency = GetCurrentCurrency(currencyRepo);
            final deleteOne = DeleteBusinessActivity(repo);

            return BusinessActivityDetailsScreen(
              activityId: badArgs.activityId,
              token: badArgs.token,
              getById: getOne,
              getCurrency: getCurrency,
              deleteActivity: deleteOne,
            );
          },
        );

      // ===== Business Insights =====
      case Routes.businessInsights:
        final biArgs = args is BusinessInsightsRouteArgs ? args : null;
        if (biArgs == null) {
          return _error(
            'Missing BusinessInsightsRouteArgs (token + businessId).',
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BusinessInsightsScreen(
            token: biArgs.token,
            businessId: biArgs.businessId,
            itemId: biArgs.itemId,
          ),
        );

      // ===== User Tickets Calendar =====
      case Routes.userTicketsCalendar:
        {
          // read args safely
          final cArgs = args is CalendarTicketsRouteArgs ? args : null; // cast

          // guard if missing
          if (cArgs == null) {
            return _error(
              'Missing CalendarTicketsRouteArgs (loadTickets).',
            ); // error page
          }

          // build the page and pass the SAME loader your Tickets screen uses
          return _page(
            CalendarTicketsScreen(
              loadTickets: cArgs.loadTickets, // inject service callback
            ),
            settings, // keep original settings
          );
        }

      case Routes.businessUsers:
        final buArgs = args is BusinessUsersRouteArgs ? args : null;
        if (buArgs == null) {
          return _error('Missing BusinessUsersRouteArgs (token + businessId).');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BusinessUsersScreen(
            token: buArgs.token,
            businessId: buArgs.businessId,
            itemId: buArgs.itemId,
          ),
        );

      // ===== Business Analytics =====
      case Routes.businessAnalytics:
        final bhArgs = args is BusinessHomeRouteArgs ? args : null;
        if (bhArgs == null) {
          return _error('Missing BusinessHomeRouteArgs (token + businessId).');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final repo = BusinessAnalyticsRepositoryImpl(
              BusinessAnalyticsService(),
            );
            return BlocProvider(
              create: (ctx) =>
                  BusinessAnalyticsBloc(
                    getBusinessAnalytics: GetBusinessAnalytics(repo),
                  )..add(
                    LoadBusinessAnalytics(
                      token: bhArgs.token,
                      businessId: bhArgs.businessId,
                    ),
                  ),
              child: BusinessAnalyticsScreen(
                token: bhArgs.token,
                businessId: bhArgs.businessId,
              ),
            );
          },
        );

      // ===== Business Notifications =====
      case Routes.businessNotifications:
        final bnArgs = args is BusinessNotificationsRouteArgs ? args : null;
        if (bnArgs == null) {
          return _error(
            'Missing BusinessNotificationsRouteArgs (token + businessId).',
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BusinessNotificationScreen(
            token: bnArgs.token,
            businessId: bnArgs.businessId,
          ),
        );

      case Routes.userNotifications:
        {
          final args = settings.arguments;
          // Safe cast with helpful error in dev:
          if (args is! UserNotificationsRouteArgs) {
            assert(() {
              throw FlutterError(
                'Routes.userNotifications expects UserNotificationsRouteArgs, '
                'but got: $args',
              );
            }());
            // Fallback: render an error page in release if needed
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Invalid route args')),
              ),
            );
          }
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => UserNotificationScreen(token: args.token),
          );
        }

      // ===== Business Activities =====
      case Routes.businessActivities:
        final baArgs = args is BusinessActivitiesRouteArgs ? args : null;
        if (baArgs == null) {
          return _error(
            "Missing BusinessActivitiesRouteArgs (token + businessId).",
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final repo = BusinessActivityRepositoryImpl(
              BusinessActivityService(),
            );
            return BlocProvider(
              create: (ctx) =>
                  BusinessActivitiesBloc(
                    getActivities: GetBusinessActivities(repo),
                    deleteActivity: DeleteBusinessActivity(repo),
                  )..add(
                    LoadBusinessActivities(
                      token: baArgs.token,
                      businessId: baArgs.businessId,
                    ),
                  ),
              child: BusinessActivitiesScreen(
                token: baArgs.token,
                businessId: baArgs.businessId,
              ),
            );
          },
        );

      // ===== User =====
      case Routes.userHome:
        {
          final uhArgs = args is UserHomeRouteArgs ? args : null;

          // DI — feature services/repos/usecases
          final homeRepo = HomeRepositoryImpl(HomeService());
          final getInterest = GetInterestBasedItems(homeRepo);
          final getUpcoming = GetUpcomingGuestItems(homeRepo);

          final itemTypes = GetItemTypes(
            ItemTypeRepositoryImpl(ItemTypesService()),
          );
          final itemsByType = GetItemsByType(
            ItemsRepositoryImpl(ItemsService()),
          );

          return _page(
            UserHomeScreen(
              firstName: uhArgs?.firstName, // << use names
              lastName: uhArgs?.lastName,
              token: uhArgs?.token ?? '',
              userId: uhArgs?.userId ?? 0, // 0 => hides "Interests" section
              getInterestBased: getInterest,
              getUpcomingGuest: getUpcoming,
              getItemTypes: itemTypes,
              getItemsByType: itemsByType,
            ),
            settings,
          );
        }

      // ===== Business Home =====
      case Routes.businessHome:
        final bhmArgs = args is BusinessHomeRouteArgs ? args : null;
        if (bhmArgs == null) {
          return _error('Missing BusinessHomeRouteArgs (token + businessId).');
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => BusinessHomeBloc(
                  getList: GetBusinessActivities(
                    BusinessActivityRepositoryImpl(BusinessActivityService()),
                  ),
                  getOne: GetBusinessActivityById(
                    BusinessActivityRepositoryImpl(BusinessActivityService()),
                  ),
                  deleteOne: DeleteBusinessActivity(
                    BusinessActivityRepositoryImpl(BusinessActivityService()),
                  ),
                  token: bhmArgs.token,
                  businessId: bhmArgs.businessId,
                  optimisticDelete: false,
                )..add(const BusinessHomeStarted()),
              ),
              BlocProvider(
                create: (_) {
                  final repo = BusinessNotificationRepositoryImpl(
                    BusinessNotificationService(),
                  );
                  return BusinessNotificationBloc(
                      getBusinessNotifications: GetBusinessNotifications(repo),
                      repository: repo,
                      token: bhmArgs.token,
                    )
                    ..add(LoadBusinessNotifications())
                    ..add(LoadUnreadCount(bhmArgs.token));
                },
              ),
            ],
            child: BusinessHomeScreen(
              token: bhmArgs.token,
              businessId: bhmArgs.businessId,
              onCreate: (ctx, bid) {
                navigatorKey.currentState?.pushNamed(
                  Routes.createBusinessActivity,
                  arguments: CreateActivityRouteArgs(businessId: bid),
                );
              },
            ),
          ),
        );

      case Routes.editBusiness:
        final ebArgs = args is EditBusinessRouteArgs ? args : null;
        if (ebArgs == null) {
          return _error("Missing EditBusinessRouteArgs (token + businessId).");
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) {
            final repo = EditBusinessRepositoryImpl(EditBusinessService());
            return BlocProvider(
              create: (ctx) => EditBusinessBloc(
                getBusinessById: GetBusinessById(repo),
                updateBusiness: UpdateBusiness(repo),
                deleteBusiness: DeleteBusiness(repo),
                deleteLogo: DeleteLogo(repo),
                deleteBanner: DeleteBanner(repo),
              ),
              child: EditBusinessScreen(
                token: ebArgs.token,
                businessId: ebArgs.businessId,
              ),
            );
          },
        );

      // ===== Create Activity =====
      case Routes.createBusinessActivity:
        final caArgs = args is CreateActivityRouteArgs ? args : null;
        if (caArgs == null) return _error("Missing CreateActivityRouteArgs");

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateItemPage(
            businessId: caArgs.businessId,
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
        final eaArgs = args is EditActivityRouteArgs ? args : null;
        if (eaArgs == null) {
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
              itemId: eaArgs.itemId,
              businessId: eaArgs.businessId,
              getItemTypes: getItemTypes,
              getCurrentCurrency: getCurrency,
              getItemById: getOne,
            );
          },
        );

      // ===== Invite Manager (NEW) =====
      case Routes.inviteManager:
        final imArgs = args is InviteManagerRouteArgs ? args : null;
        if (imArgs == null) {
          return _error('Missing InviteManagerRouteArgs (token + businessId).');
        }
        return _page(
          InviteManagerScreen(
            token: imArgs.token,
            businessId: imArgs.businessId,
          ),
          settings,
        );

      // ===== Role-aware shell =====
      case Routes.shell:
        final shArgs = args is ShellRouteArgs ? args : null;
        if (shArgs == null) {
          return _error('Missing ShellRouteArgs (role + token + businessId).');
        }
        return _page(
          NavBootstrap(
            role: shArgs.role,
            token: shArgs.token,
            businessId: shArgs.businessId,
            onChangeLocale: onChangeLocale,
            onToggleTheme: onToggleTheme,
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
