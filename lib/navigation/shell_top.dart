// ===== Flutter 3.35.x =====
// ShellTop — glass AppBar + animated top tabs (role-aware)
// - Transparent/glassy AppBar (blur, hairline, soft shadow)
// - Pill indicator + animated icon/label (scale & color tween)
// - Badges: Bookings (business) / Tickets (user)
// - Role-aware pages (same as bottom/drawer)

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hobby_sphere/features/presentation/pages/Business/business_activities_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/Business/business_analytics_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/Business/business_booking_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/business_home_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/Business/business_profile_screen.dart';

import 'package:hobby_sphere/features/presentation/pages/User/user_community_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/User/user_explore_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/User/user_home_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/User/user_profile_screen.dart';
import 'package:hobby_sphere/features/presentation/pages/User/user_tickets_screen.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../core/auth/app_role.dart';

class ShellTop extends StatelessWidget {
  final AppRole role;
  final String token;
  final int businessId;

  /// Optional badges to mirror other shells.
  final int bookingsBadge; // business tab index 1
  final int ticketsBadge; // user tab index 3

  const ShellTop({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  List<String> _labelsFor(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (role == AppRole.business) {
      return [
        t.tabHome,
        t.tabBookings,
        t.tabAnalytics,
        t.tabActivities,
        t.tabProfile,
      ];
    }
    return [t.tabHome, t.tabExplore, t.tabSocial, t.tabTickets, t.tabProfile];
  }

  List<(IconData, IconData)> _iconsFor() {
    if (role == AppRole.business) {
      return const [
        (Icons.home_outlined, Icons.home),
        (Icons.event_available_outlined, Icons.event_available),
        (Icons.insights_outlined, Icons.insights),
        (Icons.local_activity_outlined, Icons.local_activity),
        (Icons.person_outline, Icons.person),
      ];
    }
    return const [
      (Icons.home_outlined, Icons.home),
      (Icons.search_outlined, Icons.search),
      (Icons.groups_outlined, Icons.groups),
      (Icons.confirmation_number_outlined, Icons.confirmation_number),
      (Icons.person_outline, Icons.person),
    ];
  }

  List<Widget> _views() {
    if (role == AppRole.business) {
      return [
        BusinessHomeScreen(
          token: token,
          businessId: businessId,
          onCreate: () => Navigator.pushNamed(
            _ShellTopNav.ctx!,
            '/business/activity/create',
          ),
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
    // Seamless status bar on Android.
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
    final labels = _labelsFor(context);
    final icons = _iconsFor();
    final pages = _views();

    // For building routes from inside BusinessHomeScreen.onCreate
    _ShellTopNav.ctx = context;

    final glassBorder = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.25);
    final iconBase = isDark
        ? Colors.white.withOpacity(0.88)
        : Colors.black.withOpacity(0.70);

    final badgeIndex = role == AppRole.business ? 1 : 3;
    final badgeCount = role == AppRole.business ? bookingsBadge : ticketsBadge;

    return DefaultTabController(
      length: labels.length,
      child: Scaffold(
        extendBodyBehindAppBar: true, // content slides under glass AppBar
        body: Stack(
          children: [
            // Pages
            Padding(
              // AppBar height (64) + Tabs container height (~56) = 120
              // but AppBar already reserves space; keep body clean.
              padding: EdgeInsets.zero,
              child: TabBarView(children: pages),
            ),

            // Glass AppBar + TabBar
            Align(
              alignment: Alignment.topCenter,
              child: _GlassTopBar(
                title: 'Hobby Sphere', // i18n if you like
                glassBorder: glassBorder,
                child: _ProTabBar(
                  labels: labels,
                  icons: icons,
                  iconBase: iconBase,
                  active: scheme.primary,
                  isDark: isDark,
                  badgeIndex: badgeCount > 0 ? badgeIndex : -1,
                  badgeCount: badgeCount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps a static reference for the onCreate route call above (scaffold context).
class _ShellTopNav {
  static BuildContext? ctx;
}

/// Glassy header container that holds the AppBar title + TabBar.
class _GlassTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color glassBorder;
  final Widget child;

  const _GlassTopBar({
    required this.title,
    required this.glassBorder,
    required this.child,
  });

  @override
  Size get preferredSize => const Size.fromHeight(112); // title + tabs

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Blur the content behind the header
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: const SizedBox(height: 96, width: double.infinity),
              ),
              // Hairline + soft shadow + subtle fill
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.06 : 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: glassBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.28 : 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBar(
                      title: Text(title),
                      centerTitle: true,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      toolbarHeight: 48,
                      // If you want a menu icon: leading: IconButton(...),
                    ),
                    // Tabs go here
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pro TabBar: pill indicator + animated icon/label + badges.
class _ProTabBar extends StatelessWidget {
  final List<String> labels;
  final List<(IconData, IconData)> icons;
  final Color iconBase;
  final Color active;
  final bool isDark;
  final int badgeIndex;
  final int badgeCount;

  const _ProTabBar({
    required this.labels,
    required this.icons,
    required this.iconBase,
    required this.active,
    required this.isDark,
    required this.badgeIndex,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(isDark ? 0.16 : 0.22),
            width: 1,
          ),
          color: Colors.white.withOpacity(isDark ? 0.05 : 0.08),
        ),
        child: TabBar(
          isScrollable: true,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          // pill indicator (subtle)
          indicator: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.primary.withOpacity(0.30),
              width: 1,
            ),
          ),
          // text colors are mostly managed by chip; keep defaults subtle
          labelColor: scheme.onSurface,
          unselectedLabelColor: scheme.onSurfaceVariant,

          tabs: List.generate(labels.length, (i) {
            final (un, sel) = icons[i];

            final chip = _AnimatedTabChip(
              index: i,
              label: labels[i],
              unselected: un,
              selected: sel,
              base: iconBase,
              active: active,
            );

            // Add badge to a single tab (Bookings or Tickets)
            if (i == badgeIndex && badgeCount > 0) {
              return Tab(
                child: Badge(
                  label: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
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
    );
  }
}

/// Animated chip: scales icon and tweens color based on TabController position.
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
    final controller = DefaultTabController.maybeOf(context);
    // Fallback when no controller (shouldn’t happen here)
    if (controller?.animation == null) {
      return _chip(0.0);
    }
    return AnimatedBuilder(
      animation: controller!.animation!,
      builder: (context, _) {
        final pos = controller.animation!.value;
        // selectedness: 1.0 when this tab is selected, 0.0 otherwise
        final t = (1.0 - (pos - index).abs()).clamp(0.0, 1.0);
        return _chip(t);
      },
    );
  }

  Widget _chip(double t) {
    final scale = 1.0 + 0.12 * t; // icon bump
    final iconData = t > 0.5 ? selected : unselected;
    final iconColor = Color.lerp(base, active, t)!;
    final textWeight = t > 0.5 ? FontWeight.w600 : FontWeight.w500;
    final textColor = Color.lerp(Colors.black.withOpacity(0.70), active, t)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontWeight: textWeight, color: textColor),
        ),
      ],
    );
  }
}
