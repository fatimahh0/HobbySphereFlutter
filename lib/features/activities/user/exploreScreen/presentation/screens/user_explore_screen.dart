///// lib/features/activities/user/exploreScreen/presentation/screens/user_explore_screen.dart
// Flutter 3.35.x — Explore page with ONE search field, category chips (only
// non-empty types), dynamic currency (like Home), l10n, and realtime refresh.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;
import 'package:hobby_sphere/app/router/router.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/features/activities/user/common/presentation/widgets/activity_card.dart';

import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/item_type.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';

import 'package:hobby_sphere/features/activities/common/presentation/bloc/types/types_bloc.dart';
import 'package:hobby_sphere/features/activities/common/presentation/bloc/types/types_event.dart';
import 'package:hobby_sphere/features/activities/common/presentation/bloc/types/types_state.dart';

import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/bloc/explore_items_bloc.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/bloc/explore_items_event.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/bloc/explore_items_state.dart';

class ExploreScreen extends StatefulWidget {
  final String token;
  final GetItemTypes getItemTypes;
  final GetItemsByType getItemsByType;
  final GetUpcomingGuestItems getUpcomingGuest;

  /// Dynamic currency like Home:
  final String? currencyFallback; // e.g. "CAD"
  final Future<String?> Function()? getCurrencyCode;

  /// If your images are relative, pass the server root.
  final String? imageBaseUrl;

