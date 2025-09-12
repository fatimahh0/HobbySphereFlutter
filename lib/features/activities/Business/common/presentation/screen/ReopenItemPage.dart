// ===== Flutter 3.35.x =====
// ReopenItemPage — uses Top Toast (showTopToast) for success/error/info messages.

import 'dart:io'; // File
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:intl/intl.dart'; // Date format
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Map lat/lng
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // serverRootNoApi()

import 'package:hobby_sphere/features/activities/Business/createActivity/data/repositories/create_item_repository_impl.dart'; // Repo impl
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/create_item.dart'; // Use case
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart'; // Currency
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart'; // Types
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

import 'package:hobby_sphere/shared/widgets/app_button.dart'; // App button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // App text field

// ✅ Top Toast import (your widget)
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // showTopToast / ToastType

import '../../../createActivity/data/services/create_item_service.dart'; // Service

import '../../../createActivity/presentation/bloc/create_item_bloc.dart'; // Bloc
import '../../../createActivity/presentation/bloc/create_item_event.dart'; // Events
import '../../../createActivity/presentation/bloc/create_item_state.dart'; // State

import '../../../createActivity/presentation/widgets/map_location_picker.dart'; // Map picker

import '../../domain/entities/business_activity.dart'; // Old item entity

class ReopenItemPage extends StatelessWidget {
  final int businessId; // Business id
  final GetItemTypes getItemTypes; // Types use case
  final GetCurrentCurrency getCurrentCurrency; // Currency use case
  final BusinessActivity oldItem; // Old item to reuse

  const ReopenItemPage({
    super.key, // Key
    required this.businessId, // Require business id
    required this.getItemTypes, // Require types use case
    required this.getCurrentCurrency, // Require currency use case
    required this.oldItem, // Require old item
  });

  @override
  Widget build(BuildContext context) {
    final repo = CreateItemRepositoryImpl(CreateItemService()); // Build repo
    final createUsecase = CreateItem(repo); // Build use case

    // Provide Bloc and bootstrap lists
    return BlocProvider(
      create: (_) => CreateItemBloc(
        createItem: createUsecase, // Inject create use case
        getItemTypes: getItemTypes, // Inject types
        getCurrentCurrency: getCurrentCurrency, // Inject currency
        businessId: businessId, // Business scope
      )..add(CreateItemBootstrap()), // Load types/currency
      child: _ReopenItemView(oldItem: oldItem), // UI
    );
  }
}

class _ReopenItemView extends StatefulWidget {
  final BusinessActivity oldItem; // Old item data
  const _ReopenItemView({required this.oldItem}); // Ctor

  @override
  State<_ReopenItemView> createState() => _ReopenItemViewState(); // State
}

class _ReopenItemViewState extends State<_ReopenItemView> {
  final _name = TextEditingController(); // Name controller
  final _desc = TextEditingController(); // Description controller
  final _price = TextEditingController(); // Price controller
  final _max = TextEditingController(); // Capacity controller
  File? _pickedImage; // Picked image (if any)

