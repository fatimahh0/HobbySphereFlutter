// ===== Flutter 3.35.x =====
// ShellDrawer — drawer navigation for user & business roles.
// Fixed: BusinessActivitiesScreen now receives token + businessId.

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
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
import 'package:hobby_sphere/l10n/app_localizations.dart';

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

// ===== User screens =====
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_profile_screen.dart';

class ShellDrawer extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;
  final void Function(Locale) onChangeLocale; // 👈 NEW
  final VoidCallback onToggleTheme; // optional if you want theme switching
  final int bookingsBadge; // business only
  final int ticketsBadge; // user only

  const ShellDrawer({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
    required this.onChangeLocale, // 👈 required now
    required this.onToggleTheme, // 👈 if you also support theme toggle
  });

  @override
  State<ShellDrawer> createState() => _ShellDrawerState();
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0;

  // ===== User pages =====
  late final List<Widget> _userPages = const [
    UserHomeScreen(),
    UserExploreScreen(),
    UserCommunityScreen(),
    UserTicketsScreen(),
    UserProfileScreen(),
  ];

  // ===== Business pages =====
  late final List<Widget> _businessPages = <Widget>[
    BusinessHomeScreen(
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

    // ✅ FIXED: Pass token + businessId to activities screen
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
        onChangeLocale: widget.onChangeLocale, // 👈 pass callback
      ),
    ),
  ];

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
      appBar: AppBar(
        title: Text(menu[_index].title),
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _index,
        children: menu.map((m) => m.page).toList(),
      ),
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
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.15),
                ),
                child: Icon(Icons.hub, color: activeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.appTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.tabProfile,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        _AnimatedDrawerTile(
          icon: Icons.settings_outlined,
          label: t.tabSettings,
          selected: false,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${t.tabSettings} coming soon')),
            );
          },
          iconBaseColor: iconBaseColor,
          activeColor: activeColor,
        ),
        const SizedBox(height: 12),
      ],
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
    const curve = Curves.easeOutCubic;

    return InkWell(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
        builder: (context, t, _) {
          final Color ic = Color.lerp(iconBaseColor, activeColor, t)!;
          final FontWeight fw = t > 0 ? FontWeight.w600 : FontWeight.w500;
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
              boxShadow: t > 0.0
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.20 * t),
                        blurRadius: 14 * t,
                        offset: Offset(0, 6 * t),
                      ),
                    ]
                  : null,
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
                      fontWeight: fw,
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
