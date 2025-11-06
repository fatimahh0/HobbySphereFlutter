// ===== Flutter 3.35.x =====
// ShellDrawer — guest-aware drawer navigation (user + business).
// Rule: token == '' → only Home/Explore open; others show NotLoggedInGate.
// Uses go_router; replaces Navigator.pushNamed with context.pushNamed.

import 'dart:convert' show base64Url, jsonDecode, utf8; // parse JWT
import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter/services.dart'; // Haptics + sys UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:go_router/go_router.dart'; // go_router

import 'package:hobby_sphere/app/router/router.dart'; // route names + navigatorKey
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

// If your routes carry typed args via `extra`, import them here:
import 'package:hobby_sphere/features/activities/routes_activity.dart';

// ==== Business Activity ====
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/screen/business_activities_screen.dart';

// ==== Business Home ====
import 'package:hobby_sphere/features/activities/business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/business/businessHome/presentation/screen/business_home_screen.dart';

// ==== Business Notifications ====
import 'package:hobby_sphere/features/activities/business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_event.dart';

// ==== Business Profile ====
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

// ==== Business Booking ====
import 'package:hobby_sphere/features/activities/business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/business/businessBooking/presentation/screen/business_booking_screen.dart';

// ==== Business Analytics ====
import 'package:hobby_sphere/features/activities/business/businessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/business/businessAnalytics/presentation/screen/business_analytics_screen.dart';

// ==== Common UseCases ====
import 'package:hobby_sphere/features/activities/business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// ==== User Screens ====
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/screens/user_explore_screen.dart'
    show ExploreScreen;
import 'package:hobby_sphere/features/activities/user/userCommunity/presentation/screens/community_screen.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/user_tickets_screen.dart';

// ==== User Home DI ====
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

// ==== Common (types + items-by-type) ====
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

// ==== User Profile feature (alias) ====
import 'package:hobby_sphere/features/activities/user/userProfile/data/services/user_profile_service.dart'
    as upsvc;
import 'package:hobby_sphere/features/activities/user/userProfile/data/repositories/user_profile_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/get_user_profile.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/toggle_user_visibility.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/update_user_status.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/bloc/user_profile_event.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/presentation/screens/user_profile_screen.dart';

// ==== Guest Gate ====
import 'package:hobby_sphere/shared/widgets/not_logged_in_gate.dart';

