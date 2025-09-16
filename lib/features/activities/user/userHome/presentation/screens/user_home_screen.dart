// Flutter 3.35.x — Tight header, dynamic currency (with fallback), absolute image URLs.
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

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
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';

// Data layer for currency
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';

// Header
import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/home_header.dart';

// Your search bar
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';

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

  /// Optional fallback currency code if [getCurrencyCode] is null or pending.
  final String? currencyFallback;

  /// Provide a future that returns the active currency (e.g. 'CAD', 'USD', ...).
  final Future<String?> Function()? getCurrencyCode;

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
  });

  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final serverRoot = _serverRoot();

    final getCurrencyCodeFn =
        getCurrencyCode ??
        (() async {
          final usecase = GetCurrentCurrency(
            CurrencyRepositoryImpl(CurrencyService()),
          );
          final cur = await usecase(token);
          return cur.code; // e.g. "CAD"
        });

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HomeHeader(
              displayName: displayName,
              avatarUrl: avatarUrl,
              unreadCount: unreadCount,
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              radius: 10,
              onBellTap: () {},
            ),
            const Divider(height: 1),

            // ==== Interest-based (HOME: 4) ====
            if (token.trim().isNotEmpty && userId > 0)
              InterestSection(
                title: t.homeInterestBasedTitle,
                showAllLabel: t.homeSeeAll,
                usecase: getInterestBased,
                token: token,
                userId: userId,
                currencyCode: currencyFallback,
                getCurrencyCode: getCurrencyCodeFn,
                imageBaseUrl: serverRoot,
                maxItems: 4, // unchanged
                standalone: false, // unchanged
                onItemTap: (id) {},
                onShowAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _AllInterestsPage(
                        getInterestBased: getInterestBased,
                        token: token,
                        userId: userId,
                        currencyFallback: currencyFallback,
                        getCurrencyCode: getCurrencyCodeFn,
                        imageBaseUrl: serverRoot,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 6),

            // ==== Categories ====
            // in UserHomeScreen -> build()
            // In UserHomeScreen -> build()
            ActivityTypesSection(
              getTypes: getItemTypes,
              getItemsByType: getItemsByType, // <— add this
              token: token,
              onlyWithActivities: true, // <— show only types that have items
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
                      getItemsByType: getItemsByType, // <— add this
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

            const SizedBox(height: 6),

            // ==== Explore (HOME: 6) ====
            ExploreSection(
              title: t.homeExploreActivities,
              showAllLabel: t.homeSeeAll,
              usecase: getUpcomingGuest,
              currencyCode: currencyFallback,
              getCurrencyCode: getCurrencyCodeFn,
              imageBaseUrl: serverRoot,
              maxItems: 6, // unchanged
              standalone: false, // unchanged
              onItemTap: (id) {},
              onShowAll: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _AllExplorePage(
                      getUpcomingGuest: getUpcomingGuest,
                      currencyFallback: currencyFallback,
                      getCurrencyCode: getCurrencyCodeFn,
                      imageBaseUrl: serverRoot,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ===== SEE-ALL pages with your AppSearchAppBar =====

class _AllInterestsPage extends StatefulWidget {
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
  State<_AllInterestsPage> createState() => _AllInterestsPageState();
}

class _AllInterestsPageState extends State<_AllInterestsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppSearchAppBar(
        hint: t.searchPlaceholder,
        initialQuery: _query,
        onQueryChanged: (q) => setState(() => _query = q.trim()),
        onClear: () => setState(() => _query = ''),
        debounceMs: 250,
        showBack: true,
      ),
      body: InterestSection(
        title: t.homeInterestBasedTitle,
        usecase: widget.getInterestBased,
        token: widget.token,
        userId: widget.userId,
        currencyCode: widget.currencyFallback,
        getCurrencyCode: widget.getCurrencyCode,
        imageBaseUrl: widget.imageBaseUrl,
        maxItems: null, // show ALL
        searchQuery: _query, // local filter
        standalone: true, // makes it scrollable
        onShowAll: null,
      ),
    );
  }
}

class _AllExplorePage extends StatefulWidget {
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
  State<_AllExplorePage> createState() => _AllExplorePageState();
}

class _AllExplorePageState extends State<_AllExplorePage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppSearchAppBar(
        hint: t.searchPlaceholder,
        initialQuery: _query,
        onQueryChanged: (q) => setState(() => _query = q.trim()),
        onClear: () => setState(() => _query = ''),
        debounceMs: 250,
        showBack: true,
      ),
      body: ExploreSection(
        title: t.homeExploreActivities,
        usecase: widget.getUpcomingGuest,
        currencyCode: widget.currencyFallback,
        getCurrencyCode: widget.getCurrencyCode,
        imageBaseUrl: widget.imageBaseUrl,
        maxItems: null, // show ALL
        searchQuery: _query, // local filter
        standalone: true, // makes it scrollable
        onShowAll: null,
      ),
    );
  }
}
