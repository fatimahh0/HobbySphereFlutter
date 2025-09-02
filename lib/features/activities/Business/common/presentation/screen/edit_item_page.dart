import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/edit_activity_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'package:hobby_sphere/features/activities/Business/createActivity/data/services/create_item_service.dart';

import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';

import '../../data/repositories/edit_item_repository_impl.dart';
import '../../domain/usecases/edit_item.dart';
import '../../presentation/bloc/edit_item_bloc.dart';
import '../../presentation/bloc/edit_item_event.dart';
import '../../presentation/bloc/edit_item_state.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;
import '../../../createActivity/presentation/widgets/map_location_picker.dart';

class EditItemPage extends StatelessWidget {
  final int itemId;
  final int businessId;
  final GetItemTypes getItemTypes;
  final GetCurrentCurrency getCurrentCurrency;
  final GetBusinessActivityById getItemById;

  const EditItemPage({
    super.key,
    required this.itemId,
    required this.businessId,
    required this.getItemTypes,
    required this.getCurrentCurrency,
    required this.getItemById,
  });

  @override
  Widget build(BuildContext context) {
    final repo = EditItemRepositoryImpl(UpdatedItemService());
    final updateUsecase = UpdateItem(repo);

    return BlocProvider(
      create: (_) => EditItemBloc(
        updateItem: updateUsecase,
        getItemTypes: getItemTypes,
        getCurrentCurrency: getCurrentCurrency,
        getItemById: getItemById,
        businessId: businessId,
      )..add(EditItemBootstrap(itemId)),
      child: const _EditItemView(),
    );
  }
}

class _EditItemView extends StatefulWidget {
  const _EditItemView();

  @override
  State<_EditItemView> createState() => _EditItemViewState();
}

class _EditItemViewState extends State<_EditItemView> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _max = TextEditingController();
  File? _pickedImage;
  bool _initControllers = false;

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('EEE, MMM d, yyyy • HH:mm').format(dt.toLocal());
  }

  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
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
    context.read<EditItemBloc>().add(EditItemImagePicked(file));
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<EditItemBloc, EditItemState>(
      listenWhen: (p, c) =>
          p.error != c.error ||
          p.success != c.success ||
          (!_initControllers && c.id != null),
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

        // one-time prefill after bootstrap
        if (!_initControllers && state.id != null) {
          _initControllers = true;
          _name.text = state.name;
          _desc.text = state.description;
          _price.text = (state.price ?? 0)
              .toStringAsFixed(0)
              .replaceAll('.0', '');
          _max.text = (state.maxParticipants ?? 0).toString();
        }
      },
      builder: (context, state) {
        final bloc = context.read<EditItemBloc>();

        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!);

        final typeIds = state.types.map((t) => t.id).toSet();
        final selectedTypeId = typeIds.contains(state.itemTypeId)
            ? state.itemTypeId
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.editActivityTitle),
          ), // use your l10n key
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
                      onChanged: (v) => bloc.add(EditItemNameChanged(v)),
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
                          value: selectedTypeId,
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
                            if (v != null) bloc.add(EditItemTypeChanged(v));
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
                      onChanged: (v) => bloc.add(EditItemDescriptionChanged(v)),
                    ),

                    // Map picker (prefill with existing coords)
                    MapLocationPicker(
                      key: ValueKey("${state.lat}-${state.lng}"),
                      hintText: loc.searchLocation,
                      initialAddress: state.address.isEmpty
                          ? null
                          : state.address,
                      initialLatLng: (state.lat != null && state.lng != null)
                          ? LatLng(state.lat!, state.lng!)
                          : null,
                      onPicked: (addr, lat, lng) =>
                          bloc.add(EditItemLocationPicked(addr, lat, lng)),
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
                          bloc.add(EditItemMaxChanged(int.tryParse(v))),
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
                              EditItemPriceChanged(double.tryParse(v)),
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
                        bloc.add(EditItemStartChanged(dt));
                        final end = bloc.state.end;
                        if (end == null || !end.isAfter(dt)) {
                          bloc.add(
                            EditItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          );
                        }
                      },
                      onClear: () => bloc.add(EditItemStartChanged(null)),
                    ),
                    const SizedBox(height: 10),
                    _DateField(
                      label: loc.fieldEndDateTime,
                      value: state.end,
                      fmt: _fmtDate,
                      allowPast: true, // 👈 allow editing past end dates
                      onPick: (dt) {
                        final start = bloc.state.start;
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(const Duration(hours: 1));
                          bloc.add(EditItemEndChanged(fixed));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'End must be after start. Adjusted by +1h.',
                              ),
                            ),
                          );
                        } else {
                          bloc.add(EditItemEndChanged(dt));
                        }
                      },
                      onClear: () => bloc.add(EditItemEndChanged(null)),
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

                    // Image picker (shows existing or picked)
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
                        child: () {
                          if (_pickedImage != null) {
                            return Image.file(_pickedImage!, fit: BoxFit.cover);
                          }
                          if ((state.imageUrl ?? '').isNotEmpty &&
                              !state.imageRemoved) {
                            final url = _fullImageUrl(state.imageUrl);
                            return Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) => prog == null
                                  ? child
                                  : Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              'Tap to add image',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        }(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const SizedBox(height: 16),

                    // Save
                    AppButton(
                      label: loc.confirm,
                      expand: true,
                      isBusy: state.loading,
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () => bloc.add(EditItemSubmitPressed())
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
  final bool allowPast;

  const _DateField({
    required this.label,
    required this.value,
    required this.fmt,
    required this.onPick,
    this.onClear,
    this.allowPast = false,
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
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  softWrap: true,
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
              final earliest = DateTime(2000, 1, 1);
              final init = value ?? now;

              final date = await showDatePicker(
                context: context,
                firstDate: allowPast ? earliest : now,
                lastDate: DateTime(now.year + 2),
                initialDate: init,
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
            label: const Text('Pick'),
          ),
        ],
      ),
    );
  }
}
