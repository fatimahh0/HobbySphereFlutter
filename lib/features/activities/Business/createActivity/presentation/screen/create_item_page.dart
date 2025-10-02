// ===== Flutter 3.35.x =====
// CreateItemPage — show Stripe blocker banner and disable submit until connected.

import 'dart:io'; // File
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:image_picker/image_picker.dart'; // picker
import 'package:intl/intl.dart'; // date format

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // app button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // text field
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

// map picker
import '../widgets/map_location_picker.dart'; // map picker

// ===== create item DI (existing) =====
import '../../data/services/create_item_service.dart';
import '../../data/repositories/create_item_repository_impl.dart';
import '../../domain/usecases/create_item.dart';

// ===== lookups use cases (existing) =====
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

// ✅ reuse Business module to check Stripe (no new service)
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart';

// bloc
import '../bloc/create_item_bloc.dart';
import '../bloc/create_item_event.dart';
import '../bloc/create_item_state.dart';

// (optional) if you navigate to BusinessProfile for connecting Stripe
import 'package:hobby_sphere/app/router/router.dart'; // Routes + args (if available)

class CreateItemPage extends StatelessWidget {
  // inputs from router/DI
  final int businessId; // business id
  final GetItemTypes getItemTypes; // use case
  final GetCurrentCurrency getCurrentCurrency; // use case

  const CreateItemPage({
    super.key,
    required this.businessId, // required
    required this.getItemTypes, // required
    required this.getCurrentCurrency, // required
  });

  @override
  Widget build(BuildContext context) {
    // create item use case
    final repo = CreateItemRepositoryImpl(CreateItemService()); // repo
    final createUsecase = CreateItem(repo); // use case

    // ✅ stripe check use case (reuse your Business stack)
    final businessRepo = BusinessRepositoryImpl(BusinessService()); // repo
    final checkStripe = CheckStripeStatus(businessRepo); // use case

    // provide bloc
    return BlocProvider(
      create: (_) => CreateItemBloc(
        createItem: createUsecase, // create
        getItemTypes: getItemTypes, // types
        getCurrentCurrency: getCurrentCurrency, // currency
        checkStripeStatus: checkStripe, // ✅ stripe
        businessId: businessId, // id
      )..add(CreateItemBootstrap()), // bootstrap
      child: const _CreateItemView(), // view
    );
  }
}

class _CreateItemView extends StatefulWidget {
  const _CreateItemView();

