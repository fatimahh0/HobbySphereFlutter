// ===== Flutter 3.35.x =====
// EditItemPage — now using the shared Top Toast widget for success/error/info messages.

import 'dart:io'; // File handling for images
import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/features/activities/Business/common/data/services/edit_activity_service.dart'; // Edit service
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:intl/intl.dart'; // Date formatting
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show LatLng; // LatLng type

import 'package:hobby_sphere/features/activities/Business/createActivity/data/services/create_item_service.dart'; // Not used directly, but kept if other parts rely on it

import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart'; // Currency use case
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart'; // Types use case
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart'; // Get item by id

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // Button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // Inputs

// ✅ Import the Top Toast (your widget)
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // showTopToast / ToastType

import '../../data/repositories/edit_item_repository_impl.dart'; // Repo impl
import '../../domain/usecases/edit_item.dart'; // Use case
import '../../presentation/bloc/edit_item_bloc.dart'; // Bloc
import '../../presentation/bloc/edit_item_event.dart'; // Events
import '../../presentation/bloc/edit_item_state.dart'; // State

import 'package:hobby_sphere/core/network/globals.dart'
    as g; // Build absolute URL for images
import '../../../createActivity/presentation/widgets/map_location_picker.dart'; // Map picker

// Screen shell: receives ids + injected use cases
class EditItemPage extends StatelessWidget {
  final int itemId; // current item id
  final int businessId; // business id for auth/ownership
  final GetItemTypes getItemTypes; // use case to load types
  final GetCurrentCurrency getCurrentCurrency; // use case to load currency
  final GetBusinessActivityById getItemById; // use case to load item

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
    // create repo + use case
    final repo = EditItemRepositoryImpl(
      UpdatedItemService(),
    ); // repository impl
    final updateUsecase = UpdateItem(repo); // update item use case

    // Provide the bloc + bootstrap with itemId
    return BlocProvider(
      create: (_) => EditItemBloc(
        updateItem: updateUsecase,
        getItemTypes: getItemTypes,
        getCurrentCurrency: getCurrentCurrency,
        getItemById: getItemById,
        businessId: businessId,
      )..add(EditItemBootstrap(itemId)), // start loading
      child: const _EditItemView(), // body
    );
  }
}

// Internal stateful view so we can manage controllers
class _EditItemView extends StatefulWidget {
  const _EditItemView();

  @override
  State<_EditItemView> createState() => _EditItemViewState();
}

class _EditItemViewState extends State<_EditItemView> {
  // Controllers for fields
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _max = TextEditingController();

  File? _pickedImage; // picked image file
  bool _initControllers = false; // one-time prefill flag

