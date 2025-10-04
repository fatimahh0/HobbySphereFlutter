// Flutter 3.35.x — simple and clean
// Every line has a short comment.

// ===== Imports =====
import 'dart:io'; // File
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:image_picker/image_picker.dart'; // picker
import 'package:intl/intl.dart'; // dates

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // text field
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

import '../widgets/map_location_picker.dart'; // map widget

// Your create stack
import '../../data/services/create_item_service.dart'; // service
import '../../data/repositories/create_item_repository_impl.dart'; // repo impl
import '../../domain/usecases/create_item.dart'; // use case

// Lookups use cases
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart'; // currency
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart'; // types

// ✅ Bring the SAME BusinessRepository you use in BusinessProfile
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/repositories/business_repository.dart'; // contract
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart'; // service
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart'; // impl

// BLoC parts
import '../bloc/create_item_bloc.dart'; // bloc
import '../bloc/create_item_event.dart'; // events
import '../bloc/create_item_state.dart'; // state

// Route (to open BusinessProfile safely)
import 'package:hobby_sphere/app/router/router.dart'; // Routes + args

class CreateItemPage extends StatelessWidget {
  final int businessId; // business id
  final GetItemTypes getItemTypes; // types uc
  final GetCurrentCurrency getCurrentCurrency; // currency uc

  const CreateItemPage({
    super.key,
    required this.businessId, // required
    required this.getItemTypes, // required
    required this.getCurrentCurrency, // required
  });

  @override
  Widget build(BuildContext context) {
    // Build create use case (same as before)
    final createUsecase = CreateItem(
      CreateItemRepositoryImpl(CreateItemService()), // repo
    );

    // ✅ Use the SAME BusinessRepository stack used in BusinessProfile
    final businessRepo = BusinessRepositoryImpl(BusinessService()); // repo

    // Provide BLoC
    return BlocProvider(
      create: (_) => CreateItemBloc(
        createItem: createUsecase, // create uc
        getItemTypes: getItemTypes, // types uc
        getCurrentCurrency: getCurrentCurrency, // currency uc
        businessRepo: businessRepo, // ✅ stripe source
        businessId: businessId, // id
      )..add(CreateItemBootstrap()), // bootstrap
      child: const _CreateItemView(), // child view
    );
  }
}

class _CreateItemView extends StatefulWidget {
  const _CreateItemView();
  @override
  State<_CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<_CreateItemView> {
  // Controllers for text fields
  final _name = TextEditingController(); // name ctrl
  final _desc = TextEditingController(); // desc ctrl
  final _price = TextEditingController(); // price ctrl
  final _max = TextEditingController(); // max ctrl

  File? _pickedImage; // preview image

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _max.dispose(); // clean
    super.dispose();
  }

