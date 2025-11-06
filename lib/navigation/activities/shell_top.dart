// ===== Flutter 3.35.x =====
// ShellTop — top tabs with guest gating (user + business).
// Rule: token == '' → Community / Tickets / Profile show NotLoggedInGate.
// Uses go_router for navigation from tab content and quick actions.

import 'dart:convert' show base64Url, jsonDecode, utf8; // parse JWT
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // status/nav bars
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:go_router/go_router.dart'; // go_router

import 'package:hobby_sphere/app/router/router.dart'; // route names + navigatorKey
import 'package:hobby_sphere/core/constants/app_role.dart'; // roles
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root

// Typed route args used by Business create activity flow
import 'package:hobby_sphere/features/activities/routes_activity.dart';

// ===== Business stacks =====
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/screen/business_activities_screen.dart';

import 'package:hobby_sphere/features/activities/business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/business/businessHome/presentation/screen/business_home_screen.dart';

import 'package:hobby_sphere/features/activities/business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_event.dart';

import 'package:hobby_sphere/features/activities/business/businessProfile/data/repositories/business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/check_stripe_status.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/create_stripe_connect_link.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/update_business_status.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/update_business_visibility.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/screen/business_profile_screen.dart';

import 'package:hobby_sphere/features/activities/business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/screen/business_booking_screen.dart';

import 'package:hobby_sphere/features/activities/business/businessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/screen/business_analytics_screen.dart';

import 'package:hobby_sphere/features/activities/business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activity_by_id.dart';

// ===== User stacks =====
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/screens/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/user_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/community_screen.dart';

// User DI
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// ===== User Profile feature =====
import 'package:hobby_sphere/features/activities/user/userProfile/data/services/user_profile_service.dart'
    as upsvc;
import 'package:hobby_sphere/features/activities/user/userProfile/data/repositories/user_profile_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/get_user_profile.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/toggle_user_visibility.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/update_user_status.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_event.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/screens/user_profile_screen.dart';

// ===== Guest gate =====
import 'package:hobby_sphere/shared/widgets/not_logged_in_gate.dart';

