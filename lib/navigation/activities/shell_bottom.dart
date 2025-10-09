// ===== Flutter 3.35.x =====
// ShellBottom — one shell for guest + logged-in users.
// Simple rule: token == ''  => guest mode. Home/Explore work. Others show a gate.
// Uses go_router (context.pushNamed) — no Navigator.pushNamed.
// English comments throughout.

import 'dart:ui' show ImageFilter; // blur for glass bar
import 'dart:convert' show base64Url, jsonDecode, utf8; // decode JWT payload
import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter/services.dart'; // haptics + sys UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC providers
import 'package:go_router/go_router.dart'; // go_router navigation

// Routes + names
import 'package:hobby_sphere/app/router/router.dart'; // Routes.*
// We also need the arg models (e.g., CreateActivityRouteArgs)
import 'package:hobby_sphere/features/activities/routes_activity.dart';

// Role + server root
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

// ===== Business blocs/usecases/data =====
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/create_stripe_connect_link.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

// ===== Business screens =====
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';

// ===== Common / currency =====
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// ===== User screens =====
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/screens/user_explore_screen.dart'
    show ExploreScreen;
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/community_screen.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/user_tickets_screen.dart';

// ===== User Home feature (data/repo/uc) =====
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

// ===== Common types + items-by-type =====
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

// ===== User Profile feature (alias service) =====
import 'package:hobby_sphere/features/activities/user/userProfile/data/services/user_profile_service.dart'
    as svc;
import 'package:hobby_sphere/features/activities/user/userProfile/data/repositories/user_profile_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/get_user_profile.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/toggle_user_visibility.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/update_user_status.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_event.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/screens/user_profile_screen.dart';

// ===== Gate widget for guests =====
import 'package:hobby_sphere/shared/widgets/not_logged_in_gate.dart';

