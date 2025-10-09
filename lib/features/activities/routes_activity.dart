// lib/features/activities/routes_activity.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/data/repositories/edit_business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/data/services/edit_business_service.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_banner.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_logo.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/update_business.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/presentation/bloc/edit_business_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/presentation/screens/edit_business_screen.dart';

// ====== IMPORT شاشات وخدمات/ريبو/يوزكيس (نفس اللي عندك) ======
// Common
import 'package:hobby_sphere/features/activities/common/presentation/splash_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/onboarding_page.dart';
import 'package:hobby_sphere/features/activities/common/presentation/OnboardingScreen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/PrivacyPolicyScreen.dart';
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';

// Auth
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/screen/login_page.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/screens/forgot_password_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/screens/register_email_page.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart';

// User Home / Items
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

// User Activity Detail
import 'package:hobby_sphere/features/activities/user/userActivityDetail/presentation/screens/user_activity_detail_screen.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/data/services/user_activity_detail_service.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/data/repositories/user_activity_detail_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/get_user_activity_detail.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/check_user_availability.dart';
import 'package:hobby_sphere/features/activities/user/userActivityDetail/domain/usecases/confirm_user_booking.dart';

// User Profile
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/screens/edit_profile_screen.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/bloc/edit_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/presentation/bloc/edit_profile_event.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/services/edit_user_service.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/data/repositories/edit_user_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/get_edit_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/update_edit_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_account_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_edit_user_image.dart';
import 'package:hobby_sphere/features/activities/user/interests/presentation/screens/edit_interests_screen.dart';

// Community / Social
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/community_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/create_post_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/my_posts_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/add_friend_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/chat_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/conversation_screen.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/chat/chat_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/chat/chat_event.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/data/services/friends_service.dart';
import 'package:hobby_sphere/features/activities/user/social/data/repositories/friends_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/social/data/services/message_service.dart';
import 'package:hobby_sphere/features/activities/user/social/data/repositories/chat_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/usecases/friends_usecases.dart';
import 'package:hobby_sphere/features/activities/user/social/domain/usecases/chat_usecases.dart';

// Notifications (user)
import 'package:hobby_sphere/features/activities/user/userNotification/presentation/screens/user_notification_screen.dart';

// Tickets
import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/calendar_tickets_screen.dart';

// Business Home / Activities
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/edit_item_page.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/screen/create_item_page.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/ReopenItemPage.dart';

// Business Details / Profile
import 'package:hobby_sphere/features/activities/Business/BusinessActivityDetails/presentation/screen/business_activity_details_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart'
    as bprof_svc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart'
    as bprof_repo;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart'
    as bprof_uc;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/create_stripe_connect_link.dart'
    as bprof_uc;

// Business Reviews / Insights / Users / Notifications / Analytics / Bookings
import 'package:hobby_sphere/features/activities/Business/BusinessReviews/presentation/screens/business_reviews_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/presentation/screens/business_insights_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/presentation/screens/business_users_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUserInvite/presentation/screens/invite_manager_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/screens/business_notification_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart'
    hide BusinessBookingBloc;
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';

// Shell / Nav
import 'package:hobby_sphere/navigation/nav_bootstrap.dart';
import 'package:hobby_sphere/navigation/activities/shell_bottom.dart';
import 'package:hobby_sphere/navigation/activities/shell_drawer.dart';
import 'package:hobby_sphere/navigation/activities/shell_top.dart';

