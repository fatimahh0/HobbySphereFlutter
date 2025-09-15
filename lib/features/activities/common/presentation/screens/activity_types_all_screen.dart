// Screen – Show all categories in grid (3 columns)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../../domain/usecases/get_item_types.dart';
import '../bloc/types/types_bloc.dart';
import '../bloc/types/types_event.dart';
import '../bloc/types/types_state.dart';
import '../widgets/activity_type_chip.dart';

class ActivityTypesAllScreen extends StatelessWidget {
  final GetItemTypes getTypes;
  final String token;
  final void Function(int id, String name)? onTypeTap;

  const ActivityTypesAllScreen({
    super.key,
    required this.getTypes,
    required this.token,
    this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final double chipExtent = MediaQuery.textScaleFactorOf(context) > 1.1
        ? 80
        : 72;

    return Scaffold(
      appBar: AppBar(title: Text(t.homeSeeAllCategories)),
      body: BlocProvider(
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TypesLoaded) {
              final list = state.types;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: chipExtent, // ← explicit height
                ),
                itemBuilder: (_, i) {
                  final tpe = list[i];
                  return ActivityTypeChip(
                    label: tpe.name,
                    iconName: tpe.icon,
                    onTap: () => onTypeTap?.call(tpe.id, tpe.name),
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