  const ExploreScreen({
    super.key,
    required this.token,
    required this.getItemTypes,
    required this.getItemsByType,
    required this.getUpcomingGuest,
    this.currencyFallback,
    this.getCurrencyCode,
    this.imageBaseUrl,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';

  late final TypesBloc _typesBloc;
  late final ExploreItemsBloc _itemsBloc;

  late final Future<String?> _currencyFut;

  // Keep exact refs so we can unbind safely
  void Function(Map<String, dynamic>)? _onActivityCreated;
  void Function(int, Map<String, dynamic>)? _onActivityUpdated;
  void Function(int)? _onActivityDeleted;

  // return a proper "Bearer xxx" or empty if guest
  String _bearerOrEmpty(String token) {
    // trim spaces
    final t = token.trim(); // simple trim
    if (t.isEmpty) return ''; // guest → empty
    return t.startsWith('Bearer ') ? t : 'Bearer $t'; // ensure prefix
  }

  // push Activity Detail screen with the right args
  void _goToDetails(
    BuildContext context, // navigator context
    int itemId, // activity id
    String? currency, // currency code (e.g., "USD")
    String? imageBase, // base url for images (server root)
  ) {
    // compute bearer once
    final bearer = _bearerOrEmpty(widget.token); // format token

    // push named route
    Navigator.of(context).pushNamed(
      Routes.userActivityDetail, // route name
      arguments: UserActivityDetailRouteArgs(
        itemId: itemId, // required id
        token: bearer.isNotEmpty ? bearer : null, // null for guest
        currencyCode: currency, // pass currency
        imageBaseUrl: imageBase, // pass base url
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // blocs live for the whole screen lifetime.
    _typesBloc = TypesBloc(widget.getItemTypes)
      ..add(TypesLoadRequested(widget.token));

    _itemsBloc = ExploreItemsBloc(
      getUpcomingGuest: widget.getUpcomingGuest,
      getItemsByType: widget.getItemsByType,
    )..add(const ExploreItemsLoadAll());

    // Compute currency future once
    _currencyFut = (widget.getCurrencyCode == null)
        ? Future<String?>.value(widget.currencyFallback)
        : widget.getCurrencyCode!();

    // ===== Realtime: Activities → refresh Explore list & types =====
    void _refreshBoth() {
      if (!mounted) return;
      _itemsBloc.add(const ExploreItemsRefresh());
      _typesBloc.add(TypesLoadRequested(widget.token));
    }

    _onActivityCreated = (full) => _refreshBoth();
    _onActivityUpdated = (id, patch) => _refreshBoth();
    _onActivityDeleted = (id) => _refreshBoth();

    rt.userBridge.onActivityCreated = _onActivityCreated;
    rt.userBridge.onActivityUpdated = _onActivityUpdated;
    rt.userBridge.onActivityDeleted = _onActivityDeleted;
  }

  @override
  void dispose() {
    // unbind only if still ours
    if (rt.userBridge.onActivityCreated == _onActivityCreated) {
      rt.userBridge.onActivityCreated = null;
    }
    if (rt.userBridge.onActivityUpdated == _onActivityUpdated) {
      rt.userBridge.onActivityUpdated = null;
    }
    if (rt.userBridge.onActivityDeleted == _onActivityDeleted) {
      rt.userBridge.onActivityDeleted = null;
    }
    _typesBloc.close();
    _itemsBloc.close();
    super.dispose();
  }

  List<ItemDetailsEntity> _applySearch(List<ItemDetailsEntity> src, String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return src;
    return src.where((e) {
      final t = (e.title ?? '').toLowerCase();
      final loc = (e.location ?? '').toLowerCase();
      return t.contains(qq) || loc.contains(qq);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _typesBloc),
        BlocProvider.value(value: _itemsBloc),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // ONE search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: AppSearchBar(
                  showBack: false,
                  hint: t.searchPlaceholder,
                  onQueryChanged: (q) => setState(() => _query = q),
                  onClear: () => setState(() => _query = ''),
                  debounceMs: 200,
                  filled: true,
                  borderRadius: 22,
                ),
              ),

              // Chips row: we read selectedTypeId from the items bloc state
              BlocBuilder<ExploreItemsBloc, ExploreItemsState>(
                buildWhen: (p, c) {
                  int? sel(dynamic s) => s is ExploreItemsLoaded
                      ? s.selectedTypeId
                      : s is ExploreItemsLoading
                      ? s.selectedTypeId
                      : s is ExploreItemsError
                      ? s.selectedTypeId
                      : null;
                  return sel(p) != sel(c);
                },
                builder: (context, s) {
                  final int? selectedTypeId = s is ExploreItemsLoaded
                      ? s.selectedTypeId
                      : s is ExploreItemsLoading
                      ? s.selectedTypeId
                      : s is ExploreItemsError
                      ? s.selectedTypeId
                      : null;
                  return _FilteredChipsRow(
                    token: widget.token,
                    getItemsByType: widget.getItemsByType,
                    selectedTypeId: selectedTypeId,
                    onTapAll: () => context.read<ExploreItemsBloc>().add(
                      const ExploreItemsLoadAll(),
                    ),
                    onTapType: (id) => context.read<ExploreItemsBloc>().add(
                      ExploreItemsLoadByType(id),
                    ),
                  );
                },
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ExploreItemsBloc>().add(
                      const ExploreItemsRefresh(),
                    );
                    context.read<TypesBloc>().add(
                      TypesLoadRequested(widget.token),
                    );
                  },
                  child: FutureBuilder<String?>(
                    future: _currencyFut,
                    builder: (_, snap) {
                      final String? code = snap.hasData
                          ? snap.data
                          : widget.currencyFallback;

                      return BlocBuilder<ExploreItemsBloc, ExploreItemsState>(
                        builder: (context, state) {
                          if (state is ExploreItemsInitial ||
                              state is ExploreItemsLoading) {
                            return const _ListSkeleton();
                          }
                          if (state is ExploreItemsError) {
                            return ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(
                                  t.globalError,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  state.message,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            );
                          }
                          if (state is ExploreItemsLoaded) {
                            final list = _applySearch(state.items, _query);

                            return CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      8,
                                    ),
                                    child: Text(
                                      t.homeExploreActivities,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                                if (list.isEmpty)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Center(
                                        child: Text(
                                          t.activitiesEmpty,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: AppColors.muted,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  SliverList.builder(
                                    itemCount: list.length,
                                    itemBuilder: (ctx, i) {
                                      final it = list[i];
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          8,
                                          16,
                                          8,
                                        ),
                                        child: ActivityCard(
                                          item: ActivityCardData(
                                            id: it.id,
                                            title: it.title ?? '',
                                            start: it.start,
                                            price: it.price,
                                            imageUrl: it.imageUrl,
                                            location: it.location,
                                          ),
                                          variant:
                                              ActivityCardVariant.horizontal,
                                          currencyCode: code,
                                          imageBaseUrl: widget.imageBaseUrl,
                                          onPressed: () {
                                            // call helper to navigate
                                            _goToDetails(
                                              ctx, // current context
                                              it.id, // activity id
                                              code, // currency from FutureBuilder
                                              widget
                                                  .imageBaseUrl, // image base url (server root)
                                            );
                                          },

                                          padding: const EdgeInsets.all(12),
                                          margin: EdgeInsets.zero,
                                        ),
                                      );
                                    },
                                  ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: 12),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== Helpers live in this same file (private) =====

class _FilteredChipsRow extends StatefulWidget {
  final String token;
  final GetItemsByType getItemsByType;

  final int? selectedTypeId; // null = All
  final VoidCallback onTapAll;
  final ValueChanged<int> onTapType;

  const _FilteredChipsRow({
    required this.token,
    required this.getItemsByType,
    required this.selectedTypeId,
    required this.onTapAll,
    required this.onTapType,
  });

  @override
  State<_FilteredChipsRow> createState() => _FilteredChipsRowState();
}

class _FilteredChipsRowState extends State<_FilteredChipsRow> {
  Future<List<ItemType>>? _filteredFuture;
  List<int>? _lastTypeIds;

  Future<List<ItemType>> _filterNonEmpty(List<ItemType> types) async {
    final futures = types.map((t) async {
      try {
        final items = await widget.getItemsByType(t.id);
        return items.isNotEmpty ? t : null;
      } catch (_) {
        return null;
      }
    });
    final results = await Future.wait(futures);
    return results.whereType<ItemType>().toList(growable: false);
  }

  void _maybeRebuildFuture(TypesState state) {
    if (state is! TypesLoaded) return;
    final ids = state.types.map((e) => e.id).toList(growable: false);
    final changed =
        _lastTypeIds == null ||
        _lastTypeIds!.length != ids.length ||
        !_lastTypeIds!.asMap().entries.every((e) => ids[e.key] == e.value);
    if (changed) {
      _lastTypeIds = ids;
      _filteredFuture = _filterNonEmpty(state.types);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = AppLocalizations.of(context)!;

    return SizedBox(
      height: 44,
      child: BlocBuilder<TypesBloc, TypesState>(
        builder: (context, state) {
          if (state is TypesLoaded) _maybeRebuildFuture(state);

          if (_filteredFuture == null) {
            // skeleton row while types load/filter
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => Container(
                width: 72,
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: 6,
            );
          }

          return FutureBuilder<List<ItemType>>(
            future: _filteredFuture,
            builder: (_, snap) {
              final nonEmpty = snap.data ?? const <ItemType>[];

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: 1 + nonEmpty.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    final sel = widget.selectedTypeId == null;
                    return ChoiceChip(
                      label: Text(t.filtersAll),
                      selected: sel,
                      onSelected: (_) => widget.onTapAll(),
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: sel ? AppColors.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(color: cs.outlineVariant),
                    );
                  }
                  final type = nonEmpty[i - 1];
                  final sel = widget.selectedTypeId == type.id;
                  return ChoiceChip(
                    label: Text(type.name),
                    selected: sel,
                    onSelected: (_) => widget.onTapType(type.id),
                    showCheckmark: false,
                    selectedColor: AppColors.primary,
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: sel ? AppColors.onPrimary : cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(color: cs.outlineVariant),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemBuilder: (_, __) => Container(
        height: 88,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 6,
    );
  }
}
