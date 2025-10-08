// ===== Flutter 3.35.x =====
// ReopenItemPage — Stripe-aware version (uses the same Business stack as Profile)
// Simple, clean, and commented line-by-line.

import 'dart:io'; // File type for picked images
import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:intl/intl.dart'; // Date formatting
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // serverRootNoApi()
import 'package:hobby_sphere/app/router/legacy_nav.dart';
// Create Activity stack (repo + usecase)
import 'package:hobby_sphere/features/activities/Business/createActivity/data/repositories/create_item_repository_impl.dart'; // Create repo
import 'package:hobby_sphere/features/activities/Business/createActivity/domain/usecases/create_item.dart'; // Create usecase
import '../../../createActivity/data/services/create_item_service.dart'; // Create service

// Lookups (currency + item types)
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart'; // Currency UC
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart'; // ItemTypes UC

// i18n
import 'package:hobby_sphere/l10n/app_localizations.dart'; // Strings

// Common widgets
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // Button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // Text field
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // Top toast + types

// Create Activity BLoC parts
import '../../../createActivity/presentation/bloc/create_item_bloc.dart'; // BLoC
import '../../../createActivity/presentation/bloc/create_item_event.dart'; // Events
import '../../../createActivity/presentation/bloc/create_item_state.dart'; // State
import '../../../createActivity/presentation/widgets/map_location_picker.dart'; // Map picker

// Old item entity (we reopen from this)
import '../../domain/entities/business_activity.dart'; // Old item

// ✅ Stripe check via Business Profile domain (same stack used in Profile)
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart'; // UC
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart'
    as bprof_svc; // Service
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart'
    as bprof_repo; // Repo

// ✅ Router to open BusinessProfile and come back
import 'package:hobby_sphere/app/router/router.dart'; // Routes + args

class ReopenItemPage extends StatelessWidget {
  final int businessId; // Business id (owner of the activity)
  final GetItemTypes getItemTypes; // Use case to load item types
  final GetCurrentCurrency getCurrentCurrency; // Use case to load currency
  final BusinessActivity oldItem; // Previous activity data to reuse

  const ReopenItemPage({
    super.key, // Key
    required this.businessId, // Required id
    required this.getItemTypes, // Required types UC
    required this.getCurrentCurrency, // Required currency UC
    required this.oldItem, // Required old item
  });

  @override
  Widget build(BuildContext context) {
    // Build create stack (service + repo + use case)
    final createUsecase = CreateItem(
      CreateItemRepositoryImpl(CreateItemService()), // Inject service into repo
    ); // Create activity use case

    // Build Business stack for Stripe (same as BusinessProfile)
    final bService = bprof_svc.BusinessService(); // Business HTTP service
    final bRepo = bprof_repo.BusinessRepositoryImpl(bService); // Business repo
    final checkStripe = CheckStripeStatus(bRepo); // Stripe check use case

    // Provide CreateItemBloc with all deps and bootstrap
    return BlocProvider(
      create: (_) => CreateItemBloc(
        createItem: createUsecase, // Inject create use case
        getItemTypes: getItemTypes, // Inject types use case
        getCurrentCurrency: getCurrentCurrency, // Inject currency use case
        // checkStripeStatus: checkStripe, // Removed as it's not defined
        businessId: businessId, // Scope to this business
        businessRepo: bRepo, // Pass required businessRepo
      )..add(CreateItemBootstrap()), // Load lookups + Stripe flag
      child: _ReopenItemView(oldItem: oldItem), // UI child
    );
  }
}

class _ReopenItemView extends StatefulWidget {
  final BusinessActivity oldItem; // Previous item details

  const _ReopenItemView({required this.oldItem}); // Ctor

  @override
  State<_ReopenItemView> createState() => _ReopenItemViewState(); // State
}

class _ReopenItemViewState extends State<_ReopenItemView> {
  // Controllers for text fields
  final _name = TextEditingController(); // Name field
  final _desc = TextEditingController(); // Description field
  final _price = TextEditingController(); // Price field
  final _max = TextEditingController(); // Capacity field

  File? _pickedImage; // Picked image preview