// l10n
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellTop extends StatelessWidget {
  // role + auth
  final AppRole role; // current role
  final String token; // JWT ('' => guest)
  final int businessId; // business id if needed

  // app actions
  final void Function(Locale) onChangeLocale; // change language
  final VoidCallback onToggleTheme; // toggle theme

  // badges
  final int bookingsBadge; // business badge
  final int ticketsBadge; // user badge

  const ShellTop({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale,
    required this.onToggleTheme,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  // ----- helpers -----
  bool get _isGuest => token.trim().isEmpty;

  Map<String, dynamic>? _jwtPayload(String tkn) {
    // parse payload (safe)
    try {
      final parts = tkn.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final obj = jsonDecode(payload);
      return (obj is Map<String, dynamic>) ? obj : null;
    } catch (_) {
      return null;
    }
  }

  int _userIdFromToken() {
    if (_isGuest) return 0;
    final p = _jwtPayload(token);
    final raw = p?['id'] ?? p?['userId'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw') ?? 0;
  }

  String? _firstNameFromToken() {
    if (_isGuest) return null;
    final p = _jwtPayload(token);
    final fn = (p?['firstName'] ?? p?['given_name'])?.toString();
    if (fn != null && fn.trim().isNotEmpty) return fn.trim();
    final name = p?['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      return name.trim().split(RegExp(r'\s+')).first;
    }
    return null;
  }

  String? _lastNameFromToken() {
    if (_isGuest) return null;
    final p = _jwtPayload(token);
    final ln = (p?['lastName'] ?? p?['family_name'])?.toString();
    if (ln != null && ln.trim().isNotEmpty) return ln.trim();
    final name = p?['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) return parts.sublist(1).join(' ');
    }
    return null;
  }

  String _serverRoot() =>
      (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');

  // labels for tabs
  List<String> _labels(BuildContext ctx) {
    final t = AppLocalizations.of(ctx)!;
    return role == AppRole.business
        ? [
            t.tabHome,
            t.tabBookings,
            t.tabAnalytics,
            t.tabActivities,
            t.tabProfile,
          ]
        : [t.tabHome, t.tabExplore, t.tabSocial, t.tabTickets, t.tabProfile];
  }

  // ----- build USER pages (guest-aware) -----
  List<Widget> _userViews(BuildContext context) {
    final userId = _userIdFromToken(); // 0 if guest
    final firstName = _firstNameFromToken();
    final lastName = _lastNameFromToken();

    // DI (services/repos/usecases)
    final homeRepo = HomeRepositoryImpl(HomeService());
    final getInterest = GetInterestBasedItems(homeRepo);
    final getUpcoming = GetUpcomingGuestItems(homeRepo);
    final getItemTypes = GetItemTypes(
      ItemTypeRepositoryImpl(ItemTypesService()),
    );
    final getItemsByType = GetItemsByType(ItemsRepositoryImpl(ItemsService()));

    // Helper: Profile screen for logged-in users
    Widget _buildUserProfilePage() {
      final svc = upsvc.UserProfileService();
      final repo = UserProfileRepositoryImpl(svc);
      final getUser = GetUserProfile(repo);
      final toggleVis = ToggleUserVisibility(repo);
      final setStatus = UpdateUserStatus(repo);

      return MultiRepositoryProvider(
        providers: [RepositoryProvider.value(value: setStatus)],
        child: BlocProvider(
          create: (_) => UserProfileBloc(
            getUser: getUser,
            toggleVisibility: toggleVis,
            updateStatus: setStatus,
          )..add(LoadUserProfile(token, userId)),
          child: UserProfileScreen(
            token: token,
            userId: userId,
            onChangeLocale: onChangeLocale,
          ),
        ),
      );
    }

    return [
      // 0) Home (guest-safe)
      UserHomeScreen(
        firstName: _isGuest ? null : firstName,
        lastName: _isGuest ? null : lastName,
        token: token,
        userId: _isGuest ? 0 : userId,
        getInterestBased: getInterest,
        getUpcomingGuest: getUpcoming,
        getItemTypes: getItemTypes,
        getItemsByType: getItemsByType,
      ),

      // 1) Explore (open for guest)
      ExploreScreen(
        token: token,
        getUpcomingGuest: getUpcoming,
        getItemTypes: getItemTypes,
        getItemsByType: getItemsByType,
        getCurrencyCode: () async {
          // Don’t break in guest mode
          try {
            final uc = GetCurrentCurrency(
              CurrencyRepositoryImpl(CurrencyService()),
            );
            return (await uc(token)).code;
          } catch (_) {
            return null;
          }
        },
        imageBaseUrl: _serverRoot(),
      ),

      // 2) Social (Community) — gate for guest
      _isGuest
          ? NotLoggedInGate(
              onLogin: () => context.pushNamed(Routes.login),
              onRegister: () => context.pushNamed(Routes.register),
            )
          : CommunityScreen(
              token: token,
              imageBaseUrl: _serverRoot(),
              userId: userId,
            ),

      // 3) Tickets — gate for guest
      _isGuest
          ? NotLoggedInGate(
              onLogin: () => context.pushNamed(Routes.login),
              onRegister: () => context.pushNamed(Routes.register),
            )
          : UserTicketsScreen(token: token),

      // 4) Profile — gate for guest, real profile for logged-in
      _isGuest
          ? NotLoggedInGate(
              onLogin: () => context.pushNamed(Routes.login),
              onRegister: () => context.pushNamed(Routes.register),
            )
          : _buildUserProfilePage(),
    ];
  }

  // ----- build BUSINESS pages -----
  List<Widget> _businessViews(BuildContext context) {
    return [
      // 0) Home (+ notifications bloc); create button uses go_router
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => BusinessHomeBloc(
              getList: GetBusinessActivities(
                BusinessActivityRepositoryImpl(BusinessActivityService()),
              ),
              getOne: GetBusinessActivityById(
                BusinessActivityRepositoryImpl(BusinessActivityService()),
              ),
              deleteOne: DeleteBusinessActivity(
                BusinessActivityRepositoryImpl(BusinessActivityService()),
              ),
              token: token,
              businessId: businessId,
              optimisticDelete: false,
            )..add(const BusinessHomeStarted()),
          ),
          BlocProvider(
            create: (ctx) {
              final repo = BusinessNotificationRepositoryImpl(
                BusinessNotificationService(),
              );
              return BusinessNotificationBloc(
                getBusinessNotifications: GetBusinessNotifications(repo),
                repository: repo,
                token: token,
              )..add(LoadUnreadCount(token));
            },
          ),
        ],
        child: BusinessHomeScreen(
          token: token,
          businessId: businessId,
          onCreate: (ctx, bid) {
            ctx.pushNamed(
              Routes.createBusinessActivity,
              extra: CreateActivityRouteArgs(businessId: bid, token: token),
            );
          },
        ),
      ),

      // 1) Bookings
      BlocProvider(
        create: (ctx) => BusinessBookingBloc(
          getBookings: GetBusinessBookings(
            BusinessBookingRepositoryImpl(BusinessBookingService()),
          ),
          updateStatus: UpdateBookingStatus(
            BusinessBookingRepositoryImpl(BusinessBookingService()),
          ),
        )..add(BusinessBookingBootstrap()),
        child: const BusinessBookingScreen(),
      ),

      // 2) Analytics
      BlocProvider(
        create: (ctx) => BusinessAnalyticsBloc(
          getBusinessAnalytics: GetBusinessAnalytics(
            BusinessAnalyticsRepositoryImpl(BusinessAnalyticsService()),
          ),
        )..add(LoadBusinessAnalytics(token: token, businessId: businessId)),
        child: BusinessAnalyticsScreen(token: token, businessId: businessId),
      ),

      // 3) Activities
      BlocProvider(
        create: (ctx) {
          final repo = BusinessActivityRepositoryImpl(
            BusinessActivityService(),
          );
          return BusinessActivitiesBloc(
            getActivities: GetBusinessActivities(repo),
            deleteActivity: DeleteBusinessActivity(repo),
          )..add(LoadBusinessActivities(token: token, businessId: businessId));
        },
        child: BusinessActivitiesScreen(token: token, businessId: businessId),
      ),

      // 4) Profile — Stripe connect usecase injected
      BlocProvider(
        create: (ctx) {
          final businessRepo = BusinessRepositoryImpl(BusinessService());
          return BusinessProfileBloc(
            getBusinessById: GetBusinessById(businessRepo),
            updateBusinessVisibility: UpdateBusinessVisibility(businessRepo),
            updateBusinessStatus: UpdateBusinessStatus(businessRepo),
            deleteBusiness: DeleteBusiness(businessRepo),
            checkStripeStatus: CheckStripeStatus(businessRepo),
            createStripeConnectLink: CreateStripeConnectLink(businessRepo),
          )..add(LoadBusinessProfile(token, businessId));
        },
        child: BusinessProfileScreen(
          token: token,
          businessId: businessId,
          onTabChange: (_) {}, // keep existing callback
          onChangeLocale: onChangeLocale, // pass locale callback
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // transparent system bars to match top tabs
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final scheme = Theme.of(context).colorScheme;
    final labels = _labels(context);
    final pages = role == AppRole.business
        ? _businessViews(context)
        : _userViews(context);

    // Which tab shows a badge and what value
    final badgeIndex = role == AppRole.business ? 1 : 3;
    final badgeCount = role == AppRole.business
        ? bookingsBadge
        : (_isGuest ? 0 : ticketsBadge);

    return DefaultTabController(
      length: labels.length, // 5 tabs
      child: Builder(
        builder: (tabCtx) {
          final controller = DefaultTabController.of(tabCtx);
          return Scaffold(
            appBar: AppBar(
              title: const Text(''), // keep clean
              centerTitle: true,
              actions: [
                // Quick action only for logged-in users
                if (role != AppRole.business && !_isGuest)
                  IconButton(
                    tooltip: AppLocalizations.of(context)!.socialMyPosts,
                    icon: const Icon(Icons.library_books_outlined),
                    onPressed: () {
                      // go_router to "My Posts" screen, pass extras
                      context.pushNamed(
                        Routes.myPosts,
                        extra: {'token': token, 'imageBaseUrl': _serverRoot()},
                      );
                    },
                  ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // pill-style TabBar
                  Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.6),
                      ),
                    ),
                    child: TabBar(
                      isScrollable: false,
                      indicator: BoxDecoration(
                        color: scheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scheme.primary, width: 1.5),
                      ),
                      labelColor: scheme.primary,
                      unselectedLabelColor: scheme.onSurface.withOpacity(0.7),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: List.generate(labels.length, (i) {
                        final showBadge = i == badgeIndex && badgeCount > 0;
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(labels[i]),
                              if (showBadge) ...[
                                const SizedBox(width: 6),
                                Badge(
                                  label: Text(
                                    badgeCount > 99 ? '99+' : '$badgeCount',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  // pages
                  Expanded(
                    child: TabBarView(controller: controller, children: pages),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