// ==== Localization ====
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellDrawer extends StatefulWidget {
  final AppRole role; // role
  final String token; // jwt ('' => guest)
  final int businessId; // business id
  final void Function(Locale) onChangeLocale; // i18n
  final VoidCallback onToggleTheme; // theme
  final int bookingsBadge; // biz badge
  final int ticketsBadge; // user badge

  const ShellDrawer({
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
  State<ShellDrawer> createState() => _ShellDrawerState();
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0; // selected tab

  // quick guest flag
  bool get _isGuest => widget.token.trim().isEmpty;

  // server root without /api
  String _serverRoot() =>
      (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');

  // decode jwt payload safely
  Map<String, dynamic>? _jwtPayload(String token) {
    try {
      final parts = token.split('.'); // header.payload.sig
      if (parts.length != 3) return null;
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final obj = jsonDecode(decoded);
      return (obj is Map<String, dynamic>) ? obj : null;
    } catch (_) {
      return null;
    }
  }

  // extract id / names
  int? _extractUserId(String token) {
    final p = _jwtPayload(token);
    final raw = p?['id'] ?? p?['userId'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw');
  }

  String? _extractFirstName(String token) {
    final p = _jwtPayload(token);
    final fn = (p?['firstName'] ?? p?['given_name'])?.toString();
    if (fn != null && fn.trim().isNotEmpty) return fn.trim();
    final name = p?['name']?.toString();
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
    final name = p?['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) return parts.sublist(1).join(' ');
    }
    return null;
  }

  // ---- DI for User Home / Explore ----
  late final _homeRepo = HomeRepositoryImpl(HomeService());
  late final _getInterest = GetInterestBasedItems(_homeRepo);
  late final _getUpcoming = GetUpcomingGuestItems(_homeRepo);
  late final _getItemTypes = GetItemTypes(
    ItemTypeRepositoryImpl(ItemTypesService()),
  );
  late final _getItemsByType = GetItemsByType(
    ItemsRepositoryImpl(ItemsService()),
  );

  // parsed identity (safe if guest)
  late final int _userId = _extractUserId(widget.token) ?? 0;
  late final String? _firstName = _extractFirstName(widget.token);
  late final String? _lastName = _extractLastName(widget.token);

  // ===== Build user profile page (service -> repo -> UCs -> bloc -> screen) =====
  Widget _buildUserProfilePage() {
    final service = upsvc.UserProfileService();
    final repo = UserProfileRepositoryImpl(service);
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
        )..add(LoadUserProfile(widget.token, _userId)),
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
    // 0) Home — UserHomeScreen already handles guest safely
    UserHomeScreen(
      firstName: _isGuest ? null : _firstName,
      lastName: _isGuest ? null : _lastName,
      token: widget.token,
      userId: _isGuest ? 0 : _userId,
      getInterestBased: _getInterest,
      getUpcomingGuest: _getUpcoming,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
    ),

    // 1) Explore — open for guest
    ExploreScreen(
      token: widget.token,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
      getUpcomingGuest: _getUpcoming,
      // currency getter wrapped in try/catch to avoid auth crash in guest
      getCurrencyCode: () async {
        try {
          final uc = GetCurrentCurrency(
            CurrencyRepositoryImpl(CurrencyService()),
          );
          return (await uc(widget.token)).code;
        } catch (_) {
          return null;
        }
      },
      imageBaseUrl: _serverRoot(),
    ),

    // 2) Community — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login),
            onRegister: () => context.pushNamed(Routes.register),
          )
        : CommunityScreen(
            token: widget.token,
            userId: _userId,
            imageBaseUrl: _serverRoot(),
          ),

    // 3) Tickets — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login),
            onRegister: () => context.pushNamed(Routes.register),
          )
        : UserTicketsScreen(token: widget.token),

    // 4) Profile — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => context.pushNamed(Routes.login),
            onRegister: () => context.pushNamed(Routes.register),
          )
        : _buildUserProfilePage(),
  ];

  // ===== BUSINESS PAGES (with go_router for navigation) =====
  late final List<Widget> _businessPages = <Widget>[
    // 0) Business Home with notifications
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
            token: widget.token,
            businessId: widget.businessId,
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
              token: widget.token,
            )..add(LoadUnreadCount(widget.token));
          },
        ),
      ],
      child: BusinessHomeScreen(
        token: widget.token,
        businessId: widget.businessId,
        onCreate: (ctx, bid) {
          // go_router: pass typed args in `extra`
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
      create: (ctx) =>
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

    // 3) Activities
    BlocProvider(
      create: (ctx) {
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

    // 4) Profile
    BlocProvider(
      create: (_) {
        final businessService = BusinessService(); // low-level API
        final businessRepo = BusinessRepositoryImpl(businessService);

        return BusinessProfileBloc(
          getBusinessById: GetBusinessById(businessRepo),
          updateBusinessVisibility: UpdateBusinessVisibility(businessRepo),
          updateBusinessStatus: UpdateBusinessStatus(businessRepo),
          deleteBusiness: DeleteBusiness(businessRepo),
          checkStripeStatus: CheckStripeStatus(businessRepo),
          createStripeConnectLink: CreateStripeConnectLink(businessRepo),
        )..add(LoadBusinessProfile(widget.token, widget.businessId));
      },
      child: BusinessProfileScreen(
        token: widget.token,
        businessId: widget.businessId,
        onTabChange: (i) => setState(() => _index = i),
        onChangeLocale: widget.onChangeLocale,
      ),
    ),
  ];

  // ===== Drawer menu models (labels + icons + pages + optional badges) =====
  List<({String title, IconData icon, Widget page, int? badge})> _businessMenu(
    BuildContext context,
  ) {
    final t = AppLocalizations.of(context)!; // l10n
    return [
      (
        title: t.tabHome,
        icon: Icons.home_outlined,
        page: _businessPages[0],
        badge: null,
      ),
      (
        title: t.tabBookings,
        icon: Icons.event_available_outlined,
        page: _businessPages[1],
        badge: widget.bookingsBadge > 0 ? widget.bookingsBadge : null,
      ),
      (
        title: t.tabAnalytics,
        icon: Icons.insights_outlined,
        page: _businessPages[2],
        badge: null,
      ),
      (
        title: t.tabActivities,
        icon: Icons.local_activity_outlined,
        page: _businessPages[3],
        badge: null,
      ),
      (
        title: t.tabProfile,
        icon: Icons.person_outline,
        page: _businessPages[4],
        badge: null,
      ),
    ];
  }

  List<({String title, IconData icon, Widget page, int? badge})> _userMenu(
    BuildContext context,
  ) {
    final t = AppLocalizations.of(context)!; // l10n
    return [
      (
        title: t.tabHome,
        icon: Icons.home_outlined,
        page: _userPages[0],
        badge: null,
      ),
      (
        title: t.tabExplore,
        icon: Icons.search_outlined,
        page: _userPages[1],
        badge: null,
      ),
      (
        title: t.tabSocial,
        icon: Icons.groups_outlined,
        page: _userPages[2],
        badge: null,
      ),
      (
        title: t.tabTickets,
        icon: Icons.confirmation_number_outlined,
        page: _userPages[3],
        badge: _isGuest
            ? null
            : (widget.ticketsBadge > 0 ? widget.ticketsBadge : null),
      ),
      (
        title: t.tabProfile,
        icon: Icons.person_outline,
        page: _userPages[4],
        badge: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // set system nav bar color to surface for drawer
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    final scheme = Theme.of(context).colorScheme;
    final menu = widget.role == AppRole.business
        ? _businessMenu(context)
        : _userMenu(context);

    _index = _index.clamp(0, menu.length - 1);

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.35),
      drawer: Drawer(
        width: 304,
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: _DrawerContent(
            items: menu,
            index: _index,
            onTap: (i) {
              Navigator.pop(context); // close drawer
              if (i == _index) return; // ignore if same
              HapticFeedback.selectionClick(); // small haptic
              setState(() => _index = i); // change page
            },
            iconBaseColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.88)
                : Colors.black.withOpacity(0.72),
            activeColor: scheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // simple top bar (menu icon only)
            Align(
              alignment: Alignment.centerLeft,
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _index, // keep state
                children: menu.map((m) => m.page).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Drawer content =====
class _DrawerContent extends StatelessWidget {
  final List<({String title, IconData icon, Widget page, int? badge})> items;
  final int index;
  final ValueChanged<int> onTap;
  final Color iconBaseColor;
  final Color activeColor;

  const _DrawerContent({
    required this.items,
    required this.index,
    required this.onTap,
    required this.iconBaseColor,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      radius: const Radius.circular(12),
      thickness: 4,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Divider(height: 1),
          ...List.generate(items.length, (i) {
            final it = items[i];
            return _AnimatedDrawerTile(
              icon: it.icon,
              label: it.title,
              selected: i == index,
              onTap: () => onTap(i),
              iconBaseColor: iconBaseColor,
              activeColor: activeColor,
              badge: it.badge,
            );
          }),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ===== Drawer tile with tiny animation =====
class _AnimatedDrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color iconBaseColor;
  final Color activeColor;
  final int? badge;

  const _AnimatedDrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconBaseColor,
    required this.activeColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 220);

    return InkWell(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
        builder: (context, t, _) {
          final Color ic = Color.lerp(iconBaseColor, activeColor, t)!;
          final Color textColor = Color.lerp(
            Theme.of(context).colorScheme.onSurface,
            activeColor,
            t,
          )!;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: activeColor.withOpacity(0.08 * t),
            ),
            child: Row(
              children: [
                Icon(icon, color: ic),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: t > 0 ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null && badge! > 0)
                  Badge(
                    label: Text(
                      badge! > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
