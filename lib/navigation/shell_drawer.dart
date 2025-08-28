// ===== Flutter 3.35.x =====
// Drawer (sandwich) role-aware menus.
// - Business: Home, Booking, Analytics, Activities, Profile
// - User:     Home, Explore, Community, Tickets, Profile
// NOTE: BusinessHomeScreen REQUIRES token + businessId + onCreate.

import 'package:flutter/material.dart'; // core UI
import 'package:hobby_sphere/features/presentation/pages/Business/business_activities_screen.dart'; // activities page
import 'package:hobby_sphere/features/presentation/pages/Business/business_analytics_screen.dart'; // analytics page
import 'package:hobby_sphere/features/presentation/pages/Business/business_booking_screen.dart'; // booking page
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/business_home_screen.dart'; // business home (needs params)
import 'package:hobby_sphere/features/presentation/pages/Business/business_profile_screen.dart'; // business profile
import 'package:hobby_sphere/features/presentation/pages/User/user_community_screen.dart'; // community
import 'package:hobby_sphere/features/presentation/pages/User/user_explore_screen.dart'; // explore
import 'package:hobby_sphere/features/presentation/pages/User/user_home_screen.dart'; // user home
import 'package:hobby_sphere/features/presentation/pages/User/user_profile_screen.dart'; // user profile
import 'package:hobby_sphere/features/presentation/pages/User/user_tickets_screen.dart'; // user tickets
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

import '../core/auth/app_role.dart'; // AppRole enum

class ShellDrawer extends StatefulWidget {
  final AppRole role; // current role (user or business)
  final String token; // JWT token for API calls (business home needs it)
  final int businessId; // current business id (business home needs it)

  const ShellDrawer({
    super.key, // widget key
    required this.role, // pass role
    required this.token, // pass token
    required this.businessId, // pass id
  });

  @override
  State<ShellDrawer> createState() => _ShellDrawerState(); // state
}

class _ShellDrawerState extends State<ShellDrawer> {
  int _index = 0; // which center page is visible now

  // Build the role-aware menu entries (title + icon + page).
  // For business home we inject token, businessId, and onCreate.
  List<({String title, IconData icon, Widget page})> _menu(
    BuildContext context,
  ) {
    final t = AppLocalizations.of(context)!; // i18n accessor

    if (widget.role == AppRole.business) {
      // business menu
      return [
        (
          title: t.tabHome, // "Home"
          icon: Icons.home, // home icon
          page: BusinessHomeScreen(
            token: widget.token, // pass JWT
            businessId: widget.businessId, // pass business id
            onCreate: () {
              // navigate to create-activity screen
              Navigator.pushNamed(
                context,
                '/business/activity/create',
              ); // route
            }, // callback
            // bottomBar: not used here (drawer already provides shell chrome)
          ),
        ),
        (
          title: t.tabBookings, // "Bookings"
          icon: Icons.event_available, // bookings icon
          page: const BusinessBookingScreen(), // simple page
        ),
        (
          title: t.tabAnalytics, // "Analytics"
          icon: Icons.insights, // analytics icon
          page: const BusinessAnalyticsScreen(), // simple page
        ),
        (
          title: t.tabActivities, // "Activities"
          icon: Icons.local_activity, // activities icon
          page: const BusinessActivitiesScreen(), // simple page
        ),
        (
          title: t.tabProfile, // "Profile"
          icon: Icons.person, // profile icon
          page: const BusinessProfileScreen(), // simple page
        ),
      ];
    }

    // user / guest menu
    return [
      (
        title: t.tabHome, // "Home"
        icon: Icons.home, // icon
        page: const UserHomeScreen(), // user home
      ),
      (
        title: t.tabExplore, // "Explore"
        icon: Icons.search, // icon
        page: const UserExploreScreen(), // explore
      ),
      (
        title: t.tabSocial, // "Community"
        icon: Icons.groups, // icon
        page: const UserCommunityScreen(), // community
      ),
      (
        title: t.tabTickets, // "Tickets"
        icon: Icons.confirmation_number, // icon
        page: const UserTicketsScreen(), // tickets
      ),
      (
        title: t.tabProfile, // "Profile"
        icon: Icons.person, // icon
        page: const UserProfileScreen(), // profile
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final menu = _menu(context); // build menu items
    if (_index >= menu.length) _index = menu.length - 1; // clamp index

    return Scaffold(
      appBar: AppBar(
        title: Text(menu[_index].title), // title of current page
        centerTitle: true, // centered title
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero, // remove default padding
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary, // brand bg
                ),
                child: Align(
                  alignment: Alignment.bottomLeft, // bottom-left text
                  child: Text(
                    'Hobby Sphere', // app name (you can i18n if needed)
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary, // contrast
                    ),
                  ),
                ),
              ),
              // entries
              for (var i = 0; i < menu.length; i++)
                ListTile(
                  leading: Icon(menu[i].icon), // leading icon
                  title: Text(menu[i].title), // label
                  selected: _index == i, // highlight selected
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    setState(() => _index = i); // switch page
                  },
                ),
              const Divider(), // separator line
              ListTile(
                leading: const Icon(Icons.settings), // settings icon
                title: Text(AppLocalizations.of(context)!.tabSettings), // i18n
                onTap: () {
                  Navigator.pop(context); // close drawer
                  // TODO: push settings route if you have one
                  // Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200), // small fade
        child: menu[_index].page, // show active center page
      ),
    );
  }
}