  @override
  void initState() {
    super.initState(); // Parent init

    // Prefill visible fields from the old item
    _name.text = widget.oldItem.name; // Name
    _desc.text = widget.oldItem.description; // Description
    _price.text = widget.oldItem.price.toStringAsFixed(0); // Price
    _max.text = widget.oldItem.maxParticipants.toString(); // Capacity

    // After first frame, sync the bloc state with old item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<CreateItemBloc>(); // Read bloc
      bloc.add(CreateItemNameChanged(widget.oldItem.name)); // Name
      bloc.add(
        CreateItemDescriptionChanged(widget.oldItem.description),
      ); // Desc
      bloc.add(CreateItemPriceChanged(widget.oldItem.price)); // Price
      bloc.add(CreateItemMaxChanged(widget.oldItem.maxParticipants)); // Max

      // Restore type if available
      if (widget.oldItem.itemTypeId != null) {
        bloc.add(CreateItemTypeChanged(widget.oldItem.itemTypeId!)); // Type id
      }

      // Restore location into map/bloc
      bloc.add(
        CreateItemLocationPicked(
          widget.oldItem.location, // Address text
          widget.oldItem.latitude, // Lat
          widget.oldItem.longitude, // Lng
        ),
      );

      // Keep old image URL if present (so backend can reuse it)
      if ((widget.oldItem.imageUrl ?? '').isNotEmpty) {
        bloc.add(CreateItemImageUrlRetained(widget.oldItem.imageUrl!)); // URL
      }
    });
  }

  @override
  void dispose() {
    _name.dispose(); // Dispose name
    _desc.dispose(); // Dispose desc
    _price.dispose(); // Dispose price
    _max.dispose(); // Dispose max
    super.dispose(); // Parent dispose
  }

  // Pick an image file and update bloc
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker(); // Image picker

    // Ask for source (gallery or camera)
    final src = await showModalBottomSheet<ImageSource>(
      context: context, // Context
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // BG
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Round
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library), // Icon
              title: Text(
                AppLocalizations.of(context)!.createActivityChooseLibrary,
              ), // Text
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery), // Choose
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera), // Icon
              title: Text(
                AppLocalizations.of(context)!.createActivityTakePhoto,
              ), // Text
              onTap: () => Navigator.pop(context, ImageSource.camera), // Choose
            ),
          ],
        ),
      ),
    );

    if (src == null) return; // Cancelled

    // Pick file with decent compression
    final x = await picker.pickImage(source: src, imageQuality: 85); // Pick
    if (!mounted) return; // Guard after await
    final file = x != null ? File(x.path) : null; // To File or null
    setState(() => _pickedImage = file); // Show preview
    context.read<CreateItemBloc>().add(CreateItemImagePicked(file)); // Update
  }

  // Format datetime or show dash
  String _fmtDate(DateTime? dt) => dt == null
      ? '—'
      : DateFormat('EEE, MMM d, yyyy • HH:mm').format(dt.toLocal()); // Pretty

  // Build absolute URL for old relative paths (for preview)
  String _displayUrl(String? url) {
    if (url == null || url.isEmpty) return ''; // Empty
    if (url.startsWith('http://') || url.startsWith('https://'))
      return url; // Already absolute
    final base = g.serverRootNoApi(); // http://host:port
    final sep = url.startsWith('/') ? '' : '/'; // Ensure single slash
    return '$base$sep$url'; // Join
  }

  // Open BusinessProfile to connect Stripe, then re-check on return
  Future<void> _goConnectStripe(BuildContext context, int businessId) async {
    await LegacyNav.pushNamed(
      context, // Context
      Routes.businessProfile, // Your profile route
      arguments: BusinessProfileRouteArgs(
        token: '', // Profile reads token inside (keep empty here)
        businessId: businessId, // Pass id
      ),
    ); // Wait for return
    if (!mounted) return; // Guard
    context.read<CreateItemBloc>().add(
      CreateItemRecheckStripe(),
    ); // Re-check flag
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Text styles

    // Listen for error/success and build UI
    return BlocConsumer<CreateItemBloc, CreateItemState>(
      listenWhen: (p, c) =>
          p.error != c.error ||
          p.success != c.success, // Only when messages change
      listener: (context, state) {
        if ((state.error ?? '').isNotEmpty) {
          showTopToast(
            context,
            state.error!,
            type: ToastType.error,
            haptics: true,
          ); // Error toast
        } else if ((state.success ?? '').isNotEmpty) {
          showTopToast(
            context,
            state.success!,
            type: ToastType.success,
            haptics: true,
          ); // Success toast
          Navigator.pop(context, true); // Close on success
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateItemBloc>(); // Bloc handle

        // Detect invalid dates (end must be after start)
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!); // Boolean

        // Page
        return Scaffold(
          appBar: AppBar(title: Text(loc.createActivityTitle)), // Title
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // Disable UI when loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // Page padding
                child: Column(
                  children: [
                    // ===== Stripe blocker (only when NOT connected) =====
                    if (!state.stripeConnected)
                      _StripeBlockerCard(
                        onConnectTap: () => _goConnectStripe(
                          context,
                          state.businessId!,
                        ), // Open profile
                        onRefreshTap: () => bloc.add(
                          CreateItemRecheckStripe(),
                        ), // Just refresh the flag
                      ),

                    // ===== Name =====
                    AppTextField(
                      controller: _name, // Controller
                      label: loc.createActivityActivityName, // Label
                      filled: true, // Filled style
                      margin: const EdgeInsets.only(bottom: 12), // Spacing
                      onChanged: (v) =>
                          bloc.add(CreateItemNameChanged(v)), // Update bloc
                    ),

                    // ===== Type =====
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: loc.createActivitySelectType, // Label
                        filled: true, // Filled
                        fillColor: cs.surfaceContainerHighest, // BG color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), // Round
                          borderSide: BorderSide(
                            color: cs.outlineVariant,
                          ), // Border
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true, // Full width
                          value: state.itemTypeId, // Selected id
                          hint: Text(loc.createActivitySelectType), // Hint
                          items: state.types
                              .map(
                                (t) => DropdownMenuItem<int>(
                                  value: t.id, // Value
                                  child: Text(t.name), // Label
                                ),
                              )
                              .toList(), // Build items
                          onChanged: (v) {
                            if (v != null)
                              bloc.add(CreateItemTypeChanged(v)); // Update bloc
                          },
                        ),
                      ),
                    ),

                    // ===== Description =====
                    AppTextField(
                      controller: _desc, // Controller
                      label: loc.createActivityDescription, // Label
                      filled: true, // Filled style
                      maxLines: 5, // Multiline
                      margin: const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                      ), // Spacing
                      onChanged: (v) => bloc.add(
                        CreateItemDescriptionChanged(v),
                      ), // Update bloc
                    ),

                    // ===== Map (prefilled from old item) =====
                    MapLocationPicker(
                      hintText: loc.createActivityLocation, // Hint
                      initialAddress: widget.oldItem.location, // Address
                      initialLatLng: LatLng(
                        widget.oldItem.latitude,
                        widget.oldItem.longitude,
                      ), // Coords
                      onPicked: (addr, lat, lng) => bloc.add(
                        CreateItemLocationPicked(addr, lat, lng),
                      ), // Update bloc
                    ),

                    const SizedBox(height: 12), // Space
                    // ===== Max participants =====
                    AppTextField(
                      controller: _max, // Controller
                      label: loc.createActivityMaxParticipants, // Label
                      keyboardType: TextInputType.number, // Numeric
                      filled: true, // Filled
                      margin: const EdgeInsets.only(bottom: 12), // Spacing
                      onChanged: (v) => bloc.add(
                        CreateItemMaxChanged(int.tryParse(v)),
                      ), // Parse + Set
                    ),

                    // ===== Price + Currency =====
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _price, // Controller
                            label: loc.createActivityPrice, // Label
                            hint: '0', // Hint
                            filled: true, // Filled
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ), // Decimal
                            onChanged: (v) => bloc.add(
                              CreateItemPriceChanged(double.tryParse(v)),
                            ), // Parse + Set
                          ),
                        ),
                        const SizedBox(width: 10), // Gap
                        Container(
                          height: 48, // Height
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ), // Padding
                          alignment: Alignment.center, // Center
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer, // BG
                            border: Border.all(
                              color: cs.outlineVariant,
                            ), // Border
                            borderRadius: BorderRadius.circular(14), // Round
                          ),
                          child: Text(
                            state.currency?.code ?? '---',
                            style: tt.titleMedium,
                          ), // Currency code
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // Space
                    // ===== Start date/time =====
                    _DateField(
                      label: loc.createActivityStartDate, // Label
                      value: state.start, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        bloc.add(CreateItemStartChanged(dt)); // Set start
                        final end = bloc.state.end; // Current end
                        if (end == null || !end.isAfter(dt)) {
                          bloc.add(
                            CreateItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          ); // Auto +1h
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemStartChanged(null)), // Clear
                    ),

                    const SizedBox(height: 10), // Space
                    // ===== End date/time =====
                    _DateField(
                      label: loc.createActivityEndDate, // Label
                      value: state.end, // Value
                      fmt: _fmtDate, // Formatter
                      onPick: (dt) {
                        final start = bloc.state.start; // Start
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(
                            const Duration(hours: 1),
                          ); // Fix
                          bloc.add(CreateItemEndChanged(fixed)); // Apply fix
                          showTopToast(
                            context,
                            'End must be after start. Adjusted by +1h.',
                            type: ToastType.info,
                            haptics: true,
                          ); // Info
                        } else {
                          bloc.add(CreateItemEndChanged(dt)); // Accept
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemEndChanged(null)), // Clear
                    ),

                    // Inline conflict hint
                    if (hasDateConflict) ...[
                      const SizedBox(height: 8), // Space
                      Align(
                        alignment: Alignment.centerLeft, // Left align
                        child: Text(
                          'End must be after Start.',
                          style: TextStyle(color: cs.error),
                        ), // Red hint
                      ),
                    ],

                    const SizedBox(height: 12), // Space
                    // ===== Image picker / preview =====
                    GestureDetector(
                      onTap: () => _pickImage(context), // Pick image
                      child: Container(
                        height: 160, // Height
                        width: double.infinity, // Full width
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest, // BG
                          borderRadius: BorderRadius.circular(14), // Round
                          border: Border.all(
                            color: cs.outlineVariant,
                          ), // Border
                        ),
                        clipBehavior: Clip.antiAlias, // Clip inside
                        child: _pickedImage != null
                            ? Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                              ) // Show picked file
                            : ((widget.oldItem.imageUrl ?? '')
                                      .isNotEmpty // Else old network image
                                  ? Image.network(
                                      _displayUrl(widget.oldItem.imageUrl!),
                                      fit: BoxFit.cover,
                                    ) // Show network
                                  : Center(
                                      child: Text(
                                        loc.createActivityTapToPick, // Placeholder
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ), // Muted
                                      ),
                                    )),
                      ),
                    ),

                    const SizedBox(height: 16), // Space
                    // ===== Submit (now gated by Stripe) =====
                    AppButton(
                      label: loc.createActivitySubmit, // Text
                      expand: true, // Full width
                      isBusy: state.loading, // Spinner
                      onPressed:
                          state
                                  .ready // Form ok?
                                  &&
                              state
                                  .stripeConnected // ✅ Stripe must be connected
                                  &&
                              !hasDateConflict // Dates ok
                              &&
                              !state
                                  .loading // Not loading
                          ? () => context
                                .read<CreateItemBloc>()
                                .add(CreateItemSubmitPressed()) // Submit
                          : null, // Disabled
                    ),

                    // Optional inline error
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

