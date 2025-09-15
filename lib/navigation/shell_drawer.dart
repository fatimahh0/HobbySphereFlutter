// ===== Flutter 3.35.x =====
// ShellDrawer — drawer navigation for user & business roles.
// Final: Clean AppBar (menu icon only), full drawer with scrollbar.

import 'dart:convert' show base64Url, jsonDecode, utf8; // << parse JWT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';

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

// ==== User Screens ====
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/user_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/user_profile_screen.dart';

// ==== User Home feature (services/repos/usecases) ====
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

// ==== Common (types + items-by-type) for Categories section ====
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

// ==== Localization ====
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellDrawer extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;
  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;
  final int bookingsBadge;
  final int ticketsBadge;

  const ShellDrawer({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
    required this.onChangeLocale,
    required this.onToggleTheme,
  });

  @override
  State<ShellDrawer> createState() => _ShellDrawerState();
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0;

  // ---- helpers to read jwt ----
  int? _extractUserId(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final raw = payload['id'] ?? payload['userId'];
      if (raw is num) return raw.toInt();
      return int.tryParse('$raw');
    } catch (_) {
      return null;
    }
  }

  String? _extractDisplayName(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final n = payload['name'] ?? payload['given_name'] ?? payload['username'];
      return n?.toString();
    } catch (_) {
      return null;
    }
  }

  // ---- DI for User Home feature ----
  late final _homeRepo = HomeRepositoryImpl(HomeService());
  late final _getInterest = GetInterestBasedItems(_homeRepo);
  late final _getUpcoming = GetUpcomingGuestItems(_homeRepo);
  late final _getItemTypes = GetItemTypes(
    ItemTypeRepositoryImpl(ItemTypesService()),
  );
  late final _getItemsByType = GetItemsByType(
    ItemsRepositoryImpl(ItemsService()),
  );

  late final int _userId = _extractUserId(widget.token) ?? 0;
  late final String _userName = _extractDisplayName(widget.token) ?? 'User';

  // ===== User pages =====
  late final List<Widget> _userPages = <Widget>[
    UserHomeScreen(
      displayName: _userName,
      token: widget.token,
      userId: _userId, // if 0 => interests section hides
      getInterestBased: _getInterest,
      getUpcomingGuest: _getUpcoming,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,

    ),
    const UserExploreScreen(),
    const UserCommunityScreen(),
    const UserTicketsScreen(),
    const UserProfileScreen(),
  ];

  // ===== Business pages =====
  late final List<Widget> _businessPages = <Widget>[
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

  // ===== Menus =====
  List<({String title, IconData icon, Widget page, int? badge})> _businessMenu(
    BuildContext context,
  ) {
    final t = AppLocalizations.of(context)!;
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
    final t = AppLocalizations.of(context)!;
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
        badge: widget.ticketsBadge > 0 ? widget.ticketsBadge : null,
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
              Navigator.pop(context);
              if (i == _index) return;
              HapticFeedback.selectionClick();
              setState(() => _index = i);
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
            // ✅ Menu icon only
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
                index: _index,
                children: menu.map((m) => m.page).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
