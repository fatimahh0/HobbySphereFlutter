// ===== Flutter 3.35.x =====
// ShellDrawer — glassmorphism + animated selection + badges.
// Fixed: onCreate must be a non-null VoidCallback → using () {} (no-op).

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hobby_sphere/features/activities/Business/presentation/BusinessHomeScreen/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/presentation/business_booking_screen.dart';
import 'package:hobby_sphere/features/activities/Business/presentation/business_analytics_screen.dart';
import 'package:hobby_sphere/features/activities/Business/presentation/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/Business/presentation/business_profile_screen.dart';

import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_profile_screen.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../core/constants/app_role.dart';

class ShellDrawer extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;

  /// Optional badges (match bottom bar).
  final int bookingsBadge; // Business only
  final int ticketsBadge; // User only

  const ShellDrawer({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  @override
  State<ShellDrawer> createState() => _ShellDrawerState();
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0;

  late final List<Widget> _userPages = const [
    UserHomeScreen(),
    UserExploreScreen(),
    UserCommunityScreen(),
    UserTicketsScreen(),
    UserProfileScreen(),
  ];

  // 🔧 FIX: pass a non-null VoidCallback (no-op) to onCreate
  late final List<Widget> _businessPages = <Widget>[
    BusinessHomeScreen(
      token: widget.token,
      businessId: widget.businessId,
      onCreate: () {}, // <-- no-op instead of null (fixes your error)
    ),
    const BusinessBookingScreen(),
    const BusinessAnalyticsScreen(),
    const BusinessActivitiesScreen(),
    const BusinessProfileScreen(),
  ];

  List<({String title, IconData icon, Widget page, int? badge})> _menu(
    BuildContext context,
  ) {
    final t = AppLocalizations.of(context)!;
    if (widget.role == AppRole.business) {
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
    // Make Android's system nav bar solid to match the drawer
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    final scheme = Theme.of(context).colorScheme;
    final menu = _menu(context);
    if (_index >= menu.length) _index = menu.length - 1;

    return Scaffold(
      extendBody: false,
      // scrim can stay semi-transparent; it dims page behind the drawer, not the drawer itself
      drawerScrimColor: Colors.black.withOpacity(0.35),

      appBar: AppBar(
        title: Text(menu[_index].title),
        centerTitle: true,
        // solid app bar — no accidental glass tints
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // keep page states
      body: IndexedStack(
        index: _index,
        children: menu.map((m) => m.page).toList(),
      ),

      // >>> SOLID DRAWER (no transparency, no blur) <<<
      drawer: Drawer(
        width: 304,
        backgroundColor: scheme.surface, // ✅ solid background
        shape: const RoundedRectangleBorder(
          // nice rounded right edge
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
    final name = 'Hobby Sphere';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // header
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
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
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

        // items
        ...List.generate(items.length, (i) {
          final it = items[i];
          final selected = i == index;
          return _AnimatedDrawerTile(
            icon: it.icon,
            label: it.title,
            selected: selected,
            onTap: () => onTap(i),
            iconBaseColor: iconBaseColor,
            activeColor: activeColor,
            badge: it.badge,
          );
        }),

        const Divider(height: 1),

        // settings
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
                if (t > 0)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.45 * t),
                          blurRadius: 16 * t,
                        ),
                      ],
                    ),
                  ),
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