List<RouteBase> buildActivityRoutes({
  required VoidCallback onToggleTheme,
  required void Function(Locale) onChangeLocale,
  required Locale Function() getCurrentLocale,
}) {
  return [
    // ===== User Home =====
    GoRoute(
      path: Routes.userHome,
      name: Routes.userHome,
      builder: (_, state) {
        final uh = state.extra is UserHomeRouteArgs
            ? state.extra as UserHomeRouteArgs
            : null;

        final homeRepo = HomeRepositoryImpl(HomeService());
        final getInterest = GetInterestBasedItems(homeRepo);
        final getUpcoming = GetUpcomingGuestItems(homeRepo);
        final itemTypes = GetItemTypes(
          ItemTypeRepositoryImpl(ItemTypesService()),
        );
        final itemsByType = GetItemsByType(ItemsRepositoryImpl(ItemsService()));

        return UserHomeScreen(
          firstName: uh?.firstName,
          lastName: uh?.lastName,
          token: uh?.token ?? '',
          userId: uh?.userId ?? 0,
          getInterestBased: getInterest,
          getUpcomingGuest: getUpcoming,
          getItemTypes: itemTypes,
          getItemsByType: itemsByType,
        );
      },
    ),

    // ===== Business Home =====
    GoRoute(
      path: Routes.businessHome,
      name: Routes.businessHome,
      builder: (_, state) {
        final bhm = state.extra is BusinessHomeRouteArgs
            ? state.extra as BusinessHomeRouteArgs
            : null;
        if (bhm == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessHomeRouteArgs',
          );

        return MultiBlocProvider(
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
                token: bhm.token,
                businessId: bhm.businessId,
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
                    token: bhm.token,
                  )
                  ..add(LoadBusinessNotifications())
                  ..add(LoadUnreadCount(bhm.token));
              },
            ),
          ],
          child: BusinessHomeScreen(
            token: bhm.token,
            businessId: bhm.businessId,
            onCreate: (ctx, bid) {
              ctx.push(
                Routes.createBusinessActivity,
                extra: CreateActivityRouteArgs(
                  businessId: bid,
                  token: bhm.token,
                ),
              );
            },
          ),
        );
      },
    ),

    // ===== Business Profile =====
    GoRoute(
      path: Routes.businessProfile,
      name: Routes.businessProfile,
      builder: (_, state) {
        final data = state.extra is BusinessProfileRouteArgs
            ? state.extra as BusinessProfileRouteArgs
            : null;
        if (data == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessProfileRouteArgs',
          );

        final svc = bprof_svc.BusinessService();
        final repo = bprof_repo.BusinessRepositoryImpl(svc);
        final getOne = bprof_uc.GetBusinessById(repo);
        final toggleVis = bprof_uc.UpdateBusinessVisibility(repo);
        final updateStatus = bprof_uc.UpdateBusinessStatus(repo);
        final deleteBiz = bprof_uc.DeleteBusiness(repo);
        final checkStripe = bprof_uc.CheckStripeStatus(repo);
        final createStripeLink = bprof_uc.CreateStripeConnectLink(repo);

        return BlocProvider(
          create: (_) => BusinessProfileBloc(
            getBusinessById: getOne,
            updateBusinessVisibility: toggleVis,
            updateBusinessStatus: updateStatus,
            deleteBusiness: deleteBiz,
            checkStripeStatus: checkStripe,
            createStripeConnectLink: createStripeLink,
          )..add(LoadBusinessProfile(data.token, data.businessId)),
          child: BusinessProfileScreen(
            token: data.token,
            businessId: data.businessId,
            onChangeLocale: onChangeLocale,
          ),
        );
      },
    ),

    // ===== Business Activities (list) =====
    GoRoute(
      path: Routes.businessActivities,
      name: Routes.businessActivities,
      builder: (_, state) {
        final ba = state.extra is BusinessActivitiesRouteArgs
            ? state.extra as BusinessActivitiesRouteArgs
            : null;
        if (ba == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessActivitiesRouteArgs',
          );

        final repo = BusinessActivityRepositoryImpl(BusinessActivityService());
        return BlocProvider(
          create: (_) =>
              BusinessActivitiesBloc(
                getActivities: GetBusinessActivities(repo),
                deleteActivity: DeleteBusinessActivity(repo),
              )..add(
                LoadBusinessActivities(
                  token: ba.token,
                  businessId: ba.businessId,
                ),
              ),
          child: BusinessActivitiesScreen(
            token: ba.token,
            businessId: ba.businessId,
          ),
        );
      },
    ),

    // ===== Business Activity Details =====
    GoRoute(
      path: Routes.businessActivityDetails,
      name: Routes.businessActivityDetails,
      builder: (_, state) {
        final bad = state.extra is BusinessActivityDetailsRouteArgs
            ? state.extra as BusinessActivityDetailsRouteArgs
            : null;
        if (bad == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessActivityDetailsRouteArgs',
          );

        final repo = BusinessActivityRepositoryImpl(BusinessActivityService());
        final getOne = GetBusinessActivityById(repo);
        final currencyRepo = CurrencyRepositoryImpl(CurrencyService());
        final getCurrency = GetCurrentCurrency(currencyRepo);
        final deleteOne = DeleteBusinessActivity(repo);

        return BusinessActivityDetailsScreen(
          activityId: bad.activityId,
          token: bad.token,
          getById: getOne,
          getCurrency: getCurrency,
          deleteActivity: deleteOne,
        );
      },
    ),

    // ===== Create Activity =====
    GoRoute(
      path: Routes.createBusinessActivity,
      name: Routes.createBusinessActivity,
      builder: (_, state) {
        final ca = state.extra is CreateActivityRouteArgs
            ? state.extra as CreateActivityRouteArgs
            : null;
        if (ca == null)
          return const _RouteErrorPage(
            message: 'Missing CreateActivityRouteArgs',
          );

        return CreateItemPage(
          businessId: ca.businessId,
          token: ca.token,
          getItemTypes: GetItemTypes(
            ItemTypeRepositoryImpl(ItemTypesService()),
          ),
          getCurrentCurrency: GetCurrentCurrency(
            CurrencyRepositoryImpl(CurrencyService()),
          ),
        );
      },
    ),

    // ===== Edit Activity =====
    GoRoute(
      path: Routes.editBusinessActivity,
      name: Routes.editBusinessActivity,
      builder: (_, state) {
        final ea = state.extra is EditActivityRouteArgs
            ? state.extra as EditActivityRouteArgs
            : null;
        if (ea == null)
          return const _RouteErrorPage(
            message: 'Missing EditActivityRouteArgs',
          );

        final itemTypeRepo = ItemTypeRepositoryImpl(ItemTypesService());
        final currencyRepo = CurrencyRepositoryImpl(CurrencyService());
        final getItemTypes = GetItemTypes(itemTypeRepo);
        final getCurrency = GetCurrentCurrency(currencyRepo);

        final activityRepo = BusinessActivityRepositoryImpl(
          BusinessActivityService(),
        );
        final getOne = GetBusinessActivityById(activityRepo);

        return EditItemPage(
          itemId: ea.itemId,
          businessId: ea.businessId,
          getItemTypes: getItemTypes,
          getCurrentCurrency: getCurrency,
          getItemById: getOne,
        );
      },
    ),

    // ===== Reopen Item =====
    GoRoute(
      path: Routes.reopenItem,
      name: Routes.reopenItem,
      builder: (_, state) {
        final r = state.extra is ReopenItemRouteArgs
            ? state.extra as ReopenItemRouteArgs
            : null;
        if (r == null)
          return const _RouteErrorPage(message: 'Missing ReopenItemRouteArgs');

        return ReopenItemPage(
          businessId: r.businessId,
          oldItem: r.oldItem,
          getItemTypes: GetItemTypes(
            ItemTypeRepositoryImpl(ItemTypesService()),
          ),
          getCurrentCurrency: GetCurrentCurrency(
            CurrencyRepositoryImpl(CurrencyService()),
          ),
        );
      },
    ),

    // ===== Business Reviews / Insights / Users / Notifications / Analytics / Bookings =====
    GoRoute(
      path: Routes.businessReviews,
      name: Routes.businessReviews,
      builder: (_, state) {
        final d = state.extra is BusinessReviewsRouteArgs
            ? state.extra as BusinessReviewsRouteArgs
            : null;
        if (d == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessReviewsRouteArgs',
          );
        return BusinessReviewsScreen(businessId: d.businessId, token: d.token);
      },
    ),
    GoRoute(
      path: Routes.businessInsights,
      name: Routes.businessInsights,
      builder: (_, state) {
        final d = state.extra is BusinessInsightsRouteArgs
            ? state.extra as BusinessInsightsRouteArgs
            : null;
        if (d == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessInsightsRouteArgs',
          );
        return BusinessInsightsScreen(
          token: d.token,
          businessId: d.businessId,
          itemId: d.itemId,
        );
      },
    ),
    GoRoute(
      path: Routes.businessUsers,
      name: Routes.businessUsers,
      builder: (_, state) {
        final d = state.extra is BusinessUsersRouteArgs
            ? state.extra as BusinessUsersRouteArgs
            : null;
        if (d == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessUsersRouteArgs',
          );
        return BusinessUsersScreen(
          token: d.token,
          businessId: d.businessId,
          itemId: d.itemId,
        );
      },
    ),
    GoRoute(
      path: Routes.businessNotifications,
      name: Routes.businessNotifications,
      builder: (_, state) {
        final d = state.extra is BusinessNotificationsRouteArgs
            ? state.extra as BusinessNotificationsRouteArgs
            : null;
        if (d == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessNotificationsRouteArgs',
          );
        return BusinessNotificationScreen(
          token: d.token,
          businessId: d.businessId,
        );
      },
    ),
    GoRoute(
      path: Routes.businessAnalytics,
      name: Routes.businessAnalytics,
      builder: (_, state) {
        final bh = state.extra is BusinessHomeRouteArgs
            ? state.extra as BusinessHomeRouteArgs
            : null;
        if (bh == null)
          return const _RouteErrorPage(
            message: 'Missing BusinessHomeRouteArgs',
          );

        final repo = BusinessAnalyticsRepositoryImpl(
          BusinessAnalyticsService(),
        );
        return BlocProvider(
          create: (_) =>
              BusinessAnalyticsBloc(
                getBusinessAnalytics: GetBusinessAnalytics(repo),
              )..add(
                LoadBusinessAnalytics(
                  token: bh.token,
                  businessId: bh.businessId,
                ),
              ),
          child: BusinessAnalyticsScreen(
            token: bh.token,
            businessId: bh.businessId,
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.businessBookings,
      name: Routes.businessBookings,
      builder: (_, __) {
        final repo = BusinessBookingRepositoryImpl(BusinessBookingService());
        return BlocProvider(
          create: (_) => BusinessBookingBloc(
            getBookings: GetBusinessBookings(repo),
            updateStatus: UpdateBookingStatus(repo),
          )..add(BusinessBookingBootstrap()),
          child: const BusinessBookingScreen(),
        );
      },
    ),

    // ===== User Activity Detail =====
    GoRoute(
      path: Routes.userActivityDetail,
      name: Routes.userActivityDetail,
      builder: (_, state) {
        final ua = state.extra is UserActivityDetailRouteArgs
            ? state.extra as UserActivityDetailRouteArgs
            : null;
        if (ua == null)
          return const _RouteErrorPage(
            message: 'Missing UserActivityDetailRouteArgs',
          );

        final repo = UserActivityDetailRepositoryImpl(
          UserActivityDetailService(),
        );
        // usecases are wired inside the screen but kept here for clarity
        final _ = GetUserActivityDetail(repo);
        final __ = CheckUserAvailability(repo);
        final ___ = ConfirmUserBooking(repo);

        return UserActivityDetailScreen(
          itemId: ua.itemId,
          imageBaseUrl: ua.imageBaseUrl,
          currencyCode: ua.currencyCode,
          bearerToken: ua.token,
        );
      },
    ),

    // ===== Edit User Profile =====
    GoRoute(
      path: Routes.editUserProfile,
      name: Routes.editUserProfile,
      builder: (_, state) {
        final ep = state.extra is EditUserProfileRouteArgs
            ? state.extra as EditUserProfileRouteArgs
            : null;
        if (ep == null)
          return const _RouteErrorPage(
            message: 'Missing EditUserProfileRouteArgs',
          );

        final repo = EditUserRepositoryImpl(EditUserService());
        final getUser = GetEditUser(repo);
        final update = UpdateEditUser(repo);
        final delAcc = DeleteAccountUser(repo);
        final removeImg = DeleteEditUserImage(repo);

        return BlocProvider(
          create: (_) => EditProfileBloc(
            getUser: getUser,
            updateUser: update,
            deleteAccount: delAcc,
            deleteImage: removeImg,
          )..add(LoadEditProfile(ep.token, ep.userId)),
          child: EditProfileScreen(token: ep.token, userId: ep.userId),
        );
      },
    ),

    // ===== Edit Interests =====
    GoRoute(
      path: Routes.editInterests,
      name: Routes.editInterests,
      builder: (_, state) {
        final ei = state.extra is EditInterestsRouteArgs
            ? state.extra as EditInterestsRouteArgs
            : null;
        if (ei == null)
          return const _RouteErrorPage(
            message: 'Missing EditInterestsRouteArgs',
          );

        final dio = g.appDio ?? Dio();
        final regService = RegistrationService(dio);
        final interestsRepo = InterestsRepositoryImpl(regService);
        final getTypes = GetActivityTypes(interestsRepo);

        return EditInterestsScreen(
          token: ei.token,
          userId: ei.userId,
          getTypes: getTypes,
        );
      },
    ),

    // ===== Community / Social =====
    GoRoute(
      path: Routes.community,
      name: Routes.community,
      builder: (_, state) {
        final token = state.extra is String
            ? state.extra as String
            : (state.extra is UserHomeRouteArgs
                  ? (state.extra as UserHomeRouteArgs).token
                  : '');

        final imageBaseUrl = (g.appServerRoot ?? '').replaceFirst(
          RegExp(r'/api/?$'),
          '',
        );
        final uid = state.extra is UserHomeRouteArgs
            ? (state.extra as UserHomeRouteArgs).userId
            : 0;

        return CommunityScreen(
          token: token,
          userId: uid,
          imageBaseUrl: imageBaseUrl,
        );
      },
    ),
    GoRoute(
      path: Routes.createPost,
      name: Routes.createPost,
      builder: (_, state) {
        final cp = state.extra is CreatePostArgs
            ? state.extra as CreatePostArgs
            : null;
        if (cp == null)
          return const _RouteErrorPage(message: 'Missing CreatePostArgs');
        return CreatePostScreen(args: cp);
      },
    ),
    GoRoute(
      path: Routes.myPosts,
      name: Routes.myPosts,
      builder: (_, state) {
        final mp = state.extra is MyPostsRouteArgs
            ? state.extra as MyPostsRouteArgs
            : null;
        if (mp == null)
          return const _RouteErrorPage(message: 'Missing MyPostsRouteArgs');

        final base =
            mp.imageBaseUrl ??
            (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');
        return MyPostsScreen(
          args: MyPostsArgs(
            token: mp.token,
            userId: mp.userId,
            imageBaseUrl: base,
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.addFriend,
      name: Routes.addFriend,
      builder: (_, state) {
        final meId = state.extra is int
            ? state.extra as int
            : (state.extra is UserHomeRouteArgs
                  ? (state.extra as UserHomeRouteArgs).userId
                  : 0);

        final baseUrl = g.appServerRoot ?? '';
        final friendsService = FriendsService(baseUrl);
        final friendsRepo = FriendsRepositoryImpl(friendsService);

        // build UCs
        final getAll = GetAllUsersUC(friendsRepo);
        final getSuggested = GetSuggestedUC(friendsRepo);
        final sendFriend = SendFriendUC(friendsRepo);
        final cancelFriend = CancelFriendUC(friendsRepo);
        final getReceived = GetReceivedUC(friendsRepo);
        final getSent = GetSentUC(friendsRepo);
        final getFriends = GetFriendsUC(friendsRepo);
        final acceptUC = AcceptUC(friendsRepo);
        final rejectUC = RejectUC(friendsRepo);
        final unfriendUC = UnfriendUC(friendsRepo);
        final blockUC = BlockUC(friendsRepo);
        final unblockUC = UnblockUC(friendsRepo);

        return BlocProvider(
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
          child: AddFriendScreen(meId: meId),
        );
      },
    ),
    GoRoute(
      path: Routes.friendship,
      name: Routes.friendship,
      builder: (_, state) {
        final baseUrl = g.appServerRoot ?? '';

        if (state.extra is ConversationRouteArgs) {
          final a = state.extra as ConversationRouteArgs;
          final friendsRepo = FriendsRepositoryImpl(FriendsService(baseUrl));
          final chatRepo = ChatRepositoryImpl(
            MessageService(baseUrl),
            meId: a.myId,
          );

          final getFriends = GetFriendsUC(friendsRepo);
          final acceptUC = AcceptUC(friendsRepo);
          final rejectUC = RejectUC(friendsRepo);
          final unfriendUC = UnfriendUC(friendsRepo);

          final conversation = ConversationUC(chatRepo);
          final send = SendMessageUC(chatRepo);
          final markRead = MarkReadUC(chatRepo);
          final deleteMsg = DeleteMessageUC(chatRepo);

          return MultiBlocProvider(
            providers: [
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
              BlocProvider(
                create: (_) => ChatBloc(
                  myId: a.myId,
                  getConversation: conversation,
                  sendMessage: send,
                  markRead: markRead,
                  deleteMessage: deleteMsg,
                )..add(LoadConversation(a.peer.id)),
              ),
            ],
            child: ConversationScreen(peer: a.peer),
          );
        }

        // Chat home mode
        final meId = state.extra is int
            ? state.extra as int
            : (state.extra is UserHomeRouteArgs
                  ? (state.extra as UserHomeRouteArgs).userId
                  : 0);

        final friendsRepo = FriendsRepositoryImpl(FriendsService(baseUrl));
        final chatRepo = ChatRepositoryImpl(
          MessageService(baseUrl),
          meId: meId,
        );

        return MultiBlocProvider(
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
            BlocProvider(
              create: (_) => ChatBloc(
                myId: meId,
                getConversation: ConversationUC(chatRepo),
                sendMessage: SendMessageUC(chatRepo),
                markRead: MarkReadUC(chatRepo),
                deleteMessage: DeleteMessageUC(chatRepo),
              ),
            ),
          ],
          child: ChatHomeScreen(meId: meId),
        );
      },
    ),

    // ===== User Notifications =====
    GoRoute(
      path: Routes.userNotifications,
      name: Routes.userNotifications,
      builder: (_, state) {
        final un = state.extra is UserNotificationsRouteArgs
            ? state.extra as UserNotificationsRouteArgs
            : null;
        if (un == null)
          return const _RouteErrorPage(
            message: 'Missing UserNotificationsRouteArgs',
          );
        return UserNotificationScreen(token: un.token);
      },
    ),

    // ===== Calendar Tickets =====
    GoRoute(
      path: Routes.userTicketsCalendar,
      name: Routes.userTicketsCalendar,
      builder: (_, state) {
        final c = state.extra is CalendarTicketsRouteArgs
            ? state.extra as CalendarTicketsRouteArgs
            : null;
        if (c == null)
          return const _RouteErrorPage(
            message: 'Missing CalendarTicketsRouteArgs',
          );
        return CalendarTicketsScreen(loadTickets: c.loadTickets);
      },
    ),

    // ===== Invite Manager =====
    GoRoute(
      path: Routes.inviteManager,
      name: Routes.inviteManager,
      builder: (_, state) {
        final im = state.extra is InviteManagerRouteArgs
            ? state.extra as InviteManagerRouteArgs
            : null;
        if (im == null)
          return const _RouteErrorPage(
            message: 'Missing InviteManagerRouteArgs',
          );
        return InviteManagerScreen(token: im.token, businessId: im.businessId);
      },
    ),

    // ===== Business Edit =====
    GoRoute(
      path: Routes.editBusiness,
      name: Routes.editBusiness,
      builder: (_, state) {
        final eb = state.extra is EditBusinessRouteArgs
            ? state.extra as EditBusinessRouteArgs
            : null;
        if (eb == null)
          return const _RouteErrorPage(
            message: 'Missing EditBusinessRouteArgs',
          );

        final repo = EditBusinessRepositoryImpl(EditBusinessService());
        return BlocProvider(
          create: (_) => EditBusinessBloc(
            getBusinessById: GetBusinessById(repo),
            updateBusiness: UpdateBusiness(repo),
            deleteBusiness: DeleteBusiness(repo),
            deleteLogo: DeleteLogo(repo),
            deleteBanner: DeleteBanner(repo),
          ),
          child: EditBusinessScreen(token: eb.token, businessId: eb.businessId),
        );
      },
    ),

    // ===== Shell (role aware) =====
    GoRoute(
      path: Routes.shell, // shell route
      name: Routes.shell, // name
      builder: (_, state) {
        final sh =
            state.extra
                is ShellRouteArgs // read args
            ? state.extra as ShellRouteArgs
            : null;
        if (sh == null) {
          return const _RouteErrorPage(
            message: 'Missing ShellRouteArgs',
          ); // guard
        }

        // define the 3 builders *for Activities feature*
        final BuildShell buildBottom =
            (ctx, role, token, businessId, onLoc, onTheme) {
              // return your existing Activities bottom shell
              return ShellBottom(
                role: role, // pass role
                token: token, // pass token
                businessId: businessId, // pass business id
                onChangeLocale: onLoc, // pass i18n
                onToggleTheme: onTheme, // pass theme
              );
            };

        final BuildShell buildTop =
            (ctx, role, token, businessId, onLoc, onTheme) {
              // return your existing Activities top shell
              return ShellTop(
                role: role, // pass role
                token: token, // pass token
                businessId: businessId, // pass business id
                onChangeLocale: onLoc, // pass i18n
                onToggleTheme: onTheme, // pass theme
              );
            };

        final BuildShell buildDrawer =
            (ctx, role, token, businessId, onLoc, onTheme) {
              // return your existing Activities drawer shell
              return ShellDrawer(
                role: role, // pass role
                token: token, // pass token
                businessId: businessId, // pass business id
                onChangeLocale: onLoc, // pass i18n
                onToggleTheme: onTheme, // pass theme
              );
            };

        // hand everything to the dynamic chooser
        return NavBootstrap(
          role: sh.role, // who’s using the app
          token: sh.token, // jwt or ''
          businessId: sh.businessId, // biz id if needed
          onChangeLocale:
              (loc) {}, // wire real callbacks from AppRouter if you have them
          onToggleTheme: () {}, // same
          buildBottom: buildBottom, // activities bottom builder
          buildTop: buildTop, // activities top builder
          buildDrawer: buildDrawer, // activities drawer builder
        );
      },
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
