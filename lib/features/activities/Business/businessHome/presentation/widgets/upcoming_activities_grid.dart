// ===== Flutter 3.35.x =====
// Sliver grid wrapper that can do Masonry (auto-height) or fixed-ratio grid.
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

typedef Json = Map<String, dynamic>;

class UpcomingActivitiesGrid extends StatelessWidget {
  final List<Json> data;
  final bool loading;
  final bool refreshing; // (reserved for top refresh indicator if you want)
  final Future<void> Function() onRefresh;
  final Widget header;
  final Widget Function(BuildContext, Json) itemBuilder;
  final String emptyText;

  final bool masonry; // true => SliverMasonryGrid
  final double? childAspectRatio; // used when masonry=false

  const UpcomingActivitiesGrid({
    super.key,
    required this.data,
    required this.loading,
    required this.refreshing,
    required this.onRefresh,
    required this.header,
    required this.itemBuilder,
    required this.emptyText,
    this.masonry = true,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // First-load spinner
    if (loading && data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty (but not loading)
    if (!loading && data.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  emptyText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal: header + grid
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: masonry
                ? SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemBuilder: (ctx, i) => itemBuilder(ctx, data[i]),
                    childCount: data.length,
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: childAspectRatio ?? 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => itemBuilder(ctx, data[i]),
                      childCount: data.length,
                    ),
                    
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        
      ),



    );
  }
}
