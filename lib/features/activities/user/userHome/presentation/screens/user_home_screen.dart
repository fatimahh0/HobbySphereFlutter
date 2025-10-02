// lib/features/activities/user/userHome/presentation/screens/user_home_screen.dart
// Flutter 3.35.x — Guest-safe: no unread cubit in guest, bell disabled in guest.
import 'package:flutter/foundation.dart'; // kDebugMode + debugPrint
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/services/user_notification_service.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/presentation/bloc/user_unread_cubit.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/data/repositories/user_profile_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userProfile/data/services/user_profile_service.dart'
    as svc;
import 'package:hobby_sphere/features/activities/user/userProfile/domain/usecases/get_user_profile.dart';
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

  final String? avatarUrl; // avatar url (absolute or relative)
  final int unreadCount; // optional initial

  final String token; // auth token
  final int userId; // user id

  final GetInterestBasedItems getInterestBased; // UC interest
  final GetUpcomingGuestItems getUpcomingGuest; // UC explore
  final GetItemTypes getItemTypes; // UC types
  final GetItemsByType getItemsByType; // UC by type

  final String? currencyFallback; // fallback code (e.g., "USD")
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
    final root = base.replaceFirst(RegExp(r'/api/?$'), ''); // strip /api
    if (kDebugMode) {
      debugPrint(
        '[UserHomeScreen] appServerRoot="${g.appServerRoot}" -> serverRoot="$root"',
      );
    }
    return root;
  }

  // navigate to activity details (safe for guest)
  void _goToDetails(BuildContext context, int itemId, String imageBaseUrl) {
    final bearer = token.trim().isEmpty
        ? ''
        : (token.startsWith('Bearer ') ? token : 'Bearer $token');

    if (kDebugMode) {
      debugPrint(
        '[UserHomeScreen] _goToDetails itemId=$itemId imageBaseUrl="$imageBaseUrl" '
        'guest=${bearer.isEmpty}',
      );
    }

    Navigator.of(context).pushNamed(
      Routes.userActivityDetail,
      arguments: UserActivityDetailRouteArgs(
        itemId: itemId,
        token: bearer.isNotEmpty ? bearer : null,
        currencyCode: currencyFallback,
        imageBaseUrl: imageBaseUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n
    final serverRoot = _serverRoot(); // base url

    final bool isGuest = token.trim().isEmpty || userId <= 0; // guest?

    if (kDebugMode) {
      debugPrint(
        '[UserHomeScreen] build: '
        'isGuest=$isGuest '
        'userId=$userId '
        'firstName="$firstName" lastName="$lastName" '
        'avatarUrl="$avatarUrl"',
      );
    }

    // currency getter (catch errors; use fallback)
    final getCurrencyCodeFn =
        getCurrencyCode ??
        (() async {
          try {
            final usecase = GetCurrentCurrency(
              CurrencyRepositoryImpl(CurrencyService()),
            );
            final cur = await usecase(token);
            if (kDebugMode) {
              debugPrint('[UserHomeScreen] getCurrencyCode -> ${cur.code}');
            }
            return cur.code;
          } catch (e, st) {
            if (kDebugMode) {
              debugPrint('[UserHomeScreen] getCurrencyCode ERROR: $e\n$st');
            }
            return currencyFallback;
          }
        });

    // ---------- header builder: guest vs logged-in ----------
    Widget _buildHeader(BuildContext ctx, {int liveUnread = 0}) {
      final base = serverRoot;

      if (isGuest) {
        if (kDebugMode) debugPrint('[UserHomeScreen] Header(guest)');
        return HomeHeader(
          firstName: null,
          lastName: null,
          avatarUrl: null,
          imageBaseUrl: base,
          unreadCount: 0,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          radius: 10,
          onBellTap: null,
        );
      }

      // logged-in:

      final jwtAvatar = (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
          ? avatarUrl
          : null;

      if (jwtAvatar != null) {
        if (kDebugMode)
          debugPrint('[UserHomeScreen] Header(logged) using JWT avatar');
        return HomeHeader(
          firstName: firstName,
          lastName: lastName,
          avatarUrl: jwtAvatar,
          imageBaseUrl: base,
          unreadCount: liveUnread,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          radius: 10,
          onBellTap: () {
            if (kDebugMode) debugPrint('[UserHomeScreen] Bell tapped');
            Navigator.of(ctx)
                .pushNamed(
                  Routes.userNotifications,
                  arguments: UserNotificationsRouteArgs(token: token),
                )
                .then(
                  (_) => ctx.read<UserUnreadNotificationsCubit?>()?.refresh(),
                );
          },
        );
      }

      if (kDebugMode)
        debugPrint(
          '[UserHomeScreen] Header(logged) fetching profile avatar...',
        );
      final repo = UserProfileRepositoryImpl(svc.UserProfileService());
      final getUser = GetUserProfile(repo);

      return FutureBuilder(
        future: getUser(token, userId), // يجلب UserEntity
        builder: (context, snap) {
          String? relative = (snap.data?.profileImageUrl)?.toString();
          if (kDebugMode) {
            debugPrint('[UserHomeScreen] profile.profileImageUrl="$relative"');
          }

          return HomeHeader(
            firstName: firstName,
            lastName: lastName,

            avatarUrl: relative,
            imageBaseUrl: base, // ex: http://192.168.1.6:8080
            unreadCount: liveUnread,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            radius: 10,
            onBellTap: () {
              if (kDebugMode) debugPrint('[UserHomeScreen] Bell tapped');
              Navigator.of(context)
                  .pushNamed(
                    Routes.userNotifications,
                    arguments: UserNotificationsRouteArgs(token: token),
                  )
                  .then(
                    (_) => context
                        .read<UserUnreadNotificationsCubit?>()
                        ?.refresh(),
                  );
            },
          );
        },
      );
    }

    // ---------- body content: shared for both states ----------
    Widget _buildContent(BuildContext ctx, {int liveUnread = 0}) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(ctx, liveUnread: liveUnread),
          const Divider(height: 1),

          if (!isGuest)
            InterestSection(
              title: t.homeInterestBasedTitle,
              showAllLabel: t.homeSeeAll,
              usecase: getInterestBased,
              token: token,
              userId: userId,
              currencyCode: currencyFallback,
              getCurrencyCode: getCurrencyCodeFn,
              imageBaseUrl: serverRoot,
              maxItems: 4,
              standalone: false,
              onItemTap: (id) => _goToDetails(ctx, id, serverRoot),
              onShowAll: () {
                if (kDebugMode) {
                  debugPrint('[UserHomeScreen] InterestSection -> SeeAll');
                }
                Navigator.of(ctx).push(
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
          ActivityTypesSection(
            getTypes: getItemTypes,
            getItemsByType: getItemsByType,
            token: token,
            onlyWithActivities: true,
            onTypeTap: (id, name) {
              if (kDebugMode) {
                debugPrint('[UserHomeScreen] TypeTap id=$id name="$name"');
              }
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ActivitiesByTypeScreen(
                    typeId: id,
                    typeName: name,
                    getItemsByType: getItemsByType,
                    currencyCode: currencyFallback,
                    getCurrencyCode: getCurrencyCodeFn,
                    imageBaseUrl: serverRoot,
                  ),
                ),
              );
            },
            onSeeAll: () {
              if (kDebugMode) {
                debugPrint('[UserHomeScreen] ActivityTypes -> SeeAll');
              }
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ActivityTypesAllScreen(
                    getTypes: getItemTypes,
                    getItemsByType: getItemsByType,
                    token: token,
                    onTypeTap: (id, name) {
                      if (kDebugMode) {
                        debugPrint(
                          '[UserHomeScreen] AllTypes TypeTap id=$id name="$name"',
                        );
                      }
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => ActivitiesByTypeScreen(
                            typeId: id,
                            typeName: name,
                            getItemsByType: getItemsByType,
                            currencyCode: currencyFallback,
                            imageBaseUrl: serverRoot,
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
          ExploreSection(
            title: t.homeExploreActivities,
            showAllLabel: t.homeSeeAll,
            usecase: getUpcomingGuest,
            currencyCode: currencyFallback,
            getCurrencyCode: getCurrencyCodeFn,
            imageBaseUrl: serverRoot,
            maxItems: 6,
            standalone: false,
            onItemTap: (id) => _goToDetails(ctx, id, serverRoot),
            onShowAll: () {
              if (kDebugMode) {
                debugPrint('[UserHomeScreen] Explore -> SeeAll');
              }
              Navigator.of(ctx).push(
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
      );
    }

    if (isGuest) {
      if (kDebugMode) {
        debugPrint('[UserHomeScreen] Guest mode: skip UnreadCubit');
      }
      return Scaffold(
        body: SafeArea(top: true, bottom: false, child: _buildContent(context)),
      );
    }

    if (kDebugMode) {
      debugPrint('[UserHomeScreen] Logged mode: provide UnreadCubit');
    }
    return BlocProvider<UserUnreadNotificationsCubit>(
      create: (_) {
        final repo = UserNotificationRepositoryImpl(UserNotificationService());
        final cubit = UserUnreadNotificationsCubit(repo: repo, token: token);
        if (kDebugMode) debugPrint('[UserHomeScreen] UnreadCubit.refresh()');
        cubit.refresh();
        return cubit;
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: BlocBuilder<UserUnreadNotificationsCubit, UserUnreadState>(
            builder: (ctx, s) {
              if (kDebugMode) {
                debugPrint('[UserHomeScreen] UnreadState count=${s.count}');
              }
              return _buildContent(ctx, liveUnread: s.count);
            },
          ),
        ),
      ),
    );
  }
}

// ===== SEE-ALL pages with your AppSearchAppBar (unchanged, with tiny logs) =====
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (kDebugMode) {
      debugPrint(
        '[AllInterests] build query="$_query" base="${widget.imageBaseUrl}"',
      );
    }
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
        maxItems: null,
        searchQuery: _query,
        standalone: true,
        onShowAll: null,
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (kDebugMode) {
      debugPrint(
        '[AllExplore] build query="$_query" base="${widget.imageBaseUrl}"',
      );
    }
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
        maxItems: null,
        searchQuery: _query,
        standalone: true,
        onShowAll: null,
      ),
    );
  }
}
