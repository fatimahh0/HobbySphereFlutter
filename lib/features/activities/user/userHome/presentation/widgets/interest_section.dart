import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/activity_card.dart';
import '../../domain/usecases/get_interest_based_items.dart';
import '../bloc/interest/interest_bloc.dart';
import '../bloc/interest/interest_event.dart';
import '../bloc/interest/interest_state.dart';

class InterestSection extends StatelessWidget {
  final String? title;
  final String? showAllLabel;
  final GetInterestBasedItems usecase;
  final String token;
  final int userId;

  /// Optional fallback if getCurrencyCode is not provided / still loading
  final String? currencyCode;

  /// Dynamic currency provider (e.g. () async => await getCurrency())
  final Future<String?> Function()? getCurrencyCode;

  /// Base host for relative image paths (e.g. "http://3.96.140.126:8080")
  final String? imageBaseUrl;

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
    this.onShowAll,
    this.onItemTap,
  });

  static double _tileExtent(BuildContext context) {
    final s = MediaQuery.textScaleFactorOf(context);
    return 212 + (s > 1 ? (s - 1) * 28 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocProvider(
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
            return _loader(context);
          }

          if (state is InterestLoaded && state.items.isNotEmpty) {
            final items = state.items.take(6).toList();
            final future = getCurrencyCode?.call();

            return FutureBuilder<String?>(
              future: future,
              builder: (c, snap) {
                final code = snap.data ?? currencyCode;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        title ?? t.homeInterestBasedTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: _tileExtent(context),
                        ),
                        itemBuilder: (_, i) {
                          final it = items[i];
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
                            currencyCode: code,
                            imageBaseUrl: imageBaseUrl,
                            onPressed: () => onItemTap?.call(it.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
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
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _loader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final extent = _tileExtent(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: extent, // same height as real cards
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
}
