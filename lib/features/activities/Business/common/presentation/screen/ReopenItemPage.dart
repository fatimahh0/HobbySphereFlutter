// ===== lib/features/activities/Business/common/presentation/screen/reopen_item_page.dart =====
// Flutter 3.35.x
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

    return BlocProvider(
      create: (_) => CreateItemBloc(
        // Create Bloc
        createItem: createUsecase, // Inject use case
        getItemTypes: getItemTypes, // Inject types
        getCurrentCurrency: getCurrentCurrency, // Inject currency
        businessId: businessId, // Set business id
      )..add(CreateItemBootstrap()), // Bootstrap (load lists)
      child: _ReopenItemView(oldItem: oldItem), // Child view
    );
  }
}

class _ReopenItemView extends StatefulWidget {
  final BusinessActivity oldItem; // Old item data
  const _ReopenItemView({required this.oldItem}); // Ctor

  @override
  State<_ReopenItemView> createState() => _ReopenItemViewState(); // Create state
}

class _ReopenItemViewState extends State<_ReopenItemView> {
  final _name = TextEditingController(); // Name controller
  final _desc = TextEditingController(); // Description controller
  final _price = TextEditingController(); // Price controller
  final _max = TextEditingController(); // Capacity controller

  File? _pickedImage; // Picked image (if any)