// ===== L10n =====
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellBottom extends StatefulWidget {
  final AppRole role; // current role
  final String token; // JWT ('' => guest)
  final int businessId; // business id
  final void Function(Locale) onChangeLocale; // change language
  final VoidCallback onToggleTheme; // toggle theme
  final int bookingsBadge; // business badge
  final int ticketsBadge; // user badge

  const ShellBottom({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale,
    required this.onToggleTheme,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  @override
  State<ShellBottom> createState() => _ShellBottomState();
}

class _ShellBottomState extends State<ShellBottom> {
  int _index = 0; // selected tab index

  // ---- quick helper ----
  bool get _isGuest => widget.token.trim().isEmpty; // guest if no token

  // ---- remove '/api' from server root ----
  String _serverRoot() =>
      (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');

  // ---- parse JWT payload safely ----
  Map<String, dynamic>? _jwtPayload(String token) {
    try {
      final parts = token.split('.'); // header.payload.signature
      if (parts.length != 3) return null; // not a JWT
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      ); // base64url decode payload
      final obj = jsonDecode(decoded); // to Map
      return (obj is Map<String, dynamic>) ? obj : null;
    } catch (_) {
      return null; // any error => null
    }
  }

  // ---- extract id from jwt ----
  int? _extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final p = (jsonDecode(decoded) as Map?)?.map((k, v) => MapEntry('$k', v));
      if (p == null) return null;

      // Try common claim names, in order.
      final candidates = [
        p['id'],
        p['userId'],
        p['user_id'],
        p['sub'], // very common in JWTs
        p['uid'],
      ];

      for (final raw in candidates) {
        if (raw == null) continue;
        if (raw is num) return raw.toInt();
        final parsed = int.tryParse(raw.toString());
        if (parsed != null) return parsed;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---- extract first/last name from jwt ----
  String? _extractFirstName(String token) {
    final p = _jwtPayload(token);
    final fn = (p?['firstName'] ?? p?['given_name'])?.toString();
    if (fn != null && fn.trim().isNotEmpty) return fn.trim();
    final name = p?['name']?.toString(); // fallback to full name
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) return parts.first;
    }
    return null;
  }

  String? _extractLastName(String token) {
    final p = _jwtPayload(token);
    final ln = (p?['lastName'] ?? p?['family_name'])?.toString();
    if (ln != null && ln.trim().isNotEmpty) return ln.trim();
    final name = p?['name']?.toString(); // fallback to full name
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) return parts.sublist(1).join(' ');
    }
    return null;
  }

  // ---- DI for User Home/Explore ----
  late final _homeRepo = HomeRepositoryImpl(HomeService());
  late final _getInterest = GetInterestBasedItems(_homeRepo);
  late final _getUpcoming = GetUpcomingGuestItems(_homeRepo);
  late final _getItemTypes = GetItemTypes(
    ItemTypeRepositoryImpl(ItemTypesService()),
  );
  late final _getItemsByType = GetItemsByType(
    ItemsRepositoryImpl(ItemsService()),
  );

  // ---- parsed info from token (safe for guest) ----
  late final int _userId = _extractUserId(widget.token) ?? 0; // 0 for guest
  late final String? _firstName = _extractFirstName(widget.token);
  late final String? _lastName = _extractLastName(widget.token);

  // ===== User Profile tab builder (service -> repo -> UCs -> bloc -> screen) =====
  Widget _buildUserProfilePage() {
    final service = svc.UserProfileService(); // API service
    final repo = UserProfileRepositoryImpl(service); // repo impl
    final getUser = GetUserProfile(repo); // UC: get user
    final toggleVis = ToggleUserVisibility(repo); // UC: toggle vis
    final setStatus = UpdateUserStatus(repo); // UC: set status

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: setStatus), // expose UC
      ],
      child: BlocProvider(
        create: (_) => UserProfileBloc(
          getUser: getUser,
          toggleVisibility: toggleVis,
          updateStatus: setStatus,
        )..add(LoadUserProfile(widget.token, _userId)), // initial load
        child: UserProfileScreen(
          token: widget.token,
          userId: _userId,
          onChangeLocale: widget.onChangeLocale,
        ),
      ),
    );
  }

  // ===== USER PAGES (guest-aware) =====
  late final List<Widget> _userPages = <Widget>[
    // 0) Home — interest section auto-hides for guest (token='')
    UserHomeScreen(
      firstName: _isGuest ? null : _firstName,
      lastName: _isGuest ? null : _lastName,
      token: widget.token, // '' in guest mode
      userId: _isGuest ? 0 : _userId, // 0 in guest mode
      getInterestBased: _getInterest,
      getUpcomingGuest: _getUpcoming,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
    ),

    // 1) Explore — always open (guest or logged-in)
    ExploreScreen(
      token: widget.token,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
      getUpcomingGuest: _getUpcoming,
      getCurrencyCode: () async => (await GetCurrentCurrency(
        CurrencyRepositoryImpl(CurrencyService()),
      )(widget.token)).code,
      imageBaseUrl: _serverRoot(), // absolute URLs for images
    ),

    // 2) Community — gate if guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login), // ✅ go_router
            onRegister: () => context.pushNamed(Routes.register), // ✅ go_router
          )
        : CommunityScreen(
            token: widget.token,
            userId: _userId,
            imageBaseUrl: _serverRoot(),
          ),

    // 3) Tickets — gate if guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login),
            onRegister: () => context.pushNamed(Routes.register),
          )
        : UserTicketsScreen(token: widget.token),

    // 4) Profile — gate if guest, real profile if logged-in
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login),
            onRegister: () => context.pushNamed(Routes.register),
          )
        : _buildUserProfilePage(),
  ];

  // ===== BUSINESS PAGES =====
  late final List<Widget> _businessPages = <Widget>[
    // 0. Home (+ notifications bloc)
    MultiBlocProvider(
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
            token: widget.token,
            businessId: widget.businessId,
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
              token: widget.token,
            )..add(LoadUnreadCount(widget.token));
          },
        ),
      ],
      child: BusinessHomeScreen(
        token: widget.token,
        businessId: widget.businessId,
        onCreate: (ctx, bid) {
          // ✅ go_router with extra args
          ctx.pushNamed(
            Routes.createBusinessActivity,
            extra: CreateActivityRouteArgs(
              businessId: bid,
              token: widget.token,
            ),
          );
        },
      ),
    ),

    // 1. Bookings
    BlocProvider(
      create: (_) => BusinessBookingBloc(
        getBookings: GetBusinessBookings(
          BusinessBookingRepositoryImpl(BusinessBookingService()),
        ),
        updateStatus: UpdateBookingStatus(
          BusinessBookingRepositoryImpl(BusinessBookingService()),
        ),
      )..add(BusinessBookingBootstrap()),
      child: const BusinessBookingScreen(),
    ),

    // 2. Activities
    BlocProvider(
      create: (_) {
        final repo = BusinessActivityRepositoryImpl(BusinessActivityService());
        return BusinessActivitiesBloc(
          getActivities: GetBusinessActivities(repo),
          deleteActivity: DeleteBusinessActivity(repo),
        )..add(
          LoadBusinessActivities(
            token: widget.token,
            businessId: widget.businessId,
          ),
        );
      },
      child: BusinessActivitiesScreen(
        token: widget.token,
        businessId: widget.businessId,
      ),
    ),

    // 3. Analytics
    BlocProvider(
      create: (_) =>
          BusinessAnalyticsBloc(
            getBusinessAnalytics: GetBusinessAnalytics(
              BusinessAnalyticsRepositoryImpl(BusinessAnalyticsService()),
            ),
          )..add(
            LoadBusinessAnalytics(
              token: widget.token,
              businessId: widget.businessId,
            ),
          ),
      child: BusinessAnalyticsScreen(
        token: widget.token,
        businessId: widget.businessId,
      ),
    ),

    // 4. Profile
    BlocProvider(
      create: (_) {
        // create the HTTP service for business profile
        final businessService = BusinessService(); // low-level API
        // wrap service in repository
        final businessRepo = BusinessRepositoryImpl(businessService);

        // build the bloc with all needed usecases
        return BusinessProfileBloc(
          getBusinessById: GetBusinessById(businessRepo), // load profile
          updateBusinessVisibility: UpdateBusinessVisibility(businessRepo),
          updateBusinessStatus: UpdateBusinessStatus(businessRepo),
          deleteBusiness: DeleteBusiness(businessRepo),
          checkStripeStatus: CheckStripeStatus(businessRepo),
          createStripeConnectLink: CreateStripeConnectLink(businessRepo),
        )..add(
          LoadBusinessProfile(widget.token, widget.businessId),
        ); // initial load
      },
      child: BusinessProfileScreen(
        token: widget.token,
        businessId: widget.businessId,
        onTabChange: (i) => setState(() => _index = i), // allow tab change
        onChangeLocale: widget.onChangeLocale, // pass locale callback
      ),
    ),
  ];

  // ===== helpers: pick pages/labels/icons by role =====
  List<Widget> _pagesFor(AppRole role) =>
      role == AppRole.business ? _businessPages : _userPages;

  List<String> _labelsFor(BuildContext context, AppRole role) {
    final t = AppLocalizations.of(context)!; // localized labels
    return role == AppRole.business
        ? [
            t.tabHome,
            t.tabBookings,
            t.tabActivities,
            t.tabAnalytics,
            t.tabProfile,
          ]
        : [t.tabHome, t.tabExplore, t.tabSocial, t.tabTickets, t.tabProfile];
  }

  // (unselected icon, selected icon) pairs
  List<(IconData, IconData)> _iconsFor(AppRole role) {
    return role == AppRole.business
        ? const [
            (Icons.home_outlined, Icons.home),
            (Icons.event_available_outlined, Icons.event_available),
            (Icons.local_activity_outlined, Icons.local_activity),
            (Icons.insights_outlined, Icons.insights),
            (Icons.person_outline, Icons.person),
          ]
        : const [
            (Icons.home_outlined, Icons.home),
            (Icons.search_outlined, Icons.search),
            (Icons.groups_outlined, Icons.groups),
            (Icons.confirmation_number_outlined, Icons.confirmation_number),
            (Icons.person_outline, Icons.person),
          ];
  }

  @override
  Widget build(BuildContext context) {
    // make system nav bar translucent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final pages = _pagesFor(widget.role); // pick pages
    final labels = _labelsFor(context, widget.role); // pick labels
    final icons = _iconsFor(widget.role); // pick icons
    if (_index >= pages.length) _index = pages.length - 1; // bound index

    return Scaffold(
      extendBody: false,
      body: SafeArea(
        top: true,
        bottom: false, // let bottom bar own the bottom inset
        child: IndexedStack(
          index: _index, // preserve tab states
          children: pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: _GlassNavBar(
              index: _index,
              labels: labels,
              icons: icons,
              onChanged: (i) {
                if (i != _index) {
                  HapticFeedback.selectionClick();
                  setState(() => _index = i);
                }
              },
              badgeIndex: widget.role == AppRole.business
                  ? 1
                  : 3, // which tab shows badge
              badgeCount: widget.role == AppRole.business
                  ? widget.bookingsBadge
                  : widget.ticketsBadge,
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Glass Navigation Bar (tiny animation) =====
class _GlassNavBar extends StatelessWidget {
  final int index; // selected tab
  final List<String> labels; // tab labels
  final List<(IconData, IconData)> icons; // (off,on)
  final ValueChanged<int> onChanged; // tab changed callback
  final int badgeIndex; // which tab shows badge
  final int badgeCount; // badge value

  const _GlassNavBar({
    required this.index,
    required this.labels,
    required this.icons,
    required this.onChanged,
    required this.badgeIndex,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Frosted glass background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: const SizedBox.expand(),
          ),
          NavigationBar(
            height: 64,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedIndex: index,
            onDestinationSelected: onChanged,
            destinations: List.generate(labels.length, (i) {
              final (un, sel) = icons[i];
              final icon = _AnimatedNavIcon(
                unselected: un,
                selected: sel,
                isSelected: index == i,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.88)
                    : Colors.black.withOpacity(0.70),
                activeColor: Theme.of(context).colorScheme.primary,
              );
              final wrapped = (i == badgeIndex && badgeCount > 0)
                  ? Badge(
                      label: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: icon,
                    )
                  : icon;
              return NavigationDestination(icon: wrapped, label: labels[i]);
            }),
          ),
        ],
      ),
    );
  }
}

// ===== Small select animation for icons =====
class _AnimatedNavIcon extends StatelessWidget {
  final IconData unselected; // outline icon
  final IconData selected; // filled icon
  final bool isSelected; // active?
  final Color color; // base color
  final Color activeColor; // active color

  const _AnimatedNavIcon({
    required this.unselected,
    required this.selected,
    required this.isSelected,
    required this.color,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0), // 0..1
      builder: (context, t, _) {
        final scale = 1.0 + 0.10 * t; // grow a bit on select
        final iconData = t > 0.5 ? selected : unselected;
        final iconColor = Color.lerp(color, activeColor, t)!;
        return Transform.scale(
          scale: scale,
          child: Icon(iconData, color: iconColor, size: 26),
        );
      },
    );
  }
}