  // Image picker bottom sheet
  Future<void> _pickImage(BuildContext context) async {
    final t = AppLocalizations.of(context)!; // i18n
    final picker = ImagePicker(); // picker

    // Choose source
    final src = await showModalBottomSheet<ImageSource>(
      context: context, // ctx
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ), // rounded
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library), // icon
              title: Text(t.createActivityChooseLibrary), // text
              onTap: () => Navigator.pop(context, ImageSource.gallery), // pick
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera), // icon
              title: Text(t.createActivityTakePhoto), // text
              onTap: () => Navigator.pop(context, ImageSource.camera), // pick
            ),
          ],
        ),
      ),
    );

    if (src == null) return; // cancelled

    final x = await picker.pickImage(
      source: src,
      imageQuality: 85,
    ); // pick file
    if (!mounted) return; // guard
    final file = x != null ? File(x.path) : null; // to File
    setState(() => _pickedImage = file); // preview
    context.read<CreateItemBloc>().add(CreateItemImagePicked(file)); // set
  }

  // Format date or dash
  String _fmtDate(DateTime? dt) => dt == null
      ? '—'
      : DateFormat('EEE, MMM d, yyyy • HH:mm').format(dt.toLocal());

  // Open Profile to connect Stripe then re-check on return
  Future<void> _goConnectStripe(BuildContext context, int businessId) async {
    await Navigator.pushNamed(
      context,
      Routes.businessProfile, // your route
      arguments: BusinessProfileRouteArgs(
        token: '', // profile reads its own token
        businessId: businessId, // pass id
      ),
    ); // wait for return
    if (!mounted) return; // guard
    context.read<CreateItemBloc>().add(CreateItemRecheckStripe()); // recheck
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text

    return BlocConsumer<CreateItemBloc, CreateItemState>(
      listenWhen: (p, c) =>
          p.error != c.error || p.success != c.success, // listen on change
      listener: (context, state) {
        if (state.error?.isNotEmpty == true) {
          showTopToast(
            context,
            state.error!,
            type: ToastType.error,
            haptics: true,
          ); // show error
        }
        if (state.success?.isNotEmpty == true) {
          showTopToast(
            context,
            t.createActivitySuccess,
            type: ToastType.success,
            haptics: true,
          ); // success
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) Navigator.pop(context, true); // close screen
            });
          }
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateItemBloc>(); // bloc

        // Check invalid date pair
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!); // end must be after start

        return Scaffold(
          appBar: AppBar(title: Text(t.createActivityTitle)), // title
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // block when loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // page padding
                child: Column(
                  children: [
                    // ===== Stripe blocker (only if NOT connected) =====
                    if (!state.stripeConnected)
                      _StripeBlockerCard(
                        onConnectTap: () => _goConnectStripe(
                          context,
                          state.businessId!,
                        ), // open profile
                        onRefreshTap: () => bloc.add(
                          CreateItemRecheckStripe(),
                        ), // recheck inline
                      ),

                    // ===== Name =====
                    AppTextField(
                      controller: _name, // ctrl
                      label: t.createActivityActivityName, // label
                      hint: t.createActivityActivityName, // hint
                      filled: true, // style
                      margin: const EdgeInsets.only(bottom: 12), // gap
                      onChanged: (v) =>
                          bloc.add(CreateItemNameChanged(v)), // set
                    ),

                    // ===== Type =====
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: t.createActivityActivityType, // label
                        filled: true, // style
                        fillColor: cs.surfaceContainerHighest, // bg
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), // round
                          borderSide: BorderSide(
                            color: cs.outlineVariant,
                          ), // border
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true, // full width
                          value: state.itemTypeId, // selected
                          hint: Text(t.createActivitySelectType), // hint
                          items: state.types
                              .map(
                                (tpe) => DropdownMenuItem<int>(
                                  value: tpe.id, // id
                                  child: Text(
                                    tpe.name.isNotEmpty
                                        ? tpe.name
                                        : '—', // text
                                    overflow: TextOverflow.ellipsis, // safe
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null)
                              bloc.add(CreateItemTypeChanged(v)); // set
                          },
                        ),
                      ),
                    ),

                    // ===== Description =====
                    AppTextField(
                      controller: _desc, // ctrl
                      label: t.createActivityDescription, // label
                      hint: t.createActivityDescription, // hint
                      filled: true, // style
                      maxLines: 5, // multi
                      margin: const EdgeInsets.only(top: 12, bottom: 12), // gap
                      onChanged: (v) =>
                          bloc.add(CreateItemDescriptionChanged(v)), // set
                    ),

                    // ===== Map =====
                    MapLocationPicker(
                      hintText: t.createActivitySearchPlaceholder, // hint
                      initialAddress: state.address.isEmpty
                          ? null
                          : state.address, // show if has
                      onPicked: (addr, lat, lng) => bloc.add(
                        CreateItemLocationPicked(addr, lat, lng),
                      ), // set
                    ),
                    const SizedBox(height: 12), // gap
                    // ===== Max participants =====
                    AppTextField(
                      controller: _max, // ctrl
                      label: t.createActivityMaxParticipants, // label
                      hint: t.createActivityMaxParticipants, // hint
                      keyboardType: TextInputType.number, // numeric
                      filled: true, // style
                      margin: const EdgeInsets.only(bottom: 12), // gap
                      onChanged: (v) => bloc.add(
                        CreateItemMaxChanged(int.tryParse(v)),
                      ), // set
                    ),

                    // ===== Price + Currency =====
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _price, // ctrl
                            label: t.createActivityPrice, // label
                            hint: '0', // hint
                            filled: true, // style
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ), // numeric
                            onChanged: (v) => bloc.add(
                              CreateItemPriceChanged(double.tryParse(v)),
                            ), // set
                          ),
                        ),
                        const SizedBox(width: 10), // gap
                        Container(
                          height: 48, // height
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ), // pad
                          alignment: Alignment.center, // center
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer, // bg
                            border: Border.all(
                              color: cs.outlineVariant,
                            ), // border
                            borderRadius: BorderRadius.circular(14), // round
                          ),
                          child: Text(
                            state.currency?.code ?? '---',
                            style: tt.titleMedium,
                          ), // show code
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // gap
                    // ===== Start date =====
                    _DateField(
                      label: t.createActivityStartDate, // label
                      value: state.start, // value
                      fmt: _fmtDate, // formatter
                      onPick: (dt) {
                        // on pick
                        bloc.add(CreateItemStartChanged(dt)); // set start
                        final end = context
                            .read<CreateItemBloc>()
                            .state
                            .end; // read end
                        if (end == null || !end.isAfter(dt)) {
                          bloc.add(
                            CreateItemEndChanged(
                              dt.add(const Duration(hours: 1)),
                            ),
                          ); // auto +1h
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemStartChanged(null)), // clear
                    ),

                    const SizedBox(height: 10), // gap
                    // ===== End date =====
                    _DateField(
                      label: t.createActivityEndDate, // label
                      value: state.end, // value
                      fmt: _fmtDate, // formatter
                      onPick: (dt) {
                        final start = context
                            .read<CreateItemBloc>()
                            .state
                            .start; // read start
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(
                            const Duration(hours: 1),
                          ); // fix
                          bloc.add(CreateItemEndChanged(fixed)); // set
                          showTopToast(
                            context,
                            'End must be after start. Adjusted by +1h.',
                            type: ToastType.info,
                          ); // info
                        } else {
                          bloc.add(CreateItemEndChanged(dt)); // set end
                        }
                      },
                      onClear: () =>
                          bloc.add(CreateItemEndChanged(null)), // clear
                    ),

                    // ===== Date conflict hint =====
                    if (hasDateConflict) ...[
                      const SizedBox(height: 8), // gap
                      Align(
                        alignment: Alignment.centerLeft, // left
                        child: Text(
                          'End must be after Start.',
                          style: TextStyle(color: cs.error),
                        ), // hint
                      ),
                    ],

                    const SizedBox(height: 12), // gap
                    // ===== Image picker =====
                    GestureDetector(
                      onTap: () => _pickImage(context), // pick
                      child: Container(
                        height: 160, // height
                        width: double.infinity, // full width
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest, // bg
                          borderRadius: BorderRadius.circular(14), // round
                          border: Border.all(
                            color: cs.outlineVariant,
                          ), // border
                        ),
                        clipBehavior: Clip.antiAlias, // clip
                        child: _pickedImage == null
                            ? Center(
                                child: Text(
                                  t.createActivityTapToPick, // hint
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ), // muted
                                ),
                              )
                            : Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                              ), // preview
                      ),
                    ),

                    const SizedBox(height: 16), // gap
                    // ===== Submit button =====
                    AppButton(
                      label: t.createActivitySubmit, // label
                      expand: true, // full width
                      isBusy: state.loading, // spinner
                      onPressed:
                          state
                                  .ready // form ok?
                                  &&
                              state
                                  .stripeConnected // ✅ must be connected
                                  &&
                              !hasDateConflict // dates ok
                              &&
                              !state
                                  .loading // not loading
                          ? () => context
                                .read<CreateItemBloc>()
                                .add(CreateItemSubmitPressed()) // submit
                          : null, // disabled
                    ),

                    // ===== Inline error text =====
                    if (state.error != null && state.error!.isNotEmpty) ...[
                      const SizedBox(height: 12), // gap
                      Text(
                        state.error!,
                        style: TextStyle(color: cs.error),
                      ), // error text
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

// Small date field widget (unchanged style)
class _DateField extends StatelessWidget {
  final String label; // label text
  final DateTime? value; // value
  final String Function(DateTime?) fmt; // formatter
  final ValueChanged<DateTime> onPick; // pick callback
  final VoidCallback? onClear; // clear callback

  const _DateField({
    required this.label,
    required this.value,
    required this.fmt,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // bg
        borderRadius: BorderRadius.circular(14), // round
        border: Border.all(color: cs.outlineVariant), // border
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // pad
      child: Row(
        children: [
          Icon(Icons.event, color: cs.onSurfaceVariant), // icon
          const SizedBox(width: 10), // gap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left
              children: [
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ), // label
                const SizedBox(height: 2), // gap
                Text(
                  fmt(value),
                  style: tt.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ), // value
              ],
            ),
          ),
          if (value != null && onClear != null)
            IconButton(
              icon: const Icon(Icons.clear),
              color: cs.onSurfaceVariant,
              onPressed: onClear,
            ), // clear
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now(); // now
              final init = value ?? now; // init
              final date = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
                initialDate: init.isBefore(now) ? now : init,
              ); // pick date
              if (date == null) return; // cancel
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(
                  init.isBefore(now) ? now : init,
                ),
              ); // pick time
              if (time == null) return; // cancel
              onPick(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                ),
              ); // emit
            },
            icon: const Icon(Icons.edit_calendar), // icon
            label: Text(t.createActivityChange), // label
          ),
        ],
      ),
    );
  }
}

// ===== Stripe blocker card with Refresh =====
class _StripeBlockerCard extends StatelessWidget {
  final VoidCallback onConnectTap; // open profile
  final VoidCallback onRefreshTap; // re-check inline
  const _StripeBlockerCard({
    required this.onConnectTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest, // bg
        border: Border.all(color: cs.outlineVariant), // border
        borderRadius: BorderRadius.circular(14), // round
      ),
      padding: const EdgeInsets.all(14), // pad
      margin: const EdgeInsets.only(bottom: 14), // space
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // top align
        children: [
          Icon(Icons.info, color: cs.primary), // icon
          const SizedBox(width: 10), // gap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left
              children: [
                Text(
                  t.stripeConnectRequiredTitle, // "Stripe account required"
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6), // gap
                Text(
                  t.stripeConnectRequiredDesc, // short description
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10), // gap
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onConnectTap, // open profile
                      icon: const Icon(Icons.link), // icon
                      label: Text(t.registerOnStripe), // label
                    ),
                    const SizedBox(width: 8), // gap
                    IconButton(
                      tooltip: 'Refresh', // tooltip
                      onPressed: onRefreshTap, // re-check
                      icon: const Icon(Icons.refresh), // icon
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
