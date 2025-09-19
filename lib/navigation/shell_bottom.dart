// ===== Flutter 3.35.x =====
// ShellBottom — glassy transparent bottom bar + fixed animation.
// Mirrors ShellDrawer: passes token + businessId, injects Blocs for Bookings + Analytics.

import 'dart:ui' show ImageFilter;
import 'dart:convert' show base64Url, jsonDecode, utf8; // << parse JWT
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/app/router/router.dart';
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
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// ===== User screens =====
import 'package:hobby_sphere/features/activities/user/userHome/presentation/screens/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/screens/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/tickets/presentation/screens/user_tickets_screen.dart';

// ===== User Home feature (services/repos/usecases) =====
import 'package:hobby_sphere/features/activities/user/userHome/data/services/home_service.dart';
import 'package:hobby_sphere/features/activities/user/userHome/data/repositories/home_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

// ===== Common types + items-by-type (for Categories section) =====
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/data/services/items_service.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/items_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellBottom extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;
  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;

  final int bookingsBadge;
  final int ticketsBadge;

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
  int _index = 0;

  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  // ---- helpers to read jwt ----
  Map<String, dynamic>? _jwtPayload(String token) {
    try {
      final parts = token.split('.');
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

  int? _extractUserId(String token) {
    final payload = _jwtPayload(token);
    if (payload == null) return null;
    final raw = payload['id'] ?? payload['userId'];
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw');
  }

  String? _extractFirstName(String token) {
    final p = _jwtPayload(token);
    if (p == null) return null;
    final fn = (p['firstName'] ?? p['given_name'])?.toString();
    if (fn != null && fn.trim().isNotEmpty) return fn.trim();

    final name = p['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) return parts.first;
    }
    return null;
  }

  String? _extractLastName(String token) {
    final p = _jwtPayload(token);
    if (p == null) return null;
    final ln = (p['lastName'] ?? p['family_name'])?.toString();
    if (ln != null && ln.trim().isNotEmpty) return ln.trim();

    final name = p['name']?.toString();
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        return parts.sublist(1).join(' ');
      }
    }
    return null;
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
  late final String? _firstName = _extractFirstName(widget.token);
  late final String? _lastName = _extractLastName(widget.token);

  // ===== User pages =====
  late final List<Widget> _userPages = <Widget>[
    UserHomeScreen(
      firstName: _firstName, // << pass names (header shows First + Last)
      lastName: _lastName,
      token: widget.token,
      userId: _userId, // if 0 => interests section hides
      getInterestBased: _getInterest,
      getUpcomingGuest: _getUpcoming,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
    ),
    ExploreScreen(
      token: widget.token,
      getItemTypes: _getItemTypes,
      getItemsByType: _getItemsByType,
      getUpcomingGuest: _getUpcoming,
      getCurrencyCode: () async => (await GetCurrentCurrency(
        CurrencyRepositoryImpl(CurrencyService()),
      )(widget.token)).code,
      imageBaseUrl: _serverRoot(),
    ),

    const UserCommunityScreen(),
    UserTicketsScreen(token: widget.token),
  ];

  // ===== Business pages =====
  late final List<Widget> _businessPages = <Widget>[
    // 0. Home
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

    // 1. Bookings
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

    // 2. Activities
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

    // 3. Analytics
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

    // 4. Profile
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

  // ===== Helpers =====
  List<Widget> _pagesFor(AppRole role) =>
      role == AppRole.business ? _businessPages : _userPages;

  List<String> _labelsFor(BuildContext context, AppRole role) {
    final t = AppLocalizations.of(context)!;
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final pages = _pagesFor(widget.role);
    final labels = _labelsFor(context, widget.role);
    final icons = _iconsFor(widget.role);

    if (_index >= pages.length) _index = pages.length - 1;

    return Scaffold(
      extendBody: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
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
              badgeIndex: widget.role == AppRole.business ? 1 : 3,
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

/// Extracted Glass NavBar widget for clarity
class _GlassNavBar extends StatelessWidget {
  final int index;
  final List<String> labels;
  final List<(IconData, IconData)> icons;
  final ValueChanged<int> onChanged;
  final int badgeIndex;
  final int badgeCount;

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

/// Tiny, tasteful selected animation
class _AnimatedNavIcon extends StatelessWidget {
  final IconData unselected;
  final IconData selected;
  final bool isSelected;
  final Color color;
  final Color activeColor;

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
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      builder: (context, t, _) {
        final scale = 1.0 + 0.10 * t;
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
