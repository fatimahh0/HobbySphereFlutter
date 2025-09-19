// lib/features/activities/common/presentation/screens/activities_by_type_screen.dart
// Screen – List upcoming items for the selected type (fix image base URL + currency resolution)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// Resolve server root if caller doesn't pass a base
import 'package:hobby_sphere/core/network/globals.dart' as g;

import '../../../user/common/presentation/widgets/activity_card.dart';
import '../../domain/usecases/get_items_by_type.dart';
import '../bloc/items_by_type/items_bloc.dart';
import '../bloc/items_by_type/items_event.dart';
import '../bloc/items_by_type/items_state.dart';

class ActivitiesByTypeScreen extends StatelessWidget {
  final int typeId; // type id
  final String typeName; // appbar title
  final GetItemsByType getItemsByType; // dependency

  /// Optional pre-known currency code (e.g., "USD"). If null, we'll try getCurrencyCode().
  final String? currencyCode;

  /// Optional resolver for the active currency (e.g., calls GetCurrentCurrency).
  /// If provided, we prefer this over the fallback currencyCode above.
  final Future<String?> Function()? getCurrencyCode;

  /// Base host to build absolute image URLs for relative paths like "/uploads/.."
  /// Example: "http://3.96.140.126:8080"
  final String? imageBaseUrl;

  const ActivitiesByTypeScreen({
    super.key,
    required this.typeId,
    required this.typeName,
    required this.getItemsByType,
    this.currencyCode,
    this.getCurrencyCode,
    this.imageBaseUrl,
  });

  // Same server-root helper you used elsewhere
  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    // e.g. "http://host:8080/api" -> "http://host:8080"
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Prefer the provided base; otherwise fall back to global server root.
    final resolvedBase =
        (imageBaseUrl != null && imageBaseUrl!.trim().isNotEmpty)
        ? imageBaseUrl
        : _serverRoot();

    // Resolve currency *once* for the whole screen.
    final Future<String?> currencyFuture = (getCurrencyCode != null)
        ? getCurrencyCode!()
        : Future.value(currencyCode);

    return Scaffold(
      appBar: AppBar(title: Text(typeName)),
      body: FutureBuilder<String?>(
        future: currencyFuture,
        builder: (context, curSnap) {
          // While currency is resolving, still show items list loader below.
          final resolvedCurrency = curSnap.data ?? currencyCode;

          return BlocProvider(
            create: (_) =>
                ItemsByTypeBloc(getItemsByType)
                  ..add(ItemsByTypeLoadRequested(typeId)),
            child: BlocConsumer<ItemsByTypeBloc, ItemsByTypeState>(
              listenWhen: (p, c) => c is ItemsByTypeError,
              listener: (context, state) {
                if (state is ItemsByTypeError) {
                  showTopToast(context, t.globalError, type: ToastType.error);
                }
              },
              builder: (context, state) {
                if (state is ItemsByTypeInitial ||
                    state is ItemsByTypeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ItemsByTypeLoaded) {
                  final list = state.items;
                  if (list.isEmpty) {
                    return Center(child: Text(t.homeNoActivities));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final it = list[i];
                      return ActivityCard(
                        item: ActivityCardData(
                          id: it.id,
                          title: it.title,
                          start: it.start,
                          price: it.price,
                          imageUrl: it.imageUrl, // can be "/uploads/.."
                          location: it.location,
                        ),
                        variant: ActivityCardVariant.horizontal,
                        currencyCode: resolvedCurrency, // ✅ now resolved
                        imageBaseUrl: resolvedBase, // ✅ ensure absolute URL
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            Routes.userActivityDetail,
                            arguments: UserActivityDetailRouteArgs(
                              itemId: it.id,
                              token: null, // guest from this screen
                              currencyCode: resolvedCurrency, // ✅ pass along
                              imageBaseUrl: resolvedBase,
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return Center(
                  child: Text(t.globalError, style: TextStyle(color: cs.error)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