// Small date field widget
class _DateField extends StatelessWidget {
  final String label; // Field label
  final DateTime? value; // Current value
  final String Function(DateTime?) fmt; // Formatter
  final ValueChanged<DateTime> onPick; // On pick callback
  final VoidCallback? onClear; // On clear callback

  const _DateField({
    required this.label, // Require label
    required this.value, // Require value
    required this.fmt, // Require formatter
    required this.onPick, // Require callback
    this.onClear, // Optional clear
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Text

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // BG
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
          const SizedBox(width: 10), // Space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Left align
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ), // Label
                const SizedBox(height: 2), // Space
                Text(
                  fmt(value),
                  style: tt.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ), // Value text
              ],
            ),
          ),
          if (value != null && onClear != null)
            IconButton(
              icon: const Icon(Icons.clear),
              color: cs.onSurfaceVariant,
              onPressed: onClear,
            ), // Clear
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now(); // Current
              final init = value ?? now; // Initial
              final date = await showDatePicker(
                context: context, // Ctx
                firstDate: now, // Future only
                lastDate: DateTime(now.year + 2), // +2y
                initialDate: init.isBefore(now) ? now : init, // Clamp
              ); // Pick date
              if (date == null) return; // Cancel
              final time = await showTimePicker(
                context: context, // Ctx
                initialTime: TimeOfDay.fromDateTime(
                  init.isBefore(now) ? now : init,
                ), // Init time
              ); // Pick time
              if (time == null) return; // Cancel
              onPick(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
              ); // Emit combined
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

