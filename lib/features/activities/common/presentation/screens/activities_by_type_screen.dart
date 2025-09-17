// lib/features/activities/common/presentation/screens/activities_by_type_screen.dart
// Screen – List upcoming items for the selected type (fix image base URL)

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
  final String? currencyCode; // e.g., "USD"

  /// Base host to build absolute image URLs for relative paths like "/uploads/.."
  /// Example: "http://3.96.140.126:8080"
  final String? imageBaseUrl;

  const ActivitiesByTypeScreen({
    super.key,
    required this.typeId,
    required this.typeName,
    required this.getItemsByType,
    this.currencyCode,
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

    return Scaffold(
      appBar: AppBar(title: Text(typeName)),
      body: BlocProvider(
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
            if (state is ItemsByTypeInitial || state is ItemsByTypeLoading) {
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
                    currencyCode: currencyCode,
                    imageBaseUrl: resolvedBase, // <<< FIX: ensure absolute URL
                    onPressed: () {
                      // open details as guest (no token in this screen)                 // comment
                      Navigator.of(context).pushNamed(
                        Routes.userActivityDetail, // route
                        arguments: UserActivityDetailRouteArgs(
                          // args
                          itemId: it.id, // id
                          token: null, // guest
                          currencyCode: currencyCode, // currency
                          imageBaseUrl: resolvedBase, // absolute images
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
      ),
    );
  }
}
