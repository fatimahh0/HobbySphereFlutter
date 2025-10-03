// lib/features/activities/common/presentation/widgets/item-types_section.dart
// Flutter 3.35.x
// Home section: shows first 6 categories, and shows "See all" ONLY if there are > 6
// Optionally filters to only categories that currently have activities (via GetItemsByType).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/common/presentation/widgets/activity_type_chip.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../../domain/usecases/get_item_types.dart';
import '../../domain/usecases/get_items_by_type.dart';
import '../bloc/types/types_bloc.dart';
import '../bloc/types/types_event.dart';
import '../bloc/types/types_state.dart';

import '../../domain/entities/item_type.dart';

class ActivityTypesSection extends StatelessWidget {
  final GetItemTypes getTypes;
  final GetItemsByType getItemsByType; // used to check if a type has items
  final String token;

  /// Called when the header "See all" is pressed (only shown if > 6 types).
  final VoidCallback? onSeeAll;

  /// When a type chip is tapped.
  final void Function(int id, String name)? onTypeTap;

  /// If true, only keep categories that actually have activities.
  final bool onlyWithActivities;

  const ActivityTypesSection({
    super.key,
    required this.getTypes,
    required this.getItemsByType,
    required this.token,
    this.onSeeAll,
    this.onTypeTap,
    this.onlyWithActivities = false,
  });

  // Check which types currently have items (runs in parallel).
  Future<List<ItemType>> _filterTypesWithItems(List<ItemType> types) async {
    if (!onlyWithActivities) return types;

    final futures = types.map((t) async {
      try {
        final items = await getItemsByType(t.id);
        return items.isNotEmpty ? t : null;
      } catch (_) {
        // On error for a specific type, just exclude it from "non-empty".
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);
    return results.whereType<ItemType>().toList();
  }

  Widget _header(BuildContext context, {required bool showSeeAll}) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            t.homeActivityCategories,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (showSeeAll && onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(t.homeSeeAll)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => TypesBloc(getTypes)..add(TypesLoadRequested(token)),
      child: BlocConsumer<TypesBloc, TypesState>(
        listenWhen: (p, c) => c is TypesError,
        listener: (context, state) {
          if (state is TypesError) {
            showTopToast(context, t.globalError, type: ToastType.error);
          }
        },
        builder: (context, state) {
          // Loading skeleton
          if (state is TypesInitial || state is TypesLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _header(context, showSeeAll: false),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 72,
                        ),
                    itemBuilder: (_, __) => Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is TypesLoaded) {
            // Filter (if requested) using GetItemsByType, then decide to show "See all".
            return FutureBuilder<List<ItemType>>(
              future: _filterTypesWithItems(state.types),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  // While we check which types have items, keep a light skeleton.
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      _header(context, showSeeAll: false),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 72,
                              ),
                          itemBuilder: (_, __) => Container(
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final filtered = snap.data ?? const <ItemType>[];
                final showSeeAll = onSeeAll != null && filtered.length > 6;
                final firstSix = filtered.take(6).toList();

                // If there are no categories after filtering, render nothing.
                if (filtered.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    _header(context, showSeeAll: showSeeAll),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: firstSix.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 72,
                            ),
                        itemBuilder: (_, i) {
                          final x = firstSix[i];
                          return ActivityTypeChip(
                            label: x.name,
                            iconName: x.icon,
                            onTap: () => onTypeTap?.call(x.id, x.name),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }

          // Error fallback
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              _header(context, showSeeAll: false),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.globalError, style: TextStyle(color: cs.error)),
              ),
            ],
          );
        },
      ),
    );
  }
}