// ===== Simple Stripe blocker card (inline, same UX as CreateItemPage) =====
class _StripeBlockerCard extends StatelessWidget {
  final VoidCallback onConnectTap; // Open BusinessProfile
  final VoidCallback onRefreshTap; // Re-check flag

  const _StripeBlockerCard({
    required this.onConnectTap, // Ctor
    required this.onRefreshTap, // Ctor
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // Colors
    final tt = Theme.of(context).textTheme; // Text

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // BG
        border: Border.all(color: cs.outlineVariant), // Border
        borderRadius: BorderRadius.circular(14), // Round
      ),
      padding: const EdgeInsets.all(14), // Padding
      margin: const EdgeInsets.only(bottom: 14), // Spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align
        children: [
          Icon(Icons.info, color: cs.primary), // Info icon
          const SizedBox(width: 10), // Space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Left align
              children: [
                Text(
                  t.stripeConnectRequiredTitle, // "Stripe account required"
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ), // Style
                ),
                const SizedBox(height: 6), // Space
                Text(
                  t.stripeConnectRequiredDesc, // Short explanation
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ), // Muted
                ),
                const SizedBox(height: 10), // Space
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onConnectTap, // Open profile
                      icon: const Icon(Icons.link), // Icon
                      label: Text(t.registerOnStripe), // "Register on Stripe"
                    ),
                    const SizedBox(width: 8), // Space
                    IconButton(
                      tooltip: 'Refresh', // Tooltip
                      onPressed: onRefreshTap, // Re-check without leaving
                      icon: const Icon(Icons.refresh), // Icon
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
