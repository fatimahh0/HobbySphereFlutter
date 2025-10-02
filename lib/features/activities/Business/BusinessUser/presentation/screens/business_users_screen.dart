// ===== Flutter 3.35.x =====
// BusinessUsersScreen — emit realtime event on successful cash booking
// This makes Analytics refresh instantly (revenue updates right away).

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/widgets/phone_input.dart'; // Phone input

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // Colors
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart'; // Search
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // Button

// ✅ Top Toast (for nicer messages)
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // showTopToast / ToastType

// ✅ Realtime bus + models (to ping analytics immediately)
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // global bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent

// Bloc
import '../bloc/business_users_bloc.dart'; // Bloc
import '../bloc/business_users_event.dart'; // Events
import '../bloc/business_users_state.dart'; // States

class BusinessUsersScreen extends StatefulWidget {
  final String token; // auth token
  final int businessId; // business id
  final int itemId; // activity id to assign users to
  final List<int> enrolledUserIds; // users already assigned/booked

  const BusinessUsersScreen({
    super.key,
    required this.token,
    required this.businessId,
    required this.itemId,
    this.enrolledUserIds = const [],
  });

  @override
  State<BusinessUsersScreen> createState() => _BusinessUsersScreenState();
}

class _BusinessUsersScreenState extends State<BusinessUsersScreen> {
  String _query = ""; // search text

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // translations
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // text styles

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // center title
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1), // add user icon
            tooltip: tr.addUser, // hint
            onPressed: () => _showAddUserDialog(context, tr), // open dialog
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12), // outer padding
            child: AppSearchBar(
              hint: tr.searchPlaceholder, // hint
              onQueryChanged: (q) => setState(() => _query = q), // update
            ),
          ),
          // List + states
          Expanded(
            child: BlocConsumer<BusinessUsersBloc, BusinessUsersState>(
              // Listen for success/error
              listener: (context, state) {
                // ✅ Booking success: emit realtime event, toast, then pop
                if (state is BusinessUserBookingSuccess) {
                  // Build a local event id (unique)
                  final eid = 'local-${DateTime.now().microsecondsSinceEpoch}';

                  // Emit a booking-created realtime event for THIS business
                  // -> BusinessAnalyticsBloc hears it and refreshes revenue
                  RealtimeBus.I.emit(
                    RealtimeEvent(
                      eventId: eid, // unique id
                      domain: Domain.booking, // booking domain
                      action: ActionType.created, // created
                      businessId: widget.businessId, // which business
                      resourceId: widget.itemId, // we use item (activity) id
                      ts: DateTime.now(), // now
                      data: {
                        'source': 'BusinessUsersScreen', // debug
                        'itemId': widget.itemId, // activity id
                      },
                    ),
                  );

                  // Small success toast
                  showTopToast(
                    context,
                    tr.bookingUpdated, // reuse your translation
                    type: ToastType.success,
                    haptics: true,
                  );

                  // Go back to previous screen (e.g., Insights)
                  Navigator.pop(context, true);
                }
                // ❌ Error -> toast
                else if (state is BusinessUsersError) {
                  showTopToast(
                    context,
                    state.message,
                    type: ToastType.error,
                    haptics: true,
                  );
                }
              },
              builder: (context, state) {
                // Loading spinner
                if (state is BusinessUsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Loaded list
                else if (state is BusinessUsersLoaded) {
                  var list = state.users; // all users

                  // Apply search filter locally
                  if (_query.isNotEmpty) {
                    list = list
                        .where(
                          (u) =>
                              (u.firstname + u.lastname).toLowerCase().contains(
                                _query.toLowerCase(),
                              ) ||
                              (u.email ?? "").toLowerCase().contains(
                                _query.toLowerCase(),
                              ) ||
                              (u.phoneNumber ?? "").toLowerCase().contains(
                                _query.toLowerCase(),
                              ),
                        )
                        .toList();
                  }

                  // Empty state message
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        tr.noAvailableUsers,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  // Users list
                  return ListView.separated(
                    itemCount: list.length, // count
                    separatorBuilder: (_, __) => Divider(
                      color: cs.outlineVariant,
                      thickness: 0.8,
                    ), // sep
                    itemBuilder: (_, i) {
                      final u = list[i]; // user
                      final isBooked = widget.enrolledUserIds.contains(
                        u.id,
                      ); // already in activity?

                      // Debug print (can remove)
                      // ignore: avoid_print
                      print(
                        "User: ${u.id}, enrolled: ${widget.enrolledUserIds}",
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ), // card margin
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // rounded
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12), // padding
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withOpacity(
                              0.15,
                            ), // soft bg
                            child: Icon(
                              Icons.person,
                              color: cs.primary,
                            ), // avatar icon
                          ),
                          title: Text(
                            "${u.firstname} ${u.lastname}", // full name
                            style: tt.titleMedium, // style
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // left
                            children: [
                              if (u.email != null)
                                Text(u.email!, style: tt.bodySmall), // email
                              if (u.phoneNumber != null)
                                Text(
                                  u.phoneNumber!,
                                  style: tt.bodySmall,
                                ), // phone
                              if (isBooked)
                                Text(
                                  tr.alreadyBooked, // already in activity
                                  style: tt.labelSmall?.copyWith(
                                    color: AppColors.completed, // green
                                    fontWeight: FontWeight.w600, // bold-ish
                                  ),
                                ),
                            ],
                          ),
                          // If already booked: show badge only
                          // Else: show "Assign" button
                          trailing: isBooked
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppColors.completed,
                                ) // badge
                              : SizedBox(
                                  width: 140, // fixed width button
                                  child: AppButton(
                                    label: tr.assignToActivity, // text
                                    type: AppButtonType.outline, // outline
                                    onPressed: () => _showAssignDialog(
                                      context,
                                      u.id,
                                    ), // open assign
                                  ),
                                ),
                        ),
                      );
                    },
                  );
                }
                // Error state (already toasted in listener)
                else if (state is BusinessUsersError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: tt.bodyMedium?.copyWith(color: AppColors.error),
                    ),
                  );
                }
                // Default empty
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt_1), // add icon
        label: Text(tr.addUser), // label
        onPressed: () => _showAddUserDialog(context, tr), // open add dialog
      ),
    );
  }

  /// Dialog to add new business user (phone/email toggle)
  void _showAddUserDialog(BuildContext context, AppLocalizations tr) {
    final firstCtrl = TextEditingController(); // first name
    final lastCtrl = TextEditingController(); // last name
    final emailCtrl = TextEditingController(); // email
    final phoneCtrl = TextEditingController(); // phone (E.164)
    bool usePhone = false; // toggle state

    showDialog(
      context: context, // context
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(tr.addUser), // title
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: firstCtrl, // bind
                      decoration: InputDecoration(
                        labelText: tr.firstName,
                      ), // label
                    ),
                    TextField(
                      controller: lastCtrl, // bind
                      decoration: InputDecoration(
                        labelText: tr.lastName,
                      ), // label
                    ),
                    SwitchListTile(
                      title: Text(
                        usePhone ? tr.phoneNumber : tr.email,
                      ), // toggle label
                      value: usePhone, // state
                      onChanged: (val) =>
                          setLocal(() => usePhone = val), // flip
                    ),
                    if (usePhone)
                      PhoneInput(
                        initialIso: 'CA', // default region
                        onChanged: (e164, national, iso) {
                          phoneCtrl.text = e164; // keep e164
                        },
                        onSwapToEmail: () =>
                            setLocal(() => usePhone = false), // swap back
                        submittedOnce: false, // flags
                      )
                    else
                      TextField(
                        controller: emailCtrl, // bind
                        decoration: InputDecoration(
                          labelText: tr.email,
                        ), // label
                        keyboardType: TextInputType.emailAddress, // keyboard
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), // close
                  child: Text(tr.cancel), // text
                ),
                AppButton(
                  label: tr.save, // save
                  onPressed: () {
                    final first = firstCtrl.text.trim(); // value
                    final last = lastCtrl.text.trim(); // value
                    final email = emailCtrl.text.trim(); // value
                    final phone = phoneCtrl.text.trim(); // value

                    // Validate simple
                    if (first.isEmpty || last.isEmpty) {
                      showTopToast(
                        context,
                        tr.bookingErrorFailed, // reuse error text
                        type: ToastType.error,
                        haptics: true,
                      );
                      return;
                    }
                    if ((!usePhone && email.isEmpty) ||
                        (usePhone && phone.isEmpty)) {
                      showTopToast(
                        context,
                        tr.bookingErrorFailed, // reuse error text
                        type: ToastType.error,
                        haptics: true,
                      );
                      return;
                    }

                    // Dispatch create user event
                    context.read<BusinessUsersBloc>().add(
                      CreateBusinessUserEvent(
                        token: widget.token, // token
                        firstname: first, // first
                        lastname: last, // last
                        email: !usePhone ? email : null, // email or null
                        phoneNumber: usePhone ? phone : null, // phone or null
                      ),
                    );

                    Navigator.pop(ctx); // close dialog
                  },
                  type: AppButtonType.primary, // primary button
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Dialog to assign user with participants + paid toggle
  void _showAssignDialog(BuildContext context, int userId) async {
    final tr = AppLocalizations.of(context)!; // i18n
    final participantsCtrl = TextEditingController(text: "1"); // default 1
    bool wasPaid = false; // paid switch

    final result = await showDialog<Map<String, dynamic>>(
      context: context, // context
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(tr.assignToActivity), // title
              content: Column(
                mainAxisSize: MainAxisSize.min, // fit
                children: [
                  TextField(
                    controller: participantsCtrl, // bind
                    keyboardType: TextInputType.number, // number
                    decoration: InputDecoration(
                      labelText: tr.bookingParticipants, // label
                    ),
                  ),
                  SwitchListTile(
                    title: Text(tr.paid), // paid label
                    value: wasPaid, // state
                    onChanged: (val) => setLocal(() => wasPaid = val), // toggle
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), // cancel
                  child: Text(tr.cancel), // text
                ),
                AppButton(
                  label: tr.save, // save
                  type: AppButtonType.primary, // primary
                  onPressed: () {
                    // Return selected values to parent
                    Navigator.pop(ctx, {
                      "participants":
                          int.tryParse(participantsCtrl.text) ?? 1, // safe int
                      "wasPaid": wasPaid, // paid?
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // If user confirmed assignment, fire booking event
    if (result != null) {
      context.read<BusinessUsersBloc>().add(
        BookCashEvent(
          token: widget.token, // auth
          itemId: widget.itemId, // activity id
          businessUserId: userId, // user id
          participants: result["participants"], // count
          wasPaid: result["wasPaid"], // paid flag
        ),
      );
    }
  }
}
