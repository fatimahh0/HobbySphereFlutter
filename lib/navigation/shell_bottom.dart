// ===== Flutter 3.35.x =====
// Role-aware bottom shell with one BottomNavigationBar.
// - User tabs: Home, Explore, Community, Tickets, Profile
// - Business tabs: Home, Booking, Analytics, Activities, Profile
// NOTE: BusinessHomeScreen now needs token, businessId, onCreate.

import 'package:flutter/material.dart'; // core UI
import 'package:hobby_sphere/features/presentation/pages/Business/business_activities_screen.dart'; // activities tab
import 'package:hobby_sphere/features/presentation/pages/Business/business_analytics_screen.dart'; // analytics tab
import 'package:hobby_sphere/features/presentation/pages/Business/business_booking_screen.dart'; // booking tab
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/business_home_screen.dart'; // business home (needs params)
import 'package:hobby_sphere/features/presentation/pages/Business/business_profile_screen.dart'; // profile tab
import 'package:hobby_sphere/features/presentation/pages/User/user_community_screen.dart'; // user community tab
import 'package:hobby_sphere/features/presentation/pages/User/user_explore_screen.dart'; // user explore tab
import 'package:hobby_sphere/features/presentation/pages/User/user_home_screen.dart'; // user home tab
import 'package:hobby_sphere/features/presentation/pages/User/user_profile_screen.dart'; // user profile tab
import 'package:hobby_sphere/features/presentation/pages/User/user_tickets_screen.dart'; // user tickets tab
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import '../core/auth/app_role.dart'; // AppRole enum (user / business)

class ShellBottom extends StatefulWidget {
  final AppRole role; // current role (controls which tabs to show)
  final String token; // JWT token (needed by BusinessHomeScreen)
  final int businessId; // business id (needed by BusinessHomeScreen)

  const ShellBottom({
    super.key, // widget key
    required this.role, // pass current role
    required this.token, // pass JWT token
    required this.businessId, // pass business id
  });

  @override
  State<ShellBottom> createState() => _ShellBottomState(); // create state
}

class _ShellBottomState extends State<ShellBottom> {
  int _index = 0; // selected tab index

  // Build the pages list for a given role.
  // For business: inject token + businessId + onCreate into BusinessHomeScreen.
  List<Widget> _pagesFor(AppRole role) {
    if (role == AppRole.business) {
      return [
        // BUSINESS HOME (needs params)
        BusinessHomeScreen(
          token: widget.token, // pass JWT for API calls
          businessId: widget.businessId, // pass business id
          onCreate: () {
            // open create-activity screen (adjust route to your app)
            Navigator.pushNamed(
              context,
              '/business/activity/create', // your route name
            );
          }, // callback when "Create New Activity" pressed
          // bottomBar: DO NOT pass here, Shell already provides one bottom bar
        ),
        const BusinessBookingScreen(), // booking tab
        const BusinessAnalyticsScreen(), // analytics tab
        const BusinessActivitiesScreen(), // activities tab
        const BusinessProfileScreen(), // profile tab
      ];
    }

    // USER / GUEST tabs use the user stack
    return const [
      UserHomeScreen(), // home
      UserExploreScreen(), // explore
      UserCommunityScreen(), // community
      UserTicketsScreen(), // tickets
      UserProfileScreen(), // profile
    ];
  }

  // Labels using i18n keys from ARB.
  // Expected keys:
  // - tabHome, tabExplore, tabSocial (community), tabTickets, tabProfile
  // - tabBookings, tabAnalytics, tabActivities (business)
  List<String> _labelsFor(BuildContext context, AppRole role) {
    final t = AppLocalizations.of(context)!; // i18n accessor
    if (role == AppRole.business) {
      return [
        t.tabHome, // Home
        t.tabBookings, // Booking
        t.tabAnalytics, // Analytics
        t.tabActivities, // Activities
        t.tabProfile, // Profile
      ];
    }
    return [
      t.tabHome, // Home
      t.tabExplore, // Explore
      t.tabSocial, // Community
      t.tabTickets, // Tickets
      t.tabProfile, // Profile
    ];
  }

  // Icon pairs per item: (unselected, selected).
  List<(IconData, IconData)> _iconsFor(AppRole role) {
    if (role == AppRole.business) {
      return const [
        (Icons.home_outlined, Icons.home), // Home
        (Icons.event_available_outlined, Icons.event_available), // Booking
        (Icons.insights_outlined, Icons.insights), // Analytics
        (Icons.local_activity_outlined, Icons.local_activity), // Activities
        (Icons.person_outline, Icons.person), // Profile
      ];
    }
    return const [
      (Icons.home_outlined, Icons.home), // Home
      (Icons.search_outlined, Icons.search), // Explore
      (Icons.groups_outlined, Icons.groups), // Community
      (
        Icons.confirmation_number_outlined,
        Icons.confirmation_number,
      ), // Tickets
      (Icons.person_outline, Icons.person), // Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pagesFor(widget.role); // build pages for current role
    final labels = _labelsFor(context, widget.role); // tab labels
    final icons = _iconsFor(widget.role); // tab icons

    if (_index >= pages.length) {
      _index = pages.length - 1; // clamp index if role changed dynamically
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(labels[_index]), // current tab title
        centerTitle: true, // center title for a clean look
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200), // smooth fade
        child: pages[_index], // active tab page
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, // which tab is active
        onTap: (i) => setState(() => _index = i), // change tab
        type: BottomNavigationBarType.fixed, // fixed for 5 items
        showUnselectedLabels: true, // show labels for all items
        items: List.generate(labels.length, (i) {
          final (un, sel) = icons[i]; // get icon pair
          return BottomNavigationBarItem(
            icon: Icon(un), // unselected icon
            activeIcon: Icon(sel), // selected icon
            label: labels[i], // tab label
          );
        }),
      ),
    );
  }
}
