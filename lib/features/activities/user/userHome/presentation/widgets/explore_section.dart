import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/activity_card.dart';
import '../../domain/usecases/get_upcoming_guest_items.dart';
import '../bloc/upcoming/upcoming_bloc.dart';
import '../bloc/upcoming/upcoming_event.dart';
import '../bloc/upcoming/upcoming_state.dart';

class ExploreSection extends StatelessWidget {
  final String? title;
  final String? showAllLabel;
  final GetUpcomingGuestItems usecase;

  final String? currencyCode; // fallback
  final Future<String?> Function()? getCurrencyCode; // dynamic
  final String? imageBaseUrl;

  /// Max items to display (HOME). If `null`, show ALL (See-All).
  final int? maxItems;

  /// Optional local filter for See-All.
  final String? searchQuery;

  /// When true, renders as self-contained scrollable (used on See-All pages).
  final bool standalone;

  final VoidCallback? onShowAll;
  final void Function(int id)? onItemTap;

  const ExploreSection({
    super.key,
    this.title,
    this.showAllLabel,
    required this.usecase,
    this.currencyCode,
    this.getCurrencyCode,
    this.imageBaseUrl,
    this.maxItems = 6, // HOME default (unchanged)
    this.searchQuery, // See-All passes this
    this.standalone = false, // HOME false, See-All true
    this.onShowAll,
    this.onItemTap,
  });

  static double _tileExtent(BuildContext context) {
    final s = MediaQuery.textScaleFactorOf(context);
    return 172 + (s > 1 ? (s - 1) * 18 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final content = BlocProvider(
      create: (_) => UpcomingBloc(usecase)..add(UpcomingLoadRequested()),
      child: BlocConsumer<UpcomingBloc, UpcomingState>(
        listenWhen: (p, c) => c is UpcomingError,
        listener: (ctx, state) {
          if (state is UpcomingError) {
            showTopToast(ctx, t.globalError, type: ToastType.error);
          }
        },
        builder: (ctx, state) {
          if (state is UpcomingInitial || state is UpcomingLoading) {
            return _loader(context, count: maxItems ?? 8);
          }

          if (state is UpcomingLoaded && state.items.isNotEmpty) {
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
                      // no token here → open as guest (token: null)                    // comment
                      Navigator.of(context).pushNamed(
                        Routes.userActivityDetail, // route
                        arguments: UserActivityDetailRouteArgs(
                          // args
                          itemId: it.id, // id
                          token: null, // guest
                          currencyCode: code ?? currencyCode, // currency
                          imageBaseUrl: imageBaseUrl, // base
                        ),
                      );

                      // notify optional callback                                        // comment
                      onItemTap?.call(it.id);
                    },
                  );
                },
              );

              final header = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title ?? t.homeExploreActivities,
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
                              style: const TextStyle(
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
                    const SizedBox(height: 8),
                    header,
                    const SizedBox(height: 10),
                    grid,
                    if (list.isEmpty) _empty(context, t.activitiesEmpty),
                  ],
                );
              } else {
                // Home: original (non-scrollable) behavior
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    header,
                    const SizedBox(height: 10),
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
      return RefreshIndicator(onRefresh: () async {}, child: content);
    }
    return content;
  }

  Widget _loader(BuildContext context, {required int count}) {
    final cs = Theme.of(context).colorScheme;
    final extent = _tileExtent(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
