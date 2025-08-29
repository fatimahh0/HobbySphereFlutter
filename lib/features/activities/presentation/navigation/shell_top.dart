// ===== Flutter 3.35.x =====
// ShellTop — fixed top bar (no content transparency) + smooth Tab animation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hobby_sphere/features/activities/presentation/Business/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/business_analytics_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/business_booking_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/BusinessHomeScreen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/business_profile_screen.dart';

import 'package:hobby_sphere/features/activities/presentation/User/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/User/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/User/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/User/user_profile_screen.dart';
import 'package:hobby_sphere/features/activities/presentation/User/user_tickets_screen.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../../../../core/constants/app_role.dart';

class ShellTop extends StatelessWidget {
  final AppRole role;
  final String token;
  final int businessId;

  // optional badges (biz: bookings, user: tickets)
  final int bookingsBadge;
  final int ticketsBadge;

  const ShellTop({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

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

  List<(IconData, IconData)> _icons() {
    return role == AppRole.business
        ? const [
            (Icons.home_outlined, Icons.home),
            (Icons.event_available_outlined, Icons.event_available),
            (Icons.insights_outlined, Icons.insights),
            (Icons.local_activity_outlined, Icons.local_activity),
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

  List<Widget> _views(BuildContext context) {
    if (role == AppRole.business) {
      return [
        BusinessHomeScreen(
          token: token,
          businessId: businessId,
          onCreate: () =>
              Navigator.of(context).pushNamed('/business/activity/create'),
        ),
        const BusinessBookingScreen(),
        const BusinessAnalyticsScreen(),
        const BusinessActivitiesScreen(),
        const BusinessProfileScreen(),
      ];
    }
    return const [
      UserHomeScreen(),
      UserExploreScreen(),
      UserCommunityScreen(),
      UserTicketsScreen(),
      UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // system bars
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final labels = _labels(context);
    final icons = _icons();
    final pages = _views(context);

    final badgeIndex = role == AppRole.business ? 1 : 3;
    final badgeCount = role == AppRole.business ? bookingsBadge : ticketsBadge;

    // compact header
    const toolbarH = 44.0;
    const tabsH = 44.0;

    // opaque glass (no BackdropFilter }
    final border = isDark
        ? Colors.white.withOpacity(0.16)
        : Colors.white.withOpacity(0.20);
    final fill = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.10);
    final shadow = isDark ? 0.22 : 0.10;

    return DefaultTabController(
      length: labels.length,
      child: Scaffold(
   
        extendBodyBehindAppBar: true,

        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + toolbarH + tabsH,
          ),
          child: TabBarView(children: pages),
        ),

        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: toolbarH,
          title: const Text('Hobby Sphere'),

          flexibleSpace: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ), 
            decoration: BoxDecoration(
              color: fill,
              border: Border(bottom: BorderSide(color: border, width: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadow),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(tabsH),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border, width: 1),
                  color: fill, 
                ),
                child: TabBar(
                  isScrollable: true,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  indicatorPadding: const EdgeInsets.all(2),
                  indicator: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.primary.withOpacity(0.26),
                      width: 1,
                    ),
                  ),
                  tabs: List.generate(labels.length, (i) {
                    final (un, sel) = icons[i];
                    final chip = _AnimatedTabChip(
                      index: i,
                      label: labels[i],
                      unselected: un,
                      selected: sel,
                      base: isDark
                          ? Colors.white.withOpacity(0.86)
                          : Colors.black.withOpacity(0.72),
                      active: scheme.primary,
                    );

                    if (i == badgeIndex && badgeCount > 0) {
                      return Tab(
                        child: Badge(
                          label: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: chip,
                        ),
                      );
                    }
                    return Tab(child: chip);
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth tab chip animation (scale + color) based on controller progress.
class _AnimatedTabChip extends StatelessWidget {
  final int index;
  final String label;
  final IconData unselected;
  final IconData selected;
  final Color base;
  final Color active;

  const _AnimatedTabChip({
    required this.index,
    required this.label,
    required this.unselected,
    required this.selected,
    required this.base,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = DefaultTabController.maybeOf(context);
    if (ctrl?.animation == null) {
      return _chip(0.0);
    }
    return AnimatedBuilder(
      animation: ctrl!.animation!,
      builder: (context, _) {
        final pos = ctrl.animation!.value; // ex: 0.0, 0.3, 1.0 ...
        final dist = (pos - index).abs(); // distance from this tab
        final t = (1.0 - dist).clamp(0.0, 1.0); // 0..1 selectedness
        return _chip(t);
      },
    );
  }

  Widget _chip(double t) {
    final scale = 1.0 + 0.10 * t;
    final iconData = t > 0.5 ? selected : unselected;
    final iconColor = Color.lerp(base, active, t)!;
    final textWeight = t > 0.5 ? FontWeight.w600 : FontWeight.w500;
    final textColor = Color.lerp(Colors.black.withOpacity(0.70), active, t)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: Icon(iconData, color: iconColor, size: 18),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontWeight: textWeight, color: textColor),
        ),
      ],
    );
  }
}
