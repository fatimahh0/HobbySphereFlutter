// Screen – List upcoming items for the selected type
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

import '../../../user/common/presentation/widgets/activity_card.dart'; // reusable card
import '../../domain/usecases/get_items_by_type.dart'; // usecase
import '../bloc/items_by_type/items_bloc.dart'; // bloc
import '../bloc/items_by_type/items_event.dart'; // event
import '../bloc/items_by_type/items_state.dart'; // state

class ActivitiesByTypeScreen extends StatelessWidget {
  final int typeId; // type id
  final String typeName; // appbar title
  final GetItemsByType getItemsByType; // dependency
  final String? currencyCode; // e.g., "USD"

  const ActivitiesByTypeScreen({
    super.key,
    required this.typeId, // must pass
    required this.typeName, // title
    required this.getItemsByType, // usecase
    this.currencyCode, // optional
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors

    return Scaffold(
      appBar: AppBar(title: Text(typeName)), // appbar
      body: BlocProvider(
        create: (_) =>
            ItemsByTypeBloc(getItemsByType) // bloc
              ..add(ItemsByTypeLoadRequested(typeId)), // load
        child: BlocConsumer<ItemsByTypeBloc, ItemsByTypeState>(
          listenWhen: (p, c) => c is ItemsByTypeError, // errors
          listener: (context, state) {
            if (state is ItemsByTypeError) {
              showTopToast(context, t.globalError, type: ToastType.error);
            }
          },
          builder: (context, state) {
            if (state is ItemsByTypeInitial || state is ItemsByTypeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              ); // spinner
            }
            if (state is ItemsByTypeLoaded) {
              final list = state.items; // items
              if (list.isEmpty) {
                return Center(child: Text(t.homeNoActivities)); // empty text
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16), // pad
                itemCount: list.length, // count
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final it = list[i]; // item
                  return ActivityCard(
                    item: ActivityCardData(
                      id: it.id, // id
                      title: it.title, // title
                      start: it.start, // date
                      price: it.price, // price
                      imageUrl: it.imageUrl, // image
                      location: it.location, // location
                    ),
                    variant: ActivityCardVariant.horizontal, // row layout
                    currencyCode: currencyCode, // currency code
                    onPressed: () {
                      // TODO: navigate to your details screen
                      // Navigator.pushNamed(context, Routes.userItemDetails, arguments: it.id);
                    },
                  );
                },
              );
            }
            return Center(
              // error UI
              child: Text(t.globalError, style: TextStyle(color: cs.error)),
            );
          },
        ),
      ),
    );
  }
}
