// lib/features/activities/Business/common/presentation/screen/reopen_item_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:hobby_sphere/features/activities/Business/createActivity/data/repositories/create_item_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/create_item.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

// shared widgets
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';

// DI
import '../../../createActivity/data/services/create_item_service.dart';

// Bloc
import '../../../createActivity/presentation/bloc/create_item_bloc.dart';
import '../../../createActivity/presentation/bloc/create_item_event.dart';
import '../../../createActivity/presentation/bloc/create_item_state.dart';

// Map picker
import '../../../createActivity/presentation/widgets/map_location_picker.dart';

// Domain
import '../../domain/entities/business_activity.dart';

class ReopenItemPage extends StatelessWidget {
  final int businessId;
  final GetItemTypes getItemTypes;
  final GetCurrentCurrency getCurrentCurrency;
  final BusinessActivity oldItem;

  const ReopenItemPage({
    super.key,
    required this.businessId,
    required this.getItemTypes,
    required this.getCurrentCurrency,
    required this.oldItem,
  });

  @override
  Widget build(BuildContext context) {
    final repo = CreateItemRepositoryImpl(CreateItemService());
    final createUsecase = CreateItem(repo);

    return BlocProvider(
      create: (_) => CreateItemBloc(
        createItem: createUsecase,
        getItemTypes: getItemTypes,
        getCurrentCurrency: getCurrentCurrency,
        businessId: businessId,
      )..add(CreateItemBootstrap()), // bootstrap dropdown + currency
      child: _ReopenItemView(oldItem: oldItem),
    );
  }
}

class _ReopenItemView extends StatefulWidget {
  final BusinessActivity oldItem;
  const _ReopenItemView({required this.oldItem});

  @override
  State<_ReopenItemView> createState() => _ReopenItemViewState();
}