  @override
  void initState() {
    super.initState(); // Parent init

    // Prefill text fields from old item
    _name.text = widget.oldItem.name; // Name
    _desc.text = widget.oldItem.description; // Description
    _price.text = widget.oldItem.price.toStringAsFixed(0); // Price
    _max.text = widget.oldItem.maxParticipants.toString(); // Capacity

    // After first build, sync bloc fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CreateItemBloc>(); // Bloc
      bloc.add(CreateItemNameChanged(widget.oldItem.name)); // Set name
      bloc.add(
        CreateItemDescriptionChanged(widget.oldItem.description),
      ); // Set desc
      bloc.add(CreateItemPriceChanged(widget.oldItem.price)); // Set price
      bloc.add(CreateItemMaxChanged(widget.oldItem.maxParticipants)); // Set max

      // Restore type if available
      if (widget.oldItem.itemTypeId != null) {
        bloc.add(CreateItemTypeChanged(widget.oldItem.itemTypeId!)); // Type id
      }

      // Restore location
      bloc.add(
        CreateItemLocationPicked(
          widget.oldItem.location, // address
          widget.oldItem.latitude, // lat
          widget.oldItem.longitude, // lng
        ),
      );

      // Keep old image URL if exists
      if ((widget.oldItem.imageUrl ?? '').isNotEmpty) {
        bloc.add(
          CreateItemImageUrlRetained(widget.oldItem.imageUrl!),
        ); // keep url
      }
    });
  }

  @override
  void dispose() {
    _name.dispose(); // Name
    _desc.dispose(); // Desc
    _price.dispose(); // Price
    _max.dispose(); // Max
    super.dispose(); // Parent
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker(); // Picker

    // Choose source sheet
    final src = await showModalBottomSheet<ImageSource>(
      context: context, // Context
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Themed bg
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Round
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content
          children: [
            const SizedBox(height: 8), // Spacing
            Container(
              width: 40,
              height: 4, // Grabber size
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant, // Color
                borderRadius: BorderRadius.circular(4), // Round
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library), // Icon
              title: Text(
                AppLocalizations.of(context)!.createActivityChooseLibrary,
              ), // Text
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery), // Pick gallery
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera), // Icon
              title: Text(
                AppLocalizations.of(context)!.createActivityTakePhoto,
              ), // Text
              onTap: () =>
                  Navigator.pop(context, ImageSource.camera), // Pick camera
            ),
            const SizedBox(height: 6), // Spacing
          ],
        ),
      ),
    );

    if (src == null) return; // Cancelled

    // Pick file
    final x = await picker.pickImage(source: src, imageQuality: 85); // Quality
    if (!mounted) return; // Guard

    final file = x != null ? File(x.path) : null; // To File?
    setState(() => _pickedImage = file); // Update preview
    context.read<CreateItemBloc>().add(CreateItemImagePicked(file)); // Bloc
  }

  // Format date/time or dash
  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—'; // Empty
    return DateFormat(
      'EEE, MMM d, yyyy • HH:mm',
    ).format(dt.toLocal()); // Pretty
  }

  // Make absolute URL (for old relative image paths)
  String _displayUrl(String? url) {
    if (url == null || url.isEmpty) return ''; // None
    if (url.startsWith('http://') || url.startsWith('https://'))
      return url; // Already absolute
    final base = g.serverRootNoApi(); // http://host:port
    final sep = url.startsWith('/') ? '' : '/'; // Single slash
    return '$base$sep$url'; // Join
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Typography

    // Listen to success/error and build UI
    return BlocConsumer<CreateItemBloc, CreateItemState>(
      listenWhen: (p, c) =>
          p.error != c.error || p.success != c.success, // Only message changes
      listener: (context, state) {
        // ❌ Error -> Top Toast (red)
        if ((state.error ?? '').isNotEmpty) {
          showTopToast(
            context,
            state.error!, // Message
            type: ToastType.error, // Error style
            haptics: true, // Stronger feedback
          );
        }
        // ✅ Success -> Top Toast (green) then pop
        else if ((state.success ?? '').isNotEmpty) {
          showTopToast(
            context,
            state.success!, // Message
            type: ToastType.success, // Success style
            haptics: true, // Feedback
          );
          Navigator.pop(context, true); // Close with success flag
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateItemBloc>(); // Bloc shortcut

        // Start/End must be valid
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!); // end <= start

        // Screen
        return Scaffold(
          appBar: AppBar(), // Simple AppBar
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // Lock UI while loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Screen padding
                child: Column(
                  children: [
                    // Name
                    AppTextField(
                      controller: _name, // Bind
                      label: loc.createActivityActivityName, // Label
                      filled: true, // Filled bg
                      margin: const EdgeInsets.only(bottom: 12), // Gap
                      onChanged: (v) =>
                          bloc.add(CreateItemNameChanged(v)), // Event
                    ),

                    // Type dropdown
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.createActivitySelectType, // Label
                        filled: true, // Filled
                        fillColor: cs.surfaceContainerHighest, // Bg
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), // Round
                          borderSide: BorderSide(
                            color: cs.outlineVariant,
                          ), // Color
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true, // Full width
                          value: state.itemTypeId, // Selected type
                          hint: Text(loc.createActivitySelectType), // Hint
                          items: state
                              .types // Options
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id, // Value
                                  child: Text(t.name), // Label
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              bloc.add(CreateItemTypeChanged(v)); // Event
                          },
                        ),
                      ),
                    ),

                    // Description
                    AppTextField(
                      controller: _desc, // Bind
                      label: loc.createActivityDescription, // Label
                      filled: true, // Filled
                      maxLines: 5, // Multiline
                      margin: const EdgeInsets.only(top: 12, bottom: 12), // Gap
                      onChanged: (v) =>
                          bloc.add(CreateItemDescriptionChanged(v)), // Event
                    ),

                    // Map picker (prefilled from old item)
                    MapLocationPicker(
                      hintText: loc.createActivityLocation, // Hint
                      initialAddress: widget.oldItem.location, // Address
                      initialLatLng: LatLng(
                        widget.oldItem.latitude,
                        widget.oldItem.longitude,
                      ), // Coords
                      onPicked: (addr, lat, lng) => bloc.add(
                        CreateItemLocationPicked(addr, lat, lng),
                      ), // Event
                    ),

                    const SizedBox(height: 12), // Space
                    // Max participants
                    AppTextField(
                      controller: _max, // Bind
                      label: loc.createActivityMaxParticipants, // Label
                      keyboardType: TextInputType.number, // Numbers
                      filled: true, // Filled
                      margin: const EdgeInsets.only(bottom: 12), // Gap
                      onChanged: (v) => bloc.add(
                        CreateItemMaxChanged(int.tryParse(v)),
                      ), // Parse + Event
                    ),

                    // Price + currency
                    Row(
                      children: [
                        // Price
                        Expanded(
                          child: AppTextField(
                            controller: _price, // Bind
                            label: loc.createActivityPrice, // Label
                            hint: '0', // Hint
                            filled: true, // Filled
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ), // Decimal
                            onChanged: (v) => bloc.add(
                              CreateItemPriceChanged(double.tryParse(v)),
                            ), // Parse + Event
                          ),
                        ),
                        const SizedBox(width: 10), // Space
                        // Currency badge
                        Container(
                          height: 48, // Height
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ), // Pad
                          alignment: Alignment.center, // Center
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer, // Bg
                            border: Border.all(
                              color: cs.outlineVariant,
                            ), // Border
                            borderRadius: BorderRadius.circular(14), // Round
                          ),
                          child: Text(
                            state.currency?.code ?? '---', // Code
                            style: tt.titleMedium, // Style
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // Space
                    // Start date/time
                    _DateField(
                      label: loc.createActivityStartDate, // Label
                      value: state.start, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        bloc.add(CreateItemStartChanged(dt)); // Set start
                        final end = bloc.state.end; // Current end
                        if (end == null || !end.isAfter(dt)) {
                          // Auto fix end = start + 1h
                          bloc.add(
                            CreateItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          );
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemStartChanged(null)), // Clear
                    ),

                    const SizedBox(height: 10), // Space
                    // End date/time
                    _DateField(
                      label: loc.createActivityEndDate, // Label
                      value: state.end, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        final start = bloc.state.start; // Start
                        if (start != null && !dt.isAfter(start)) {
                          // If invalid, fix and inform
                          final fixed = start.add(
                            const Duration(hours: 1),
                          ); // +1h
                          bloc.add(CreateItemEndChanged(fixed)); // Apply
                          // ℹ️ Info top toast (instead of SnackBar)
                          showTopToast(
                            context,
                            'End must be after start. Adjusted by +1h.', // Message
                            type: ToastType.info, // Neutral style
                            haptics: true, // Light haptic
                          );
                        } else {
                          bloc.add(CreateItemEndChanged(dt)); // Accept end
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemEndChanged(null)), // Clear
                    ),

                    // Inline error hint if conflict still visible
                    if (hasDateConflict) ...[
                      const SizedBox(height: 8), // Space
                      Align(
                        alignment: Alignment.centerLeft, // Left aligned
                        child: Text(
                          'End must be after Start.', // Inline hint
                          style: TextStyle(color: cs.error), // Red
                        ),
                      ),
                    ],

                    const SizedBox(height: 12), // Space
                    // Image picker / preview
                    GestureDetector(
                      onTap: () => _pickImage(context), // Open picker
                      child: Container(
                        height: 160, // Preview height
                        width: double.infinity, // Full width
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest, // Bg
                          borderRadius: BorderRadius.circular(14), // Round
                          border: Border.all(
                            color: cs.outlineVariant,
                          ), // Border
                        ),
                        clipBehavior: Clip.antiAlias, // Clip corners
                        child: _pickedImage != null
                            // Show picked file
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            // Else show old network image (if any) or placeholder
                            : ((widget.oldItem.imageUrl ?? '').isNotEmpty
                                  ? Image.network(
                                      _displayUrl(
                                        widget.oldItem.imageUrl!,
                                      ), // Absolute URL
                                      fit: BoxFit.cover, // Cover
                                    )
                                  : Center(
                                      child: Text(
                                        loc.createActivityTapToPick, // Placeholder text
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ), // Style
                                      ),
                                    )),
                      ),
                    ),

                    const SizedBox(height: 16), // Space
                    // Submit (Create new item)
                    AppButton(
                      label: loc.createActivitySubmit, // Text
                      expand: true, // Full width
                      isBusy: state.loading, // Spinner
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () => context
                                .read<CreateItemBloc>()
                                .add(CreateItemSubmitPressed()) // Submit
                          : null, // Disabled
                    ),

                    // Optional inline error text (kept)
                    if ((state.error ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12), // Space
                        child: Text(
                          state.error!,
                          style: TextStyle(color: cs.error),
                        ), // Red text
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

// Small date field widget used twice above
class _DateField extends StatelessWidget {
  final String label; // Field label
  final DateTime? value; // Current value
  final String Function(DateTime?) fmt; // Formatter
  final ValueChanged<DateTime> onPick; // Pick callback
  final VoidCallback? onClear; // Clear callback

  const _DateField({
    required this.label, // Require label
    required this.value, // Require value
    required this.fmt, // Require fmt
    required this.onPick, // Require onPick
    this.onClear, // Optional clear
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Text styles

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // Bg
        borderRadius: BorderRadius.circular(14), // Round
        border: Border.all(color: cs.outlineVariant), // Border
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // Padding
      child: Row(
        children: [
          Icon(Icons.event, color: cs.onSurfaceVariant), // Icon
          const SizedBox(width: 10), // Spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Left align
              children: [
                Text(
                  label, // Label
                  style: tt.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ), // Style
                ),
                const SizedBox(height: 2), // Spacing
                Text(fmt(value), style: tt.bodyMedium), // Value
              ],
            ),
          ),
          if (value != null && onClear != null) // Show clear if needed
            IconButton(
              tooltip: 'Clear', // Hint
              icon: const Icon(Icons.clear), // Clear icon
              onPressed: onClear, // Action
            ),
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now(); // Now
              final init = value ?? now; // Init value
              // Date picker (future dates for reopen)
              final date = await showDatePicker(
                context: context, // Context
                firstDate: now, // Not in the past
                lastDate: DateTime(now.year + 2), // +2 years
                initialDate: init.isBefore(now) ? now : init, // Clamp
              );
              if (date == null) return; // Cancelled
              // Time picker
              final time = await showTimePicker(
                context: context, // Context
                initialTime: TimeOfDay.fromDateTime(init), // Init time
              );
              if (time == null) return; // Cancelled
              // Return combined DateTime
              onPick(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
              ); // Emit
            },
            icon: const Icon(Icons.edit_calendar), // Icon
            label: Text(
              AppLocalizations.of(context)!.createActivityChange,
            ), // Text
          ),
        ],
      ),
    );
  }
}
