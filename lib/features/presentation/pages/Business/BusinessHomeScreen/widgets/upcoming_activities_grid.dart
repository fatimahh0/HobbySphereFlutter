// Flutter 3.35.x
import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // L10n

// keep JSON flexible like RN
typedef Json = Map<String, dynamic>; // alias

class UpcomingActivitiesGrid extends StatelessWidget {
  // list of items to show
  final List<Json> data; // activities
  // show spinner during first load
  final bool loading; // first load flag
  // show spinner during pull-to-refresh
  final bool refreshing; // refresh flag
  // refresh callback
  final Future<void> Function() onRefresh; // refresh
  // header widget (Welcome + title row)
  final Widget header; // header UI
  // item builder to render each card (gives context + item)
  final Widget Function(BuildContext, Json) itemBuilder; // card builder
  // text when list empty
  final String emptyText; // empty label

  const UpcomingActivitiesGrid({
    super.key, // key
    required this.data, // list
    required this.loading, // flag
    required this.refreshing, // flag
    required this.onRefresh, // handler
    required this.header, // header
    required this.itemBuilder, // builder
    required this.emptyText, // empty
  });

  @override
  Widget build(BuildContext context) {
    // theme
    final scheme = Theme.of(context).colorScheme; // colors

    // show big center spinner when first loading and list is empty
    if (loading && (data.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(), // spinner
      );
    }

    // when empty (not loading) show header + empty text
    if (!loading && data.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh, // allow pull-down even when empty
        child: ListView(
          padding: EdgeInsets.zero, // flush
          children: [
            header, // show header block
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24), // spacing
              child: Center(
                child: Text(
                  emptyText, // "No activities found..."
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface.withOpacity(0.6), // muted
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // normal case: header + 2-column grid with pull-to-refresh
    return RefreshIndicator(
      onRefresh: onRefresh, // pull-to-refresh
      child: CustomScrollView(
        slivers: [
          // header on top (Welcome + "Your Activities")
          SliverToBoxAdapter(child: header), // header
          // padding around grid
          const SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // spacing
            sliver: SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ), // no-op (keeps structure clean)
          ),
          // actual grid (2 columns)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // spacing
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns
                mainAxisSpacing: 12, // vertical gap
                crossAxisSpacing: 12, // horizontal gap
                childAspectRatio: 1.1, // card aspect
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => itemBuilder(ctx, data[i]), // build each card
                childCount: data.length, // number of items
              ),
            ),
          ),
          // bottom extra space
          const SliverToBoxAdapter(child: SizedBox(height: 24)), // footer space
        ],
      ),
    );
  }
}