class _ReopenItemViewState extends State<_ReopenItemView> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _max = TextEditingController();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    // prefill controllers from old item
    _name.text = widget.oldItem.name;
    _desc.text = widget.oldItem.description;
    _price.text = widget.oldItem.price.toStringAsFixed(0);
    _max.text = widget.oldItem.maxParticipants.toString();

    // send initial values to Bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CreateItemBloc>();
      bloc.add(CreateItemNameChanged(widget.oldItem.name));
      bloc.add(CreateItemDescriptionChanged(widget.oldItem.description));
      bloc.add(CreateItemPriceChanged(widget.oldItem.price));
      bloc.add(CreateItemMaxChanged(widget.oldItem.maxParticipants));
      if (widget.oldItem.itemTypeId != null) {
        bloc.add(CreateItemTypeChanged(widget.oldItem.itemTypeId!));
      }
      bloc.add(
        CreateItemLocationPicked(
          widget.oldItem.location,
          widget.oldItem.latitude,
          widget.oldItem.longitude,
        ),
      );
      // 👇 treat old image as valid if exists
      if (widget.oldItem.imageUrl != null &&
          widget.oldItem.imageUrl!.isNotEmpty) {
        bloc.add(CreateItemImageUrlRetained(widget.oldItem.imageUrl!));
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final picker = ImagePicker();

    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                AppLocalizations.of(context)!.createActivityChooseLibrary,
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(
                AppLocalizations.of(context)!.createActivityTakePhoto,
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );

    if (src == null) return;
    final x = await picker.pickImage(source: src, imageQuality: 85);
    if (!mounted) return;

    final file = x != null ? File(x.path) : null;
    setState(() => _pickedImage = file);
    context.read<CreateItemBloc>().add(CreateItemImagePicked(file));
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('EEE, MMM d, yyyy • HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<CreateItemBloc, CreateItemState>(
      listenWhen: (p, c) => p.error != c.error || p.success != c.success,
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.success != null && state.success!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.success!)));
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateItemBloc>();
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!);

        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Activity name
                    AppTextField(
                      controller: _name,
                      label: loc.createActivityActivityName,
                      filled: true,
                      margin: const EdgeInsets.only(bottom: 12),
                      onChanged: (v) => bloc.add(CreateItemNameChanged(v)),
                    ),

                    // Activity type
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.createActivitySelectType,
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: state.itemTypeId,
                          hint: Text(loc.createActivitySelectType),
                          items: state.types
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id,
                                  child: Text(t.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) bloc.add(CreateItemTypeChanged(v));
                          },
                        ),
                      ),
                    ),

                    // Description
                    AppTextField(
                      controller: _desc,
                      label: loc.createActivityDescription,
                      filled: true,
                      maxLines: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      onChanged: (v) =>
                          bloc.add(CreateItemDescriptionChanged(v)),
                    ),

                    // Map location
                    MapLocationPicker(
                      hintText: loc.createActivityLocation,
                      initialAddress: widget.oldItem.location,
                      initialLatLng: LatLng(
                        widget.oldItem.latitude,
                        widget.oldItem.longitude,
                      ),
                      onPicked: (addr, lat, lng) =>
                          bloc.add(CreateItemLocationPicked(addr, lat, lng)),
                    ),

                    const SizedBox(height: 12),

                    // Max participants
                    AppTextField(
                      controller: _max,
                      label: loc.createActivityMaxParticipants,
                      keyboardType: TextInputType.number,
                      filled: true,
                      margin: const EdgeInsets.only(bottom: 12),
                      onChanged: (v) =>
                          bloc.add(CreateItemMaxChanged(int.tryParse(v))),
                    ),

                    // Price
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _price,
                            label: loc.createActivityPrice,
                            hint: '0',
                            filled: true,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (v) => bloc.add(
                              CreateItemPriceChanged(double.tryParse(v)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            border: Border.all(color: cs.outlineVariant),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            state.currency?.code ?? '---',
                            style: tt.titleMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Start datetime
                    _DateField(
                      label: loc.createActivityStartDate,
                      value: state.start,
                      fmt: _fmtDate,
                      onPick: (dt) {
                        bloc.add(CreateItemStartChanged(dt));
                        final end = context.read<CreateItemBloc>().state.end;
                        if (end == null || !end.isAfter(dt)) {
                          bloc.add(
                            CreateItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          );
                        }
                      },
                      onClear: () => bloc.add(CreateItemStartChanged(null)),
                    ),
                    const SizedBox(height: 10),

                    // End datetime
                    _DateField(
                      label: loc.createActivityEndDate,
                      value: state.end,
                      fmt: _fmtDate,
                      onPick: (dt) {
                        final start = bloc.state.start;
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(const Duration(hours: 1));
                          bloc.add(CreateItemEndChanged(fixed));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.createActivityErrorRequired),
                            ),
                          );
                        } else {
                          bloc.add(CreateItemEndChanged(dt));
                        }
                      },
                      onClear: () => bloc.add(CreateItemEndChanged(null)),
                    ),

                    if (hasDateConflict) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          loc.createActivityErrorRequired,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Image (old or new)
                    GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.outlineVariant,
                          ), // ✅ Correct
                        ),

                        clipBehavior: Clip.antiAlias,
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : (widget.oldItem.imageUrl != null
                                  ? Image.network(
                                      widget.oldItem.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        loc.createActivityTapToPick,
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    )),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit
                    AppButton(
                      label: loc.createActivitySubmit,
                      expand: true,
                      isBusy: state.loading,
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () => bloc.add(CreateItemSubmitPressed())
                          : null,
                    ),

                    if (state.error != null && state.error!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          state.error!,
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// date picker field widget
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String Function(DateTime?) fmt;
  final ValueChanged<DateTime> onPick;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.value,
    required this.fmt,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant), // ✅ Correct
      ),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.event, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(fmt(value), style: tt.bodyMedium),
              ],
            ),
          ),
          if (value != null && onClear != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            ),
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final init = value ?? now;
              final date = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
                initialDate: init.isBefore(now) ? now : init,
              );
              if (date == null) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(init),
              );
              if (time == null) return;
              onPick(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
              );
            },
            icon: const Icon(Icons.edit_calendar),
            label: Text(AppLocalizations.of(context)!.createActivityChange),
          ),
        ],
      ),
    );
  }
}
