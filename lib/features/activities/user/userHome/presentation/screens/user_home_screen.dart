import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

// Sections
import 'package:hobby_sphere/features/activities/user/userHome/presentation/widgets/interest_section.dart';
import 'package:hobby_sphere/features/activities/user/userHome/presentation/widgets/explore_section.dart';
import 'package:hobby_sphere/features/activities/common/presentation/widgets/activity_types_section.dart';
import 'package:hobby_sphere/features/activities/common/presentation/screens/activity_types_all_screen.dart';
import 'package:hobby_sphere/features/activities/common/presentation/screens/activities_by_type_screen.dart';

// Usecases
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_interest_based_items.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

// Header
import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/home_header.dart';

class UserHomeScreen extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int unreadCount;

  final String token;
  final int userId;

  final GetInterestBasedItems getInterestBased;
  final GetUpcomingGuestItems getUpcomingGuest;
  final GetItemTypes getItemTypes;
  final GetItemsByType getItemsByType;

  /// Optional fallback currency (used until dynamic one arrives)
  final String? currencyFallback;

  /// Supply a future that returns the active currency (e.g. 'CAD')
  final Future<String?> Function()? getCurrencyCode;

  /// Base URL for images when API returns relative paths
  final String? imageBaseUrl;

  const UserHomeScreen({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.unreadCount = 0,
    required this.token,
    required this.userId,
    required this.getInterestBased,
    required this.getUpcomingGuest,
    required this.getItemTypes,
    required this.getItemsByType,
    this.currencyFallback,
    this.getCurrencyCode,
    this.imageBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Compact header (0 top space)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: HomeHeader(
                displayName: displayName,
                avatarUrl: avatarUrl,
                unreadCount: unreadCount,
                onBellTap: () {
                  // open notifications
                },
              ),
            ),

            // ==== Interest-based (auth only) ====
            if (token.trim().isNotEmpty && userId > 0)
              InterestSection(
                title: t.homeInterestBasedTitle,
                showAllLabel: t.homeSeeAll,
                usecase: getInterestBased,
                token: token,
                userId: userId,
                currencyCode: currencyFallback,
                getCurrencyCode: getCurrencyCode,
                imageBaseUrl: imageBaseUrl,
                onItemTap: (id) {
                  // open details(id)
                },
                onShowAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _AllInterestsPage(
                        getInterestBased: getInterestBased,
                        token: token,
                        userId: userId,
                        currencyFallback: currencyFallback,
                        getCurrencyCode: getCurrencyCode,
                        imageBaseUrl: imageBaseUrl,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 8),

            // ==== Categories ====
            ActivityTypesSection(
              getTypes: getItemTypes,
              token: token,
              onTypeTap: (id, name) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivitiesByTypeScreen(
                      typeId: id,
                      typeName: name,
                      getItemsByType: getItemsByType,
                      currencyCode: currencyFallback,
                    ),
                  ),
                );
              },
              onSeeAll: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityTypesAllScreen(
                      getTypes: getItemTypes,
                      token: token,
                      onTypeTap: (id, name) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActivitiesByTypeScreen(
                              typeId: id,
                              typeName: name,
                              getItemsByType: getItemsByType,
                              currencyCode: currencyFallback,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // ==== Explore (guest upcoming) ====
            ExploreSection(
              title: t.homeExploreActivities,
              showAllLabel: t.homeSeeAll,
              usecase: getUpcomingGuest,
              currencyCode: currencyFallback,
              getCurrencyCode: getCurrencyCode,
              imageBaseUrl: imageBaseUrl,
              onItemTap: (id) {
                // open details(id)
              },
              onShowAll: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _AllExplorePage(
                      getUpcomingGuest: getUpcomingGuest,
                      currencyFallback: currencyFallback,
                      getCurrencyCode: getCurrencyCode,
                      imageBaseUrl: imageBaseUrl,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== simple "Show All" pages =====

class _AllInterestsPage extends StatelessWidget {
  final GetInterestBasedItems getInterestBased;
  final String token;
  final int userId;

  final String? currencyFallback;
  final Future<String?> Function()? getCurrencyCode;
  final String? imageBaseUrl;

  const _AllInterestsPage({
    required this.getInterestBased,
    required this.token,
    required this.userId,
    this.currencyFallback,
    this.getCurrencyCode,
    this.imageBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.homeInterestBasedTitle)),
      body: InterestSection(
        title: t.homeInterestBasedTitle,
        showAllLabel: t.homeSeeAll,
        usecase: getInterestBased,
        token: token,
        userId: userId,
        currencyCode: currencyFallback,
        getCurrencyCode: getCurrencyCode,
        imageBaseUrl: imageBaseUrl,
      ),
    );
  }
}

class _AllExplorePage extends StatelessWidget {
  final GetUpcomingGuestItems getUpcomingGuest;

  final String? currencyFallback;
  final Future<String?> Function()? getCurrencyCode;
  final String? imageBaseUrl;

  const _AllExplorePage({
    required this.getUpcomingGuest,
    this.currencyFallback,
    this.getCurrencyCode,
    this.imageBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.homeExploreActivities)),
      body: ExploreSection(
        title: t.homeExploreActivities,
        showAllLabel: t.homeSeeAll,
        usecase: getUpcomingGuest,
        currencyCode: currencyFallback,
        getCurrencyCode: getCurrencyCode,
        imageBaseUrl: imageBaseUrl,
      ),
    );
  }
}
