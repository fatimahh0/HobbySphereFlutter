import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/app/router/legacy_nav.dart';
// Card
import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/activity_card.dart';

// Domain
import '../../domain/usecases/get_interest_based_items.dart';

// Bloc
import '../bloc/interest/interest_bloc.dart';
import '../bloc/interest/interest_event.dart';
import '../bloc/interest/interest_state.dart';

class InterestSection extends StatelessWidget {
  final String? title;
  final String? showAllLabel;
  final GetInterestBasedItems usecase;
  final String token;
  final int userId;

  /// Fallback currency if [getCurrencyCode] is not provided / still loading
  final String? currencyCode;

  /// Async currency getter that returns raw code from backend (e.g. "CAD", "EURO", "EUR")
  final Future<String?> Function()? getCurrencyCode;

  /// Base host to build absolute image URLs for relative paths like "/uploads/.."
  /// Example: "http://3.96.140.126:8080"
  final String? imageBaseUrl;

  /// Max items to display (HOME). If `null`, show ALL (See-All).
  final int? maxItems;

  /// Optional local filter (case-insensitive) used on See-All page.
  final String? searchQuery;

  /// When true, renders as self-contained scrollable (used on See-All pages).
  final bool standalone;

  final VoidCallback? onShowAll;
  final void Function(int id)? onItemTap;

  const InterestSection({
    super.key,
    this.title,
    this.showAllLabel,
    required this.usecase,
    required this.token,
    required this.userId,
    this.currencyCode,
    this.getCurrencyCode,
    this.imageBaseUrl,
    this.maxItems = 4, // HOME default (unchanged)
    this.searchQuery, // See-All passes this
    this.standalone = false, // HOME false, See-All true
    this.onShowAll,
    this.onItemTap,
  });

  static double _tileExtent(BuildContext context) {
    final s = MediaQuery.textScaleFactorOf(context);
    return 168 + (s > 1 ? (s - 1) * 18 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final content = BlocProvider(
      create: (_) =>
          InterestBloc(usecase)
            ..add(InterestLoadRequested(token: token, userId: userId)),
      child: BlocConsumer<InterestBloc, InterestState>(
        listenWhen: (p, c) => c is InterestError,
        listener: (ctx, state) {
          if (state is InterestError) {
            showTopToast(ctx, t.globalError, type: ToastType.error);
          }
        },
        builder: (ctx, state) {
          if (state is InterestInitial || state is InterestLoading) {
            return _skeletonGrid(context, count: maxItems ?? 8);
          }

          if (state is InterestLoaded && state.items.isNotEmpty) {
            // Filter (only when searchQuery provided)
            final q = (searchQuery ?? '').trim().toLowerCase();
            var list = state.items.where((it) {
              if (q.isEmpty) return true;
              final title = (it.title ?? '').toLowerCase();
              final loc = (it.location ?? '').toLowerCase();

              return title.contains(q) || loc.contains(q);
            }).toList();

            // Cap for HOME (unchanged behavior)
            if (maxItems != null) {
              list = list.take(maxItems!).toList();
            }

            final fut = getCurrencyCode?.call();

            Widget grid(String? code) {
              final extent = _tileExtent(context);
              final grid = GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: extent,
                ),
                itemBuilder: (_, i) {
                  final it = list[i];
                  return ActivityCard(
                    item: ActivityCardData(
                      id: it.id,
                      title: it.title,
                      start: it.start,
                      price: it.price,
                      imageUrl: it.imageUrl,
                      location: it.location,
                    ),
                    variant: ActivityCardVariant.compact,
                    currencyCode: code ?? currencyCode,
                    imageBaseUrl: imageBaseUrl,
                    onPressed: () {
                      // build a proper Bearer token or pass null if empty              // comment
                      final bearer = token.startsWith('Bearer ')
                          ? token
                          : 'Bearer $token';

                      // navigate to the details screen                                 // comment
                      LegacyNav.pushNamed(
                        context,
                        Routes.userActivityDetail, // route name
                        arguments: UserActivityDetailRouteArgs(
                          // typed args
                          itemId: it.id, // item id
                          token: bearer.trim().isEmpty
                              ? null
                              : bearer, // auth or guest
                          currencyCode: code ?? currencyCode, // currency
                          imageBaseUrl: imageBaseUrl, // base for images
                        ),
                      );

                      // still notify optional callback if caller wants it               // comment
                      onItemTap?.call(it.id);
                    },
                  );
                },
              );

              final header = Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  title ?? t.homeInterestBasedTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );

              final seeAll = (onShowAll != null && maxItems != null)
                  ? Column(
                      children: [
                        const SizedBox(height: 4),
                        Center(
                          child: TextButton(
                            onPressed: onShowAll,
                            child: Text(
                              showAllLabel ?? t.homeSeeAll,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink();

              if (standalone) {
                // See-All page: scrollable wrapper
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    const SizedBox(height: 6),
                    header,
                    const SizedBox(height: 8),
                    grid,
                    if (list.isEmpty) _empty(context, t.activitiesEmpty),
                  ],
                );
              } else {
                // Home: original (non-scrollable) behavior
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: grid,
                    ),
                    seeAll,
                  ],
                );
              }
            }

            return FutureBuilder<String?>(
              future: fut,
              builder: (_, snap) => grid(snap.data),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );

    if (standalone) {
      // Pull to refresh wrapper for See-All page
      return RefreshIndicator(onRefresh: () async {}, child: content);
    }
    return content;
  }

  Widget _skeletonGrid(BuildContext context, {required int count}) {
    final cs = Theme.of(context).colorScheme;
    final extent = _tileExtent(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: extent,
        ),
        itemBuilder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context, String msg) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          msg,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
