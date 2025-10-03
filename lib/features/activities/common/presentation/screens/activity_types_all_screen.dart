// Show all categories that actually have activities (probe GetItemsByType).
// Includes search, scrolling, and responsive grid.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/common/presentation/widgets/activity_type_chip.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';

import '../../domain/entities/item_type.dart';
import '../../domain/usecases/get_item_types.dart';
import '../../domain/usecases/get_items_by_type.dart';
import '../bloc/types/types_bloc.dart';
import '../bloc/types/types_event.dart';
import '../bloc/types/types_state.dart';


class ActivityTypesAllScreen extends StatefulWidget {
  final GetItemTypes getTypes;
  final GetItemsByType getItemsByType; // <— probe items per type
  final String token;
  final void Function(int id, String name)? onTypeTap;

  const ActivityTypesAllScreen({
    super.key,
    required this.getTypes,
    required this.getItemsByType, // <—
    required this.token,
    this.onTypeTap,
  });

  @override
  State<ActivityTypesAllScreen> createState() => _ActivityTypesAllScreenState();
}

class _ActivityTypesAllScreenState extends State<ActivityTypesAllScreen> {
  String _query = '';

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 340) return 2;
    if (w < 600) return 3;
    if (w < 900) return 4;
    if (w < 1200) return 5;
    return 6;
  }

  double _chipExtent(BuildContext context) {
    final s = MediaQuery.textScaleFactorOf(context);
    return 72 + (s > 1 ? (s - 1) * 12 : 0);
  }

  Future<List<ItemType>> _activeTypes(List<ItemType> source) async {
    final out = <ItemType>[];
    for (final t in source) {
      try {
        final items = await widget.getItemsByType(t.id);
        if (items.isNotEmpty) out.add(t);
      } catch (_) {
        // ignore this type if request fails
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppSearchAppBar(
        hint: t.searchPlaceholder,
        initialQuery: _query,
        onQueryChanged: (q) => setState(() => _query = q.trim()),
        onClear: () => setState(() => _query = ''),
        debounceMs: 250,
        showBack: true,
      ),
      body: BlocProvider(
        create: (_) =>
            TypesBloc(widget.getTypes)..add(TypesLoadRequested(widget.token)),
        child: BlocConsumer<TypesBloc, TypesState>(
          listenWhen: (p, c) => c is TypesError,
          listener: (context, state) {
            if (state is TypesError) {
              showTopToast(context, t.globalError, type: ToastType.error);
            }
          },
          builder: (context, state) {
            if (state is TypesInitial || state is TypesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TypesLoaded) {
              return FutureBuilder<List<ItemType>>(
                future: _activeTypes(state.types),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Only non-empty types
                  List<ItemType> list = snap.data!;

                  // Apply search
                  final q = _query.toLowerCase();
                  if (q.isNotEmpty) {
                    list = list.where((it) {
                      final name = it.name.toLowerCase();
                      final icon = (it.icon ?? '').toLowerCase();
                      return name.contains(q) || icon.contains(q);
                    }).toList();
                  }

                  final count = _crossAxisCount(context);
                  final extent = _chipExtent(context);

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TypesBloc>().add(
                        TypesLoadRequested(widget.token),
                      );
                      setState(() {}); // refresh future
                    },
                    child: Scrollbar(
                      child: list.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(24),
                              children: [
                                Center(
                                  child: Text(
                                    t.activitiesEmpty,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: list.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: count,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    mainAxisExtent: extent,
                                  ),
                              itemBuilder: (_, i) {
                                final tpe = list[i];
                                return ActivityTypeChip(
                                  label: tpe.name,
                                  iconName: tpe.icon,
                                  onTap: () =>
                                      widget.onTypeTap?.call(tpe.id, tpe.name),
                                );
                              },
                            ),
                    ),
                  );
                },
              );
            }

            // Fallback error
            return Center(
              child: Text(t.globalError, style: TextStyle(color: cs.error)),
            );
          },
        ),
      ),
    );
  }
}