  // format a DateTime nicely or return dash
  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('EEE, MMM d, yyyy • HH:mm').format(dt.toLocal());
  }

  // make network image URL absolute using server root
  String _fullImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');
    if (url.startsWith('/')) return '$base$url';
    return '$base/$url';
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final picker = ImagePicker();

    // source chooser sheet
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
            // small grabber
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // gallery
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            // camera
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

    if (src == null) return; // user canceled

    // pick the image
    final x = await picker.pickImage(source: src, imageQuality: 85);
    if (!mounted) return;

    // set file + notify bloc
    final file = x != null ? File(x.path) : null;
    setState(() => _pickedImage = file);
    context.read<EditItemBloc>().add(EditItemImagePicked(file)); // update state
  }

  @override
  void dispose() {
    // free controllers
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // texts

    // Listen to success/error + build UI
    return BlocConsumer<EditItemBloc, EditItemState>(
      // re-listen only when error/success changes or first time prefill
      listenWhen: (p, c) =>
          p.error != c.error ||
          p.success != c.success ||
          (!_initControllers && c.id != null),
      listener: (context, state) {
        // ❌ error -> show Top Toast error
        if (state.error != null && state.error!.isNotEmpty) {
          showTopToast(
            context,
            state.error!, // message
            type: ToastType.error, // red style
            haptics: true, // vibration
          );
        }
        // ✅ success -> show Top Toast success then pop
        else if (state.success != null && state.success!.isNotEmpty) {
          showTopToast(
            context,
            state.success!, // message
            type: ToastType.success, // primary style
            haptics: true, // vibration
          );
          Navigator.pop(context, true); // return to previous with success=true
        }

        // one-time controllers prefill after item loads
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
        final bloc = context.read<EditItemBloc>(); // shortcut

        // check start/end conflict
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!);

        // ensure selected type id is valid
        final typeIds = state.types.map((t) => t.id).toSet();
        final selectedTypeId = typeIds.contains(state.itemTypeId)
            ? state.itemTypeId
            : null;

        // Screen scaffold
        return Scaffold(
          appBar: AppBar(), // keep default; set your title with l10n later
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // disable inputs while loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // outer padding
                child: Column(
                  children: [
                    // Title
                    AppTextField(
                      controller: _name, // bind controller
                      label: loc.fieldTitle, // label from i18n
                      hint: loc.hintTitle, // hint
                      filled: true, // filled bg
                      margin: const EdgeInsets.only(bottom: 12), // spacing
                      onChanged: (v) =>
                          bloc.add(EditItemNameChanged(v)), // event
                    ),

                    // Type dropdown
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.selectActivityType, // label
                        filled: true, // filled bg
                        fillColor: cs.surfaceContainerHighest, // bg color
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
                          isExpanded: true, // full width
                          value: selectedTypeId, // selected id
                          hint: Text(
                            state.types.isEmpty
                                ? loc.generalLoading
                                : loc.selectActivityType,
                          ),
                          items: state.types
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id, // option id
                                  child: Text(
                                    (t.name).isNotEmpty ? t.name : '—', // label
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              bloc.add(EditItemTypeChanged(v)); // event
                          },
                        ),
                      ),
                    ),

                    // Description
                    AppTextField(
                      controller: _desc, // bind controller
                      label: loc.fieldDescription, // label
                      hint: loc.hintDescription, // hint
                      filled: true, // filled bg
                      maxLines: 5, // multiline
                      margin: const EdgeInsets.only(top: 12, bottom: 12), // gap
                      onChanged: (v) =>
                          bloc.add(EditItemDescriptionChanged(v)), // event
                    ),

                    // Map picker (prefilled from state)
                    MapLocationPicker(
                      key: ValueKey(
                        "${state.lat}-${state.lng}",
                      ), // rebuild if coords change
                      hintText: loc.searchLocation, // search hint
                      initialAddress: state.address.isEmpty
                          ? null
                          : state.address, // prefill address
                      initialLatLng: (state.lat != null && state.lng != null)
                          ? LatLng(state.lat!, state.lng!) // prefill coords
                          : null,
                      onPicked: (addr, lat, lng) => bloc.add(
                        EditItemLocationPicked(addr, lat, lng),
                      ), // event
                    ),

                    const SizedBox(height: 12), // space
                    // Max participants
                    AppTextField(
                      controller: _max, // bind
                      label: loc.fieldMaxParticipants, // label
                      hint: loc.hintMaxParticipants, // hint
                      keyboardType: TextInputType.number, // numeric
                      filled: true, // bg
                      margin: const EdgeInsets.only(bottom: 12), // gap
                      onChanged: (v) => bloc.add(
                        EditItemMaxChanged(int.tryParse(v)),
                      ), // event
                    ),

                    // Price + currency row
                    Row(
                      children: [
                        // Price input
                        Expanded(
                          child: AppTextField(
                            controller: _price, // bind
                            label: loc.fieldPrice, // label
                            hint: '0', // hint
                            filled: true, // bg
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, // allow decimals
                            ),
                            onChanged: (v) => bloc.add(
                              EditItemPriceChanged(double.tryParse(v)), // event
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // gap
                        // Currency badge
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
                            state.currency?.code ?? '---', // show currency code
                            style: tt.titleMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // gap
                    // Start date/time field
                    _DateField(
                      label: loc.fieldStartDateTime, // label
                      value: state.start, // current value
                      fmt: _fmtDate, // formatter
                      onPick: (dt) {
                        // set start
                        bloc.add(EditItemStartChanged(dt));
                        final end = bloc.state.end;
                        // if end is null or before start -> push end +1h
                        if (end == null || !end.isAfter(dt)) {
                          bloc.add(
                            EditItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          );
                        }
                      },
                      onClear: () =>
                          bloc.add(EditItemStartChanged(null)), // clear
                    ),

                    const SizedBox(height: 10), // gap
                    // End date/time field
                    _DateField(
                      label: loc.fieldEndDateTime, // label
                      value: state.end, // current end
                      fmt: _fmtDate, // formatter
                      allowPast: true, // allow past end to edit old items
                      onPick: (dt) {
                        final start = bloc.state.start;
                        if (start != null && !dt.isAfter(start)) {
                          // if end <= start -> fix to start +1h
                          final fixed = start.add(const Duration(hours: 1));
                          bloc.add(EditItemEndChanged(fixed)); // set fixed end
                          // ℹ️ show info toast instead of SnackBar
                          showTopToast(
                            context,
                            'End must be after start. Adjusted by +1h.', // info text
                            type: ToastType.info, // neutral style
                            haptics: true, // small vibration
                          );
                        } else {
                          bloc.add(EditItemEndChanged(dt)); // accept end
                        }
                      },
                      onClear: () =>
                          bloc.add(EditItemEndChanged(null)), // clear
                    ),

                    // inline conflict warning text
                    if (hasDateConflict) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'End must be after Start.', // error text
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12), // gap
                    // Image picker (existing or picked)
                    GestureDetector(
                      onTap: () => _pickImage(context), // open picker
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
                          // show picked image
                          if (_pickedImage != null) {
                            return Image.file(_pickedImage!, fit: BoxFit.cover);
                          }
                          // show network image if exists and not removed
                          if ((state.imageUrl ?? '').isNotEmpty &&
                              !state.imageRemoved) {
                            final url = _fullImageUrl(state.imageUrl);
                            return Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) => prog == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image, // fallback icon
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          // empty placeholder
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

                    const SizedBox(height: 8), // space

                    const SizedBox(height: 16), // more space
                    // Save button
                    AppButton(
                      label: loc.confirm, // button text
                      expand: true, // full width
                      isBusy: state.loading, // spinner when loading
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () =>
                                bloc.add(EditItemSubmitPressed()) // submit
                          : null, // disabled when invalid/busy
                    ),

                    // extra inline error text (kept)
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

// Reusable date field widget (unchanged except we call back to parent to show toast)
class _DateField extends StatelessWidget {
  final String label; // label text
  final DateTime? value; // current value
  final String Function(DateTime?) fmt; // formatter
  final ValueChanged<DateTime> onPick; // when a date picked
  final VoidCallback? onClear; // optional clear action
  final bool allowPast; // whether to allow past date

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
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text styles

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // bg
        borderRadius: BorderRadius.circular(14), // radius
        border: Border.all(color: cs.outlineVariant), // border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // pad
      child: Row(
        children: [
          Icon(Icons.event, color: cs.onSurfaceVariant), // icon
          const SizedBox(width: 10), // gap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, // top label
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2), // tiny gap
                Text(
                  fmt(value), // formatted value
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
              tooltip: 'Clear', // tooltip
              icon: const Icon(Icons.clear), // clear icon
              color: cs.onSurfaceVariant, // color
              onPressed: onClear, // action
            ),
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now(); // today
              final earliest = DateTime(2000, 1, 1); // min past date
              final init = value ?? now; // initial in picker

              // pick date
              final date = await showDatePicker(
                context: context,
                firstDate: allowPast ? earliest : now, // min date
                lastDate: DateTime(now.year + 2), // max date
                initialDate: init, // start date
              );
              if (date == null) return; // canceled
              // pick time
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(init), // start time
              );
              if (time == null) return; // canceled
              // return combined datetime
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
            icon: const Icon(Icons.edit_calendar), // edit icon
            label: const Text('Pick'), // button text
          ),
        ],
      ),
    );
  }
}