  @override
  State<_CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<_CreateItemView> {
  // controllers
  final _name = TextEditingController(); // name
  final _desc = TextEditingController(); // description
  final _price = TextEditingController(); // price
  final _max = TextEditingController(); // capacity
  File? _pickedImage; // picked image

  @override
  void dispose() {
    // dispose controllers
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    // i18n + theme
    final t = AppLocalizations.of(context)!; // texts
    final cs = Theme.of(context).colorScheme; // colors
    // picker
    final picker = ImagePicker(); // picker instance

    // ask source
    final src = await showModalBottomSheet<ImageSource>(
      context: context, // ctx
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // bg
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // round
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap
          children: [
            const SizedBox(height: 8), // space
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant, // subtle
                borderRadius: BorderRadius.circular(4), // round
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library), // icon
              title: Text(t.createActivityChooseLibrary), // label
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery), // action
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera), // icon
              title: Text(t.createActivityTakePhoto), // label
              onTap: () => Navigator.pop(context, ImageSource.camera), // action
            ),
            const SizedBox(height: 6), // space
          ],
        ),
      ),
    );

    // cancelled
    if (src == null) return;

    // pick
    final x = await picker.pickImage(source: src, imageQuality: 85); // pick
    if (!mounted) return; // guard

    // set
    final file = x != null ? File(x.path) : null; // to file
    setState(() => _pickedImage = file); // preview
    context.read<CreateItemBloc>().add(CreateItemImagePicked(file)); // state

    // toast
    if (file != null) {
      showTopToast(
        context,
        t.createActivityPickImage,
        type: ToastType.success,
      ); // ok
    }
  }

  String _fmtDate(DateTime? dt) {
    // format or dash
    if (dt == null) return '—'; // empty
    return DateFormat(
      'EEE, MMM d, yyyy • HH:mm',
    ).format(dt.toLocal()); // nice format
  }

  @override
  Widget build(BuildContext context) {
    // i18n + theme
    final t = AppLocalizations.of(context)!; // texts
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text styles

    return BlocConsumer<CreateItemBloc, CreateItemState>(
      // listen when error or success change
      listenWhen: (p, c) => p.error != c.error || p.success != c.success,
      listener: (context, state) {
        // show error toast
        if (state.error?.isNotEmpty == true) {
          showTopToast(
            context,
            state.error!,
            type: ToastType.error,
            haptics: true,
          ); // error
        }
        // show success toast then pop
        if (state.success?.isNotEmpty == true) {
          showTopToast(
            context,
            t.createActivitySuccess,
            type: ToastType.success,
            haptics: true,
          ); // success
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) Navigator.pop(context, true); // close
            });
          }
        }
      },
      builder: (context, state) {
        // bloc
        final bloc = context.read<CreateItemBloc>(); // bloc
        // date validity
        final hasDateConflict =
            state.start != null &&
            state.end != null &&
            !state.end!.isAfter(state.start!); // check

        return Scaffold(
          appBar: AppBar(title: Text(t.createActivityTitle)), // title
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state.loading, // block during loading
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // page padding
                child: Column(
                  children: [
                    // ===== Stripe blocker (visible when not connected) =====
                    if (!state.stripeConnected)
                      _StripeBlockerCard(
                        onConnectTap: () {
                          // navigate to BusinessProfile where "Register on Stripe" exists
                          Navigator.pushNamed(
                            context,
                            Routes.businessProfile, // your route
                            arguments: BusinessProfileRouteArgs(
                              token:
                                  '', // profile will fetch token inside (keep blank if not needed here)
                              businessId: state.businessId!, // pass id
                            ),
                          );
                        },
                      ),

                    // ===== Title =====
                    AppTextField(
                      controller: _name, // ctrl
                      label: t.createActivityActivityName, // label
                      hint: t.createActivityActivityName, // hint
                      filled: true, // style
                      margin: const EdgeInsets.only(bottom: 12), // gap
                      onChanged: (v) =>
                          bloc.add(CreateItemNameChanged(v)), // event
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), // round
                          borderSide: BorderSide(
                            color: cs.outlineVariant,
                          ), // border
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14), // round
                          borderSide: BorderSide(
                            color: cs.primary,
                            width: 1.6,
                          ), // focus
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
                              bloc.add(CreateItemTypeChanged(v)); // event
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
                          bloc.add(CreateItemDescriptionChanged(v)), // event
                    ),

                    // ===== Map =====
                    MapLocationPicker(
                      hintText: t.createActivitySearchPlaceholder, // hint
                      initialAddress: state.address.isEmpty
                          ? null
                          : state.address, // initial
                      onPicked: (addr, lat, lng) => bloc.add(
                        CreateItemLocationPicked(addr, lat, lng),
                      ), // event
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
                      ), // event
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
                            ), // event
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
                          ), // code
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // gap
                    // ===== Start =====
                    _DateField(
                      label: t.createActivityStartDate, // label
                      value: state.start, // value
                      fmt: _fmtDate, // format
                      onPick: (dt) {
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
                    // ===== End =====
                    _DateField(
                      label: t.createActivityEndDate, // label
                      value: state.end, // value
                      fmt: _fmtDate, // format
                      onPick: (dt) {
                        final start = context
                            .read<CreateItemBloc>()
                            .state
                            .start; // read start
                        if (start != null && !dt.isAfter(start)) {
                          final fixed = start.add(
                            const Duration(hours: 1),
                          ); // +1h
                          bloc.add(CreateItemEndChanged(fixed)); // set fixed
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

                    // conflict hint
                    if (hasDateConflict) ...[
                      const SizedBox(height: 8), // gap
                      Align(
                        alignment: Alignment.centerLeft, // align
                        child: Text(
                          'End must be after Start.',
                          style: TextStyle(color: cs.error),
                        ), // text
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
                    // ===== Submit =====
                    AppButton(
                      label: t.createActivitySubmit, // label
                      expand: true, // full width
                      isBusy: state.loading, // spinner
                      onPressed:
                          state
                                  .ready // form ready
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

                    // text error
                    if (state.error != null && state.error!.isNotEmpty) ...[
                      const SizedBox(height: 12), // gap
                      Text(
                        state.error!,
                        style: TextStyle(color: cs.error),
                      ), // error
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

// Small date field
class _DateField extends StatelessWidget {
  final String label; // label
  final DateTime? value; // value
  final String Function(DateTime?) fmt; // formatter
  final ValueChanged<DateTime> onPick; // pick handler
  final VoidCallback? onClear; // clear handler

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
              icon: const Icon(Icons.clear), // icon
              color: cs.onSurfaceVariant, // color
              onPressed: onClear, // clear
            ),
          TextButton.icon(
            onPressed: () async {
              final now = DateTime.now(); // now
              final init = value ?? now; // init
              final date = await showDatePicker(
                context: context, // ctx
                firstDate: now, // min
                lastDate: DateTime(now.year + 2), // max
                initialDate: init.isBefore(now) ? now : init, // clamp
              );
              if (date == null) return; // cancel
              final time = await showTimePicker(
                context: context, // ctx
                initialTime: TimeOfDay.fromDateTime(
                  init.isBefore(now) ? now : init,
                ), // time
              );
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

// ===== Simple Stripe blocker card (inline) =====
class _StripeBlockerCard extends StatelessWidget {
  final VoidCallback onConnectTap; // action to open profile/connect

  const _StripeBlockerCard({required this.onConnectTap});

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
      margin: const EdgeInsets.only(bottom: 14), // space below
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // top
        children: [
          Icon(Icons.info, color: cs.primary), // icon
          const SizedBox(width: 10), // gap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left
              children: [
                Text(
                  t.stripeConnectRequiredTitle, // "Stripe account required"
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ), // bold
                ),
                const SizedBox(height: 6), // gap
                Text(
                  t.stripeConnectRequiredDesc, // short reason
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ), // muted
                ),
                const SizedBox(height: 10), // gap
                TextButton.icon(
                  onPressed: onConnectTap, // go connect
                  icon: const Icon(Icons.link), // icon
                  label: Text(t.registerOnStripe), // "Register on Stripe"
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
