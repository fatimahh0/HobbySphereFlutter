// ===== Flutter 3.35.x =====
// ShellDrawer — guest-aware drawer navigation (user + business).
// Guest: token == '' → only Home/Explore open; others show NotLoggedInGate.

import 'dart:convert' show base64Url, jsonDecode, utf8; // parse JWT
import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter/services.dart'; // Haptics + sys UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC

import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/core/constants/app_role.dart'; // role enum
import 'package:hobby_sphere/core/network/globals.dart' as g; // base url

// ==== Business Activity ====
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';

// ==== Business Home ====
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';

// ==== Business Notifications ====
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';

// ==== Business Profile ====
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';

// ==== Business Booking ====
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart';

// ==== Business Analytics ====
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';

// ==== Common UseCases ====
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
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
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n

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
  State<ShellDrawer> createState() => _ShellDrawerState(); // state
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0; // selected tab

  // quick guest flag
  bool get _isGuest => widget.token.trim().isEmpty; // guest if empty

  // server root without /api
  String _serverRoot() {
    final base = (g.appServerRoot ?? ''); // base
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // strip
  }

  // decode jwt payload safely
  Map<String, dynamic>? _jwtPayload(String token) {
    try {
      final parts = token.split('.'); // header.payload.sig
      if (parts.length != 3) return null; // invalid
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      ); // decode
      final obj = jsonDecode(decoded); // json
      return (obj is Map<String, dynamic>) ? obj : null; // map
    } catch (_) {
      return null; // error
    }
  }

  // extract id
  int? _extractUserId(String token) {
    final p = _jwtPayload(token); // payload
    if (p == null) return null; // none
    final raw = p['id'] ?? p['userId']; // keys
    if (raw is num) return raw.toInt(); // number
    return int.tryParse('$raw'); // string
  }

  // extract names
  String? _extractFirstName(String token) {
    final p = _jwtPayload(token); // payload
    if (p == null) return null; // none
    final fn = (p['firstName'] ?? p['given_name'])?.toString(); // keys
    if (fn != null && fn.trim().isNotEmpty) return fn.trim(); // value
    final name = p['name']?.toString(); // fallback
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+')); // split
      if (parts.isNotEmpty) return parts.first; // first
    }
    return null; // none
  }

  String? _extractLastName(String token) {
    final p = _jwtPayload(token); // payload
    if (p == null) return null; // none
    final ln = (p['lastName'] ?? p['family_name'])?.toString(); // keys
    if (ln != null && ln.trim().isNotEmpty) return ln.trim(); // value
    final name = p['name']?.toString(); // fallback
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+')); // split
      if (parts.length > 1) return parts.sublist(1).join(' '); // rest
    }
    return null; // none
  }

  // ---- DI for User Home / Explore ----
  late final _homeRepo = HomeRepositoryImpl(HomeService()); // repo
  late final _getInterest = GetInterestBasedItems(_homeRepo); // UC
  late final _getUpcoming = GetUpcomingGuestItems(_homeRepo); // UC
  late final _getItemTypes = GetItemTypes(
    ItemTypeRepositoryImpl(ItemTypesService()),
  ); // UC
  late final _getItemsByType = GetItemsByType(
    ItemsRepositoryImpl(ItemsService()),
  ); // UC

  // parsed identity (safe if guest)
  late final int _userId = _extractUserId(widget.token) ?? 0; // id or 0
  late final String? _firstName = _extractFirstName(widget.token); // fn
  late final String? _lastName = _extractLastName(widget.token); // ln

  // ===== Build user profile page (service -> repo -> UCs -> bloc -> screen) =====
  Widget _buildUserProfilePage() {
    final service = upsvc.UserProfileService(); // svc
    final repo = UserProfileRepositoryImpl(service); // repo
    final getUser = GetUserProfile(repo); // uc
    final toggleVis = ToggleUserVisibility(repo); // uc
    final setStatus = UpdateUserStatus(repo); // uc

    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: setStatus)], // expose UC
      child: BlocProvider(
        create: (_) => UserProfileBloc(
          // bloc
          getUser: getUser,
          toggleVisibility: toggleVis,
          updateStatus: setStatus,
        )..add(LoadUserProfile(widget.token, _userId)), // initial load
        child: UserProfileScreen(
          token: widget.token, // token
          userId: _userId, // id
          onChangeLocale: widget.onChangeLocale, // i18n
        ),
      ),
    );
  }

  // ===== USER PAGES (guest-aware) =====
  late final List<Widget> _userPages = <Widget>[
    // 0) Home — your UserHomeScreen already handles guest safely (no unread cubit)
    UserHomeScreen(
      firstName: _isGuest ? null : _firstName, // hide if guest
      lastName: _isGuest ? null : _lastName, // hide if guest
      token: widget.token, // '' in guest
      userId: _isGuest ? 0 : _userId, // 0 in guest
      getInterestBased: _getInterest, // UC
      getUpcomingGuest: _getUpcoming, // UC
      getItemTypes: _getItemTypes, // UC
      getItemsByType: _getItemsByType, // UC
    ),

    // 1) Explore — open for guest
    ExploreScreen(
      token: widget.token, // '' in guest
      getItemTypes: _getItemTypes, // UC
      getItemsByType: _getItemsByType, // UC
      getUpcomingGuest: _getUpcoming, // UC
      // currency getter wrapped in try/catch to avoid auth crash in guest
      getCurrencyCode: () async {
        try {
          final uc = GetCurrentCurrency(
            CurrencyRepositoryImpl(CurrencyService()),
          );
          return (await uc(widget.token)).code; // code
        } catch (_) {
          return null; // fallback null
        }
      },
      imageBaseUrl: _serverRoot(), // absolute base
    ),

    // 2) Community — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => Navigator.pushNamed(context, Routes.login),
            onRegister: () => Navigator.pushNamed(context, Routes.register),
          )
        : CommunityScreen(
            token: widget.token, // token
            userId: _userId, // id
            imageBaseUrl: _serverRoot(), // base
          ),

    // 3) Tickets — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => Navigator.pushNamed(context, Routes.login),
            onRegister: () => Navigator.pushNamed(context, Routes.register),
          )
        : UserTicketsScreen(token: widget.token), // tickets
    // 4) Profile — gate for guest
    _isGuest
        ? NotLoggedInGate(
            onLogin: () => Navigator.pushNamed(context, Routes.login),
            onRegister: () => Navigator.pushNamed(context, Routes.register),
          )
        : _buildUserProfilePage(), // profile
  ];

  // ===== BUSINESS PAGES (same as your latest) =====
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
          Navigator.pushNamed(
            ctx,
            Routes.createBusinessActivity,
            arguments: CreateActivityRouteArgs(businessId: bid),
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
      create: (ctx) {
        final businessRepo = BusinessRepositoryImpl(BusinessService());
        return BusinessProfileBloc(
          getBusinessById: GetBusinessById(businessRepo),
          updateBusinessVisibility: UpdateBusinessVisibility(businessRepo),
          updateBusinessStatus: UpdateBusinessStatus(businessRepo),
          deleteBusiness: DeleteBusiness(businessRepo),
          checkStripeStatus: CheckStripeStatus(businessRepo),
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

    final scheme = Theme.of(context).colorScheme; // colors
    final menu =
        widget.role ==
            AppRole
                .business // choose menu
        ? _businessMenu(context)
        : _userMenu(context);

    _index = _index.clamp(0, menu.length - 1); // clamp index

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.35), // dim bg
      drawer: Drawer(
        width: 304, // drawer width
        backgroundColor: scheme.surface, // bg color
        shape: const RoundedRectangleBorder(
          // rounded edge
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: _DrawerContent(
            // list builder
            items: menu, // items
            index: _index, // selected
            onTap: (i) {
              Navigator.pop(context); // close drawer
              if (i == _index) return; // ignore same
              HapticFeedback.selectionClick(); // haptic
              setState(() => _index = i); // change page
            },
            iconBaseColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.88) // dark color
                : Colors.black.withOpacity(0.72), // light color
            activeColor: scheme.primary, // active color
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
                  icon: const Icon(Icons.menu), // menu icon
                  onPressed: () => Scaffold.of(ctx).openDrawer(), // open drawer
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                // keep state
                index: _index, // active
                children: menu.map((m) => m.page).toList(), // pages
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
  final List<({String title, IconData icon, Widget page, int? badge})>
  items; // items
  final int index; // selected
  final ValueChanged<int> onTap; // tap callback
  final Color iconBaseColor; // base icon
  final Color activeColor; // active color

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
      thumbVisibility: true, // always visible
      radius: const Radius.circular(12), // rounded thumb
      thickness: 4, // width
      child: ListView(
        padding: EdgeInsets.zero, // no extra padding
        children: [
          const Divider(height: 1), // top line
          ...List.generate(items.length, (i) {
            final it = items[i]; // item
            return _AnimatedDrawerTile(
              icon: it.icon, // icon
              label: it.title, // title
              selected: i == index, // is selected
              onTap: () => onTap(i), // choose
              iconBaseColor: iconBaseColor, // color
              activeColor: activeColor, // active color
              badge: it.badge, // optional badge
            );
          }),
          const Divider(height: 1), // bottom line
        ],
      ),
    );
  }
}

// ===== Drawer tile with tiny animation =====
class _AnimatedDrawerTile extends StatelessWidget {
  final IconData icon; // icon
  final String label; // label
  final bool selected; // selected?
  final VoidCallback onTap; // tap
  final Color iconBaseColor; // base icon color
  final Color activeColor; // active color
  final int? badge; // optional badge

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
    const duration = Duration(milliseconds: 220); // anim speed

    return InkWell(
      onTap: onTap, // select
      child: TweenAnimationBuilder<double>(
        duration: duration, // timing
        curve: Curves.easeOutCubic, // easing
        tween: Tween<double>(begin: 0, end: selected ? 1 : 0), // 0..1
        builder: (context, t, _) {
          final Color ic = Color.lerp(
            iconBaseColor,
            activeColor,
            t,
          )!; // icon color
          final Color textColor = Color.lerp(
            Theme.of(context).colorScheme.onSurface, // base text
            activeColor, // active text
            t, // mix
          )!;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ), // outer
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ), // inner
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), // rounded
              color: activeColor.withOpacity(0.08 * t), // active tint
            ),
            child: Row(
              children: [
                Icon(icon, color: ic), // icon
                const SizedBox(width: 12), // gap
                Expanded(
                  child: Text(
                    label, // title
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor, // color
                      fontWeight: t > 0
                          ? FontWeight.w600
                          : FontWeight.w500, // weight
                    ),
                  ),
                ),
                if (badge != null && badge! > 0) // show badge if any
                  Badge(
                    label: Text(
                      badge! > 99 ? '99+' : '$badge', // cap 99+
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
