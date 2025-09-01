import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:hobby_sphere/features/activities/Business/createActivity/data/repositories/create_item_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/create_item.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

// common widgets
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';

// DI targets
import '../../data/services/create_item_service.dart';

// Bloc
import '../bloc/create_item_bloc.dart';
import '../bloc/create_item_event.dart';
import '../bloc/create_item_state.dart';

// Map picker
import '../widgets/map_location_picker.dart';

class CreateItemPage extends StatelessWidget {
  final int businessId;
  final GetItemTypes getItemTypes;
  final GetCurrentCurrency getCurrentCurrency;

  const CreateItemPage({
    super.key,
    required this.businessId,
    required this.getItemTypes,
    required this.getCurrentCurrency,
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
      )..add(CreateItemBootstrap()),
      child: const _CreateItemView(),
    );
  }
}

class _CreateItemView extends StatefulWidget {
  const _CreateItemView();

  @override
  State<_CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<_CreateItemView> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _max = TextEditingController();

  File? _pickedImage;

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
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
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
    // Example: Mon, Sep 2, 2025 • 14:30
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
          appBar: AppBar(title: Text(loc.createActivityTitle)),
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Title
                    AppTextField(
                      controller: _name,
                      label: loc.fieldTitle,
                      hint: loc.hintTitle,
                      filled: true,
                      margin: const EdgeInsets.only(bottom: 12),
                      onChanged: (v) => bloc.add(CreateItemNameChanged(v)),
                    ),

                    // Activity Type dropdown
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.selectActivityType,
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.primary, width: 1.6),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: state.itemTypeId,
                          hint: Text(
                            state.types.isEmpty
                                ? loc.generalLoading
                                : loc.selectActivityType,
                          ),
                          items: state.types
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id,
                                  child: Text(
                                    (t.name).isNotEmpty ? t.name : '—',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              bloc.add(CreateItemTypeChanged(v));
                            }
                          },
                        ),
                      ),
                    ),

                    // Description
                    AppTextField(
                      controller: _desc,
                      label: loc.fieldDescription,
                      hint: loc.hintDescription,
                      filled: true,
                      maxLines: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      onChanged: (v) =>
                          bloc.add(CreateItemDescriptionChanged(v)),
                    ),

                    // Map picker
                    MapLocationPicker(
                      hintText: loc.searchLocation,
                      initialAddress: state.address.isEmpty
                          ? null
                          : state.address,
                      onPicked: (addr, lat, lng) =>
                          bloc.add(CreateItemLocationPicked(addr, lat, lng)),
                      // NOTE: if you kept onLocateMe inside the widget, it already updates on pick
                    ),
                    const SizedBox(height: 12),

                    // Max participants
                    AppTextField(
                      controller: _max,
                      label: loc.fieldMaxParticipants,
                      hint: loc.hintMaxParticipants,
                      keyboardType: TextInputType.number,
                      filled: true,
                      margin: const EdgeInsets.only(bottom: 12),
                      onChanged: (v) =>
                          bloc.add(CreateItemMaxChanged(int.tryParse(v))),
                    ),

                    // Price + currency
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _price,
                            label: loc.fieldPrice,
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

                    // Start / End times
                    _DateField(
                      label: loc.fieldStartDateTime,
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
                    _DateField(
                      label: loc.fieldEndDateTime,
                      value: state.end,
                      fmt: _fmtDate,
                      onPick: (dt) {
                        final start = context
                            .read<CreateItemBloc>()
                            .state
                            .start;
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(const Duration(hours: 1));
                          bloc.add(CreateItemEndChanged(fixed));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'End must be after start. Adjusted by +1h.',
                              ),
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
                          'End must be after Start.',
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Image picker (preview)
                    GestureDetector(
                      onTap: () => _pickImage(context),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _pickedImage == null
                            ? Center(
                                child: Text(
                                  'Tap to add image',
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Image.file(_pickedImage!, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit
                    AppButton(
                      label: loc.submit,
                      expand: true,
                      isBusy: state.loading,
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () => context.read<CreateItemBloc>().add(
                              CreateItemSubmitPressed(),
                            )
                          : null,
                    ),

                    if (state.error != null && state.error!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(state.error!, style: TextStyle(color: cs.error)),
                    ],
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
        border: Border.all(color: cs.outlineVariant),
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
                Text(
                  fmt(value),
                  style: tt.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (value != null && onClear != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              color: cs.onSurfaceVariant,
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
                initialTime: TimeOfDay.fromDateTime(
                  init.isBefore(now) ? now : init,
                ),
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
            label: const Text('Pick'),
          ),
        ],
      ),
    );
  }
}
