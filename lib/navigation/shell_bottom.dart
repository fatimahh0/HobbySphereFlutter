// ===== Flutter 3.35.x =====
// ShellBottom — glassy transparent bottom bar + fixed animation.
// - extendBody: true so the page draws under the bar (no white slab).
// - BackdropFilter blur + low opacity fill (real glass).
// - Animated selected icons (scale + soft glow).
// - Badges kept, i18n kept, role-aware pages kept.

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_profile_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_tickets_screen.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../core/constants/app_role.dart';

class ShellBottom extends StatefulWidget {
  final AppRole role;
  final String token;
  final int businessId;

  final int bookingsBadge;
  final int ticketsBadge;

  const ShellBottom({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  @override
  State<ShellBottom> createState() => _ShellBottomState();
}

class _ShellBottomState extends State<ShellBottom> {
  int _index = 0;

  late final List<Widget> _userPages = const [
    UserHomeScreen(),
    UserExploreScreen(),
    UserCommunityScreen(),
    UserTicketsScreen(),
    UserProfileScreen(),
  ];

  late final List<Widget> _businessPages = <Widget>[
    BusinessHomeScreen(
      token: widget.token,
      businessId: widget.businessId,
      onCreate: () => Navigator.pushNamed(context, '/business/activity/create'),
    ),
    const BusinessBookingScreen(),
    const BusinessAnalyticsScreen(),
    const BusinessActivitiesScreen(),
    const BusinessProfileScreen(),
  ];

  List<Widget> _pagesFor(AppRole role) =>
      role == AppRole.business ? _businessPages : _userPages;

  List<String> _labelsFor(BuildContext context, AppRole role) {
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

  List<(IconData, IconData)> _iconsFor(AppRole role) {
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

  @override
  Widget build(BuildContext context) {
    // Make Android's system nav bar transparent as well.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final pages = _pagesFor(widget.role);
    final labels = _labelsFor(context, widget.role);
    final icons = _iconsFor(widget.role);

    if (_index >= pages.length) _index = pages.length - 1;

    final badgeIndex = widget.role == AppRole.business ? 1 : 3;
    final badgeCount = widget.role == AppRole.business
        ? widget.bookingsBadge
        : widget.ticketsBadge;

    // Glass tones (adaptive)
    final glassFill = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.12);
    final glassBorder = isDark
        ? Colors.white.withOpacity(0.18)
        : Colors.white.withOpacity(0.25);
    final iconBase = isDark
        ? Colors.white.withOpacity(0.88)
        : Colors.black.withOpacity(0.70);

    return Scaffold(
      // KEY: body extends behind bottom bar -> no white background slab
      extendBody: false,

      appBar: AppBar(
        title: Text(labels[_index]),
        centerTitle: true,
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
      ),

      // Preserve page state when switching tabs
      body: IndexedStack(index: _index, children: pages),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.hardEdge, // no bleed
            child: SizedBox(
              // match the bar height exactly
              height: 64, // NavigationBar height
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // real transparency: blur the backdrop, no color fill here
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: const SizedBox.expand(),
                  ),

                  // border + faint shadow only (no white/grey background)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.transparent, // <--- transparent
                      border: Border.all(
                        color: Colors.white.withOpacity(0.22), // hairline
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10), // soft lift
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      // ensure no extra Material color
                      type: MaterialType.transparency,
                      child: NavigationBar(
                        height: 64,
                        elevation: 0,
                        backgroundColor: Colors.transparent, // keep transparent
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysShow,
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.10), // subtle pill
                        indicatorShape: const StadiumBorder(),

                        selectedIndex: _index,
                        onDestinationSelected: (i) {
                          if (i == _index) return;
                          HapticFeedback.selectionClick();
                          setState(() => _index = i);
                        },

                        destinations: List.generate(
                          _labelsFor(context, widget.role).length,
                          (i) {
                            final (un, sel) = _iconsFor(widget.role)[i];
                            final withBadge =
                                (widget.role == AppRole.business ? 1 : 3) ==
                                    i &&
                                (widget.role == AppRole.business
                                        ? widget.bookingsBadge
                                        : widget.ticketsBadge) >
                                    0;

                            final icon = _AnimatedNavIcon(
                              unselected: un,
                              selected: sel,
                              isSelected: _index == i,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.88)
                                  : Colors.black.withOpacity(0.70),
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            );

                            final wrapped = withBadge
                                ? Badge(
                                    label: Text(
                                      (widget.role == AppRole.business
                                                  ? widget.bookingsBadge
                                                  : widget.ticketsBadge) >
                                              99
                                          ? '99+'
                                          : '${widget.role == AppRole.business ? widget.bookingsBadge : widget.ticketsBadge}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: icon,
                                  )
                                : icon;

                            return NavigationDestination(
                              icon: wrapped,
                              selectedIcon:
                                  wrapped, // animation is inside the widget
                              label: _labelsFor(context, widget.role)[i],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiny, tasteful selected animation (scale + soft glow).
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
    const duration = Duration(milliseconds: 220);
    const curve = Curves.easeOutCubic;

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      builder: (context, t, _) {
        final scale = 1.0 + 0.10 * t; // +10%
        final iconData = t > 0.5 ? selected : unselected;
        final Color iconColor = Color.lerp(color, activeColor, t)!;

        return Stack(
          alignment: Alignment.center,
          children: [
            // subtle glow when selected
            if (t > 0)
              Opacity(
                opacity: 0.28 * t,
                child: Container(
                  width: 34 + 6 * t,
                  height: 34 + 6 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.55 * t),
                        blurRadius: 16 + 12 * t,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            Transform.scale(
              scale: scale,
              child: Icon(iconData, color: iconColor, size: 26),
            ),
          ],
        );
      },
    );
  }
}