  @override
  void initState() {
    super.initState(); // Call parent
    _name.text = widget.oldItem.name; // Prefill name
    _desc.text = widget.oldItem.description; // Prefill description
    _price.text = widget.oldItem.price.toStringAsFixed(0); // Prefill price
    _max.text = widget.oldItem.maxParticipants.toString(); // Prefill capacity

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Dispatch after build
      final bloc = context.read<CreateItemBloc>(); // Read bloc
      bloc.add(CreateItemNameChanged(widget.oldItem.name)); // Set name
      bloc.add(
        CreateItemDescriptionChanged(widget.oldItem.description),
      ); // Set desc
      bloc.add(CreateItemPriceChanged(widget.oldItem.price)); // Set price
      bloc.add(
        CreateItemMaxChanged(widget.oldItem.maxParticipants),
      ); // Set capacity
      if (widget.oldItem.itemTypeId != null) {
        // If type exists
        bloc.add(CreateItemTypeChanged(widget.oldItem.itemTypeId!)); // Set type
      }
      bloc.add(
        CreateItemLocationPicked(
          // Set location
          widget.oldItem.location,
          widget.oldItem.latitude,
          widget.oldItem.longitude,
        ),
      );
      if (widget.oldItem.imageUrl != null &&
          widget.oldItem.imageUrl!.isNotEmpty) {
        bloc.add(
          CreateItemImageUrlRetained(widget.oldItem.imageUrl!),
        ); // Keep old URL
      }
    });
  }

  @override
  void dispose() {
    _name.dispose(); // Dispose name
    _desc.dispose(); // Dispose desc
    _price.dispose(); // Dispose price
    _max.dispose(); // Dispose capacity
    super.dispose(); // Parent dispose
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker(); // Image picker
    final src = await showModalBottomSheet<ImageSource>(
      // Choose source
      context: context, // Context
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Theme bg
      shape: const RoundedRectangleBorder(
        // Rounded top
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        // Safe area
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content
          children: [
            const SizedBox(height: 8), // Spacing
            Container(
              // Grabber
              width: 40,
              height: 4, // Size
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant, // Color
                borderRadius: BorderRadius.circular(4), // Round
              ),
            ),
            ListTile(
              // Gallery option
              leading: const Icon(Icons.photo_library), // Icon
              title: Text(
                AppLocalizations.of(context)!.createActivityChooseLibrary,
              ), // Text
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery), // Pick gallery
            ),
            ListTile(
              // Camera option
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

    if (src == null) return; // User cancelled
    final x = await picker.pickImage(
      source: src,
      imageQuality: 85,
    ); // Pick file
    if (!mounted) return; // Guard after await

    final file = x != null ? File(x.path) : null; // Build File or null
    setState(() => _pickedImage = file); // Update local preview
    context.read<CreateItemBloc>().add(
      CreateItemImagePicked(file),
    ); // Update bloc
  }

  String _fmtDate(DateTime? dt) {
    // Format date
    if (dt == null) return '—'; // Dash if null
    return DateFormat(
      'EEE, MMM d, yyyy • HH:mm',
    ).format(dt.toLocal()); // Pretty text
  }

  String _displayUrl(String? url) {
    // Make absolute URL to show
    if (url == null || url.isEmpty) return ''; // Empty string if none
    if (url.startsWith('http://') || url.startsWith('https://')) {
      // Already absolute
      return url; // Return as is
    }
    final base = g.serverRootNoApi(); // http://host:port
    final sep = url.startsWith('/') ? '' : '/'; // Ensure single slash
    return '$base$sep$url'; // Join base + relative
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Text styles

    return BlocConsumer<CreateItemBloc, CreateItemState>(
      listenWhen: (p, c) =>
          p.error != c.error ||
          p.success != c.success, // Only when messages change
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          // If error
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!))); // Show error
        } else if (state.success != null && state.success!.isNotEmpty) {
          // If success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.success!)),
          ); // Show success
          Navigator.pop(context, true); // Close screen with success flag
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateItemBloc>(); // Bloc ref
        final hasDateConflict = // Date validation
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!);

        return Scaffold(
          appBar: AppBar(), // Simple AppBar
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // Disable UI while loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Page padding
                child: Column(
                  children: [
                    AppTextField(
                      // Name field
                      controller: _name, // Controller
                      label: loc.createActivityActivityName, // Label
                      filled: true, // Filled style
                      margin: const EdgeInsets.only(bottom: 12), // Spacing
                      onChanged: (v) =>
                          bloc.add(CreateItemNameChanged(v)), // Update bloc
                    ),

                    InputDecorator(
                      // Type dropdown container
                      decoration: InputDecoration(
                        labelText: loc.createActivitySelectType, // Label
                        filled: true, // Filled
                        fillColor: cs.surfaceContainerHighest, // Bg
                        border: OutlineInputBorder(
                          // Border
                          borderRadius: BorderRadius.circular(14), // Round
                          borderSide: BorderSide(
                            color: cs.outlineVariant,
                          ), // Color
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        // Hide underline
                        child: DropdownButton<int>(
                          // Dropdown
                          isExpanded: true, // Full width
                          value: state.itemTypeId, // Current value
                          hint: Text(loc.createActivitySelectType), // Hint
                          items: state
                              .types // Build options
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id, // Value
                                  child: Text(t.name), // Label
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              bloc.add(CreateItemTypeChanged(v)); // Update
                          },
                        ),
                      ),
                    ),

                    AppTextField(
                      // Description field
                      controller: _desc, // Controller
                      label: loc.createActivityDescription, // Label
                      filled: true, // Filled
                      maxLines: 5, // Multi-line
                      margin: const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                      ), // Spacing
                      onChanged: (v) => bloc.add(
                        CreateItemDescriptionChanged(v),
                      ), // Update bloc
                    ),

                    MapLocationPicker(
                      // Map picker
                      hintText: loc.createActivityLocation, // Label/Hint
                      initialAddress:
                          widget.oldItem.location, // Prefill address
                      initialLatLng: LatLng(
                        // Prefill position
                        widget.oldItem.latitude,
                        widget.oldItem.longitude,
                      ),
                      onPicked:
                          (addr, lat, lng) => // Callback
                          bloc.add(
                            CreateItemLocationPicked(addr, lat, lng),
                          ),
                    ),

                    const SizedBox(height: 12), // Spacing

                    AppTextField(
                      // Capacity field
                      controller: _max, // Controller
                      label: loc.createActivityMaxParticipants, // Label
                      keyboardType: TextInputType.number, // Number keyboard
                      filled: true, // Filled
                      margin: const EdgeInsets.only(bottom: 12), // Spacing
                      onChanged: (v) => bloc.add(
                        CreateItemMaxChanged(int.tryParse(v)),
                      ), // Parse int
                    ),

                    Row(
                      // Price + currency row
                      children: [
                        Expanded(
                          child: AppTextField(
                            // Price field
                            controller: _price, // Controller
                            label: loc.createActivityPrice, // Label
                            hint: '0', // Hint
                            filled: true, // Filled
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ), // Decimal
                            onChanged: (v) => bloc.add(
                              CreateItemPriceChanged(double.tryParse(v)),
                            ), // Parse double
                          ),
                        ),
                        const SizedBox(width: 10), // Spacing
                        Container(
                          // Currency badge
                          height: 48, // Height
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ), // Pad
                          alignment: Alignment.center, // Center text
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer, // Bg
                            border: Border.all(
                              color: cs.outlineVariant,
                            ), // Border
                            borderRadius: BorderRadius.circular(14), // Round
                          ),
                          child: Text(
                            state.currency?.code ?? '---', // Show code
                            style: tt.titleMedium, // Style
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // Spacing

                    _DateField(
                      // Start datetime
                      label: loc.createActivityStartDate, // Label
                      value: state.start, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        // On pick
                        bloc.add(CreateItemStartChanged(dt)); // Set start
                        final end = bloc.state.end; // Current end
                        if (end == null || !end.isAfter(dt)) {
                          // Ensure end after start
                          bloc.add(
                            CreateItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          ); // Auto +1h
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemStartChanged(null)), // Clear start
                    ),

                    const SizedBox(height: 10), // Spacing

                    _DateField(
                      // End datetime
                      label: loc.createActivityEndDate, // Label
                      value: state.end, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        // On pick
                        final start = bloc.state.start; // Current start
                        if (start != null && !dt.isAfter(start)) {
                          // Validate
                          final fixed = start.add(
                            const Duration(hours: 1),
                          ); // Fix
                          bloc.add(CreateItemEndChanged(fixed)); // Set fixed
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Warn
                            SnackBar(
                              content: Text(loc.createActivityErrorRequired),
                            ),
                          );
                        } else {
                          bloc.add(CreateItemEndChanged(dt)); // Set end
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemEndChanged(null)), // Clear end
                    ),

                    if (hasDateConflict) ...[
                      // Show date error
                      const SizedBox(height: 8), // Spacing
                      Align(
                        alignment: Alignment.centerLeft, // Left align
                        child: Text(
                          loc.createActivityErrorRequired, // Error text
                          style: TextStyle(color: cs.error), // Error color
                        ),
                      ),
                    ],

                    const SizedBox(height: 12), // Spacing

                    GestureDetector(
                      // Image picker tap
                      onTap: () => _pickImage(context), // Pick image
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
                        clipBehavior: Clip.antiAlias, // Clip radius
                        child:
                            _pickedImage !=
                                null // If picked new file
                            ? Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                              ) // Show file
                            : (widget.oldItem.imageUrl != null &&
                                      widget
                                          .oldItem
                                          .imageUrl!
                                          .isNotEmpty // Else old URL
                                  ? Image.network(
                                      _displayUrl(
                                        widget.oldItem.imageUrl!,
                                      ), // Make absolute for display
                                      fit: BoxFit.cover, // Cover
                                    )
                                  : Center(
                                      child: Text(
                                        // Placeholder
                                        loc.createActivityTapToPick, // Tap to pick
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ), // Style
                                      ),
                                    )),
                      ),
                    ),

                    const SizedBox(height: 16), // Spacing

                    AppButton(
                      // Submit button
                      label: loc.createActivitySubmit, // Label
                      expand: true, // Full width
                      isBusy: state.loading, // Busy spinner
                      onPressed:
                          state.ready && !hasDateConflict && !state.loading
                          ? () => context
                                .read<CreateItemBloc>()
                                .add(CreateItemSubmitPressed()) // Submit
                          : null, // Disabled
                    ),

                    if (state.error != null &&
                        state.error!.isNotEmpty) // If error text
                      Padding(
                        padding: const EdgeInsets.only(top: 12), // Spacing
                        child: Text(
                          state.error!, // Error message
                          style: TextStyle(color: cs.error), // Color
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
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ), // Label
                const SizedBox(height: 2), // Spacing
                Text(fmt(value), style: tt.bodyMedium), // Formatted value
              ],
            ),
          ),
          if (value != null &&
              onClear != null) // Show clear only when value exists
            IconButton(
              tooltip: 'Clear', // Hint
              icon: const Icon(Icons.clear), // Clear icon
              onPressed: onClear, // Clear action
            ),
          TextButton.icon(
            // Pick button
            onPressed: () async {
              // Async picker
              final now = DateTime.now(); // Now
              final init = value ?? now; // Initial value
              final date = await showDatePicker(
                // Show date picker
                context: context, // Context
                firstDate: now, // Not in the past
                lastDate: DateTime(now.year + 2), // +2 years
                initialDate: init.isBefore(now) ? now : init, // Clamp initial
              );
              if (date == null) return; // Cancelled
              final time = await showTimePicker(
                // Show time picker
                context: context, // Context
                initialTime: TimeOfDay.fromDateTime(init), // Initial time
              );
              if (time == null) return; // Cancelled
              onPick(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
              ); // Emit result
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
