// ===== Flutter 3.35.x =====
// Top Tabs shell (role-aware):
// - User tabs:     Home, Explore, Community, Tickets, Profile
// - Business tabs: Home, Booking, Analytics, Activities, Profile
// NOTE: BusinessHomeScreen needs token + businessId + onCreate.

import 'package:flutter/material.dart'; // core UI
import 'package:hobby_sphere/features/presentation/pages/Business/business_activities_screen.dart'; // activities page
import 'package:hobby_sphere/features/presentation/pages/Business/business_analytics_screen.dart'; // analytics page
import 'package:hobby_sphere/features/presentation/pages/Business/business_booking_screen.dart'; // booking page
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/business_home_screen.dart'; // business home (needs params)
import 'package:hobby_sphere/features/presentation/pages/Business/business_profile_screen.dart'; // business profile
import 'package:hobby_sphere/features/presentation/pages/User/user_community_screen.dart'; // user community
import 'package:hobby_sphere/features/presentation/pages/User/user_explore_screen.dart'; // user explore
import 'package:hobby_sphere/features/presentation/pages/User/user_home_screen.dart'; // user home
import 'package:hobby_sphere/features/presentation/pages/User/user_profile_screen.dart'; // user profile
import 'package:hobby_sphere/features/presentation/pages/User/user_tickets_screen.dart'; // user tickets
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import '../core/auth/app_role.dart'; // role enum

class ShellTop extends StatelessWidget {
  final AppRole role; // current role (user/business/guest)
  final String token; // JWT token (BusinessHomeScreen needs it)
  final int businessId; // business id (BusinessHomeScreen needs it)

  const ShellTop({
    super.key, // widget key
    required this.role, // pass role
    required this.token, // pass token
    required this.businessId, // pass business id
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n accessor
    final scheme = Theme.of(context).colorScheme; // theme colors

    // ----- tabs & views depend on role -----
    late final List<Tab> tabs; // top tab headers
    late final List<Widget> views; // tab pages (bodies)

    if (role == AppRole.business) {
      // ===== BUSINESS SET =====
      tabs = [
        Tab(text: t.tabHome), // Home
        Tab(text: t.tabBookings), // Booking
        Tab(text: t.tabAnalytics), // Analytics
        Tab(text: t.tabActivities), // Activities
        Tab(text: t.tabProfile), // Profile
      ];

      views = [
        // Home needs token + businessId + onCreate
        BusinessHomeScreen(
          token: token, // pass JWT for API calls
          businessId: businessId, // pass current business id
          onCreate: () {
            // navigate to create-activity screen
            Navigator.pushNamed(context, '/business/activity/create'); // route
          }, // create handler
        ),
        const BusinessBookingScreen(), // Booking page
        const BusinessAnalyticsScreen(), // Analytics page
        const BusinessActivitiesScreen(), // Activities page
        const BusinessProfileScreen(), // Profile page
      ];
    } else {
      // ===== USER/GUEST SET =====
      tabs = [
        Tab(text: t.tabHome), // Home
        Tab(text: t.tabExplore), // Explore
        Tab(text: t.tabSocial), // Community
        Tab(text: t.tabTickets), // Tickets
        Tab(text: t.tabProfile), // Profile
      ];

      views = const [
        UserHomeScreen(), // Home page
        UserExploreScreen(), // Explore page
        UserCommunityScreen(), // Community page
        UserTicketsScreen(), // Tickets page
        UserProfileScreen(), // Profile page
      ];
    }

    return DefaultTabController(
      length: tabs.length, // number of tabs
      child: Scaffold(
        backgroundColor: scheme.background, // themed background
        appBar: AppBar(
          title: const Text('Hobby Sphere'), // app title (you can i18n later)
          centerTitle: true, // centered title
          bottom: TabBar(
            isScrollable: true, // allow horizontal scroll if many tabs
            tabs: tabs, // role-based tab headers
          ), // top tab bar
        ),
        body: TabBarView(
          children: views, // role-based pages
        ), // swipeable pages
      ),
    );
  }
}
