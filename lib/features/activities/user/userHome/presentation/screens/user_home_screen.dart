// Flutter 3.35.x — Guest-safe: no unread cubit in guest, bell disabled in guest.
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/services/user_notification_service.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/presentation/bloc/user_unread_cubit.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root

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
  // header name pieces (never username)
  final String? firstName; // first name
  final String? lastName; // last name

  final String? avatarUrl; // avatar url
  final int unreadCount; // optional initial

  final String token; // auth token
  final int userId; // user id

  final GetInterestBasedItems getInterestBased; // UC interest
  final GetUpcomingGuestItems getUpcomingGuest; // UC explore
  final GetItemTypes getItemTypes; // UC types
  final GetItemsByType getItemsByType; // UC by type

  final String? currencyFallback; // fallback code
  final Future<String?> Function()? getCurrencyCode; // currency getter

  const UserHomeScreen({
    super.key,
    this.firstName,
    this.lastName,
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
    final base = (g.appServerRoot ?? ''); // read base
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // strip /api
  }

  // navigate to activity details (safe for guest)
  void _goToDetails(BuildContext context, int itemId, String imageBaseUrl) {
    final bearer =
        token
            .trim()
            .isEmpty // if guest
        ? '' // no token
        : (token.startsWith('Bearer ')
              ? token
              : 'Bearer $token'); // ensure prefix

    Navigator.of(context).pushNamed(
      // push route
      Routes.userActivityDetail, // name
      arguments: UserActivityDetailRouteArgs(
        // args bag
        itemId: itemId, // id
        token: bearer.isNotEmpty ? bearer : null, // null for guest
        currencyCode: currencyFallback, // currency
        imageBaseUrl: imageBaseUrl, // absolute imgs
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n
    final serverRoot = _serverRoot(); // base url

    // detect guest mode once
    final bool isGuest = token.trim().isEmpty || userId <= 0; // guest?

    // currency getter (catch errors; use fallback)
    final getCurrencyCodeFn =
        getCurrencyCode ??
        (() async {
          try {
            final usecase = GetCurrentCurrency(
              // UC
              CurrencyRepositoryImpl(CurrencyService()),
            );
            final cur = await usecase(token); // may use ''
            return cur.code; // e.g. "USD"
          } catch (_) {
            return currencyFallback; // fallback
          }
        });

    // ---------- header builder: guest vs logged-in ----------
    Widget _buildHeader(BuildContext ctx, {int liveUnread = 0}) {
      // if guest: disable bell (no onTap) to avoid navigating/APIs
      if (isGuest) {
        return HomeHeader(
          firstName: null, // hide name
          lastName: null, // hide
          avatarUrl: null, // no avatar
          unreadCount: 0, // no count
          margin: EdgeInsets.zero, // layout
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8), // padding
          radius: 10, // radius
          onBellTap: null, // ← disabled
        );
      }

      // logged-in: show live unread + navigate to notifications
      return HomeHeader(
        firstName: firstName, // show name
        lastName: lastName, // show name
        avatarUrl: avatarUrl, // avatar
        unreadCount: liveUnread, // live count
        margin: EdgeInsets.zero, // layout
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8), // padding
        radius: 10, // radius
        onBellTap: () {
          Navigator.of(ctx)
              .pushNamed(
                Routes.userNotifications, // notifications
                arguments: UserNotificationsRouteArgs(token: token),
              )
              .then((_) {
                // refresh when returning (only if cubit exists)
                final cubit = ctx.read<UserUnreadNotificationsCubit>();
                cubit.refresh();
              });
        },
      );
    }

    // ---------- body content: shared for both states ----------
    Widget _buildContent(BuildContext ctx, {int liveUnread = 0}) {
      return ListView(
        padding: EdgeInsets.zero, // no outer pad
        children: [
          _buildHeader(ctx, liveUnread: liveUnread), // header

          const Divider(height: 1), // thin line
          // ==== Interest-based (HOME: 4) - only when logged-in ====
          if (!isGuest)
            InterestSection(
              title: t.homeInterestBasedTitle, // title
              showAllLabel: t.homeSeeAll, // see all
              usecase: getInterestBased, // UC
              token: token, // token
              userId: userId, // id
              currencyCode: currencyFallback, // fallback
              getCurrencyCode: getCurrencyCodeFn, // getter
              imageBaseUrl: serverRoot, // absolute imgs
              maxItems: 4, // limit
              standalone: false, // in home
              onItemTap: (id) {}, // your nav
              onShowAll: () {
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => _AllInterestsPage(
                      // see-all
                      getInterestBased: getInterestBased, // UC
                      token: token, // token
                      userId: userId, // id
                      currencyFallback: currencyFallback, // fallback
                      getCurrencyCode: getCurrencyCodeFn, // getter
                      imageBaseUrl: serverRoot, // imgs
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 6), // gap
          // ==== Categories (works for guest) ====
          ActivityTypesSection(
            getTypes: getItemTypes, // UC
            getItemsByType: getItemsByType, // UC
            token: token, // '' ok if API allows
            onlyWithActivities: true, // filter
            onTypeTap: (id, name) {
              // open list
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ActivitiesByTypeScreen(
                    typeId: id, // id
                    typeName: name, // name
                    getItemsByType: getItemsByType, // UC
                    currencyCode: currencyFallback, // fallback
                    getCurrencyCode: getCurrencyCodeFn, // getter
                    imageBaseUrl: serverRoot, // imgs
                  ),
                ),
              );
            },
            onSeeAll: () {
              // all types
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ActivityTypesAllScreen(
                    getTypes: getItemTypes, // UC
                    getItemsByType: getItemsByType, // UC
                    token: token, // token/guest
                    onTypeTap: (id, name) {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => ActivitiesByTypeScreen(
                            typeId: id, // id
                            typeName: name, // name
                            getItemsByType: getItemsByType, // UC
                            currencyCode: currencyFallback, // fallback
                            imageBaseUrl: serverRoot, // imgs
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 6), // gap
          // ==== Explore (HOME: 6) - works for guest ====
          ExploreSection(
            title: t.homeExploreActivities, // title
            showAllLabel: t.homeSeeAll, // see all
            usecase: getUpcomingGuest, // UC
            currencyCode: currencyFallback, // fallback
            getCurrencyCode: getCurrencyCodeFn, // getter
            imageBaseUrl: serverRoot, // imgs
            maxItems: 6, // limit
            standalone: false, // in home
            onItemTap: (id) {}, // your nav
            onShowAll: () {
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => _AllExplorePage(
                    // see-all
                    getUpcomingGuest: getUpcomingGuest, // UC
                    currencyFallback: currencyFallback, // fallback
                    getCurrencyCode: getCurrencyCodeFn, // getter
                    imageBaseUrl: serverRoot, // imgs
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16), // bottom gap
        ],
      );
    }

    // ---------- return: guest vs logged-in wrappers ----------
    if (isGuest) {
      // guest mode: NO BlocProvider (prevents unread API + Dio 401)
      return Scaffold(
        body: SafeArea(
          top: true,
          bottom: false, // insets
          child: _buildContent(context), // content
        ),
      );
    }

    // logged-in: provide unread cubit and stream count to header
    return BlocProvider<UserUnreadNotificationsCubit>(
      create: (_) {
        final repo = UserNotificationRepositoryImpl(
          UserNotificationService(),
        ); // repo
        final cubit = UserUnreadNotificationsCubit(
          repo: repo,
          token: token,
        ); // cubit
        cubit.refresh(); // initial fetch
        return cubit; // provide
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false, // insets
          child: BlocBuilder<UserUnreadNotificationsCubit, UserUnreadState>(
            builder: (ctx, s) =>
                _buildContent(ctx, liveUnread: s.count), // header count
          ),
        ),
      ),
    );
  }
}

// ===== SEE-ALL pages with your AppSearchAppBar (unchanged) =====
class _AllInterestsPage extends StatefulWidget {
  final GetInterestBasedItems getInterestBased; // UC
  final String token; // token
  final int userId; // id
  final String? currencyFallback; // fallback
  final Future<String?> Function()? getCurrencyCode; // getter
  final String? imageBaseUrl; // imgs base

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
  String _query = ''; // search

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n

    return Scaffold(
      appBar: AppSearchAppBar(
        // search bar
        hint: t.searchPlaceholder, // hint
        initialQuery: _query, // initial
        onQueryChanged: (q) => setState(() => _query = q.trim()), // update
        onClear: () => setState(() => _query = ''), // clear
        debounceMs: 250, // debounce
        showBack: true, // back btn
      ),
      body: InterestSection(
        // list
        title: t.homeInterestBasedTitle, // title
        usecase: widget.getInterestBased, // UC
        token: widget.token, // token
        userId: widget.userId, // id
        currencyCode: widget.currencyFallback, // fallback
        getCurrencyCode: widget.getCurrencyCode, // getter
        imageBaseUrl: widget.imageBaseUrl, // imgs base
        maxItems: null, // all
        searchQuery: _query, // filter
        standalone: true, // full page
        onShowAll: null, // hide see-all
      ),
    );
  }
}

class _AllExplorePage extends StatefulWidget {
  final GetUpcomingGuestItems getUpcomingGuest; // UC
  final String? currencyFallback; // fallback
  final Future<String?> Function()? getCurrencyCode; // getter
  final String? imageBaseUrl; // imgs base

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
  String _query = ''; // search

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n

    return Scaffold(
      appBar: AppSearchAppBar(
        // search bar
        hint: t.searchPlaceholder, // hint
        initialQuery: _query, // initial
        onQueryChanged: (q) => setState(() => _query = q.trim()), // update
        onClear: () => setState(() => _query = ''), // clear
        debounceMs: 250, // debounce
        showBack: true, // back btn
      ),
      body: ExploreSection(
        // list
        title: t.homeExploreActivities, // title
        usecase: widget.getUpcomingGuest, // UC
        currencyCode: widget.currencyFallback, // fallback
        getCurrencyCode: widget.getCurrencyCode, // getter
        imageBaseUrl: widget.imageBaseUrl, // imgs base
        maxItems: null, // all
        searchQuery: _query, // filter
        standalone: true, // full page
        onShowAll: null, // hide see-all
      ),
    );
  }
}
