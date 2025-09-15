// Home section: "Categories" (first 6). Supports filtering to non-empty types.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../../domain/usecases/get_item_types.dart';
import '../bloc/types/types_bloc.dart';
import '../bloc/types/types_event.dart';
import '../bloc/types/types_state.dart';
import 'activity_type_chip.dart';

class ActivityTypesSection extends StatelessWidget {
  final GetItemTypes getTypes;
  final String token;
  final VoidCallback? onSeeAll;
  final void Function(int id, String name)? onTypeTap;
  final bool onlyWithActivities; // NEW

  const ActivityTypesSection({
    super.key,
    required this.getTypes,
    required this.token,
    this.onSeeAll,
    this.onTypeTap,
    this.onlyWithActivities = false, // default keeps original behavior
  });

  bool _hasActivities(dynamic t) {
    // try common field names safely (null -> 0)
    final int count =
        (t.activitiesCount ?? t.count ?? t.itemsCount ?? t.total ?? 0) as int;
    return count > 0;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // compact header, no extra space
    final header = Padding(
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
          TextButton(onPressed: onSeeAll, child: Text(t.homeSeeAll)),
        ],
      ),
    );

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
          if (state is TypesInitial || state is TypesLoading) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                header,
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
                          mainAxisExtent: 72, // <<< fixed height, no overflow
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
            final source = onlyWithActivities
                ? state.types.where(_hasActivities).toList()
                : state.types;
            final six = source.take(6).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                header,
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: six.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 72, // <<< fixed height
                        ),
                    itemBuilder: (_, i) {
                      final x = six[i];
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
          }

          // error fallback
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              header,
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
