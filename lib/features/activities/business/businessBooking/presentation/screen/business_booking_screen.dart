// lib/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart
// Flutter 3.35.x
// BusinessBookingScreen — fixed Canceled > Approved filter to include
// both "CancelApproved" AND final "Canceled/CANCELLED" statuses.

import 'package:flutter/material.dart'; // core UI
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // buttons
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart'; // search app bar
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

// realtime bus (if you already use it; kept as-is)
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // realtime bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // event types

import '../bloc/business_booking_bloc.dart'; // bloc
import '../bloc/business_booking_event.dart'; // events
import '../bloc/business_booking_state.dart'; // state
import '../widgets/booking_card_business.dart'; // booking card

class BusinessBookingScreen extends StatefulWidget {
  // basic ctor
  const BusinessBookingScreen({super.key});

  @override
  State<BusinessBookingScreen> createState() => _BusinessBookingScreenState();
}

// simple enum for date filter
enum _DateFilter { all, past }

class _BusinessBookingScreenState extends State<BusinessBookingScreen> {
  // search text
  String _searchQuery = '';

  // date filter value
  _DateFilter _dateFilter = _DateFilter.all;

  // sort key (by date/price/name)
  String _sortKey = 'date_desc';

  // ------ Canceled sub-tabs keys (normalized letters only) ------
  static const String _CANCEL_REQUESTED = 'cancelrequested'; // waiting decision
  static const String _CANCEL_APPROVED = 'cancelapproved'; // approved cancel
  static const String _CANCEL_REJECTED = 'cancelrejected'; // reject cancel

  // current selected canceled sub-tab
  String _cancelSubFilter = _CANCEL_REQUESTED;

  @override
  void initState() {
    super.initState(); // base state init
    // bootstrap list on open
    context.read<BusinessBookingBloc>().add(BusinessBookingBootstrap());
  }

  // helper: label for top status tabs
  String _labelForFilter(AppLocalizations l10n, String filter) {
    switch (filter) {
      case 'all':
        return l10n.bookingsFiltersAll; // All
      case 'pending':
        return l10n.bookingsFiltersPending; // Pending
      case 'completed':
        return l10n.bookingsFiltersCompleted; // Completed
      case 'rejected':
        return l10n.bookingsFiltersRejected; // Rejected
      case 'canceled':
        return l10n.bookingsFiltersCanceled; // Canceled
      default:
        return filter; // fallback
    }
  }

  // helper: label for sort menu
  String _labelForSort(String key) {
    switch (key) {
      case 'date_desc':
        return 'Date (Newest)'; // newest first
      case 'date_asc':
        return 'Date (Oldest)'; // oldest first
      case 'price_asc':
        return 'Price ↑'; // price ascending
      case 'price_desc':
        return 'Price ↓'; // price descending
      case 'name_asc':
        return 'Name A–Z'; // A–Z
      case 'name_desc':
        return 'Name Z–A'; // Z–A
      default:
        return 'Sort'; // default
    }
  }

  // helper: short label for canceled sub-tabs
  String _labelForCancelSub(String key) {
    switch (key) {
      case _CANCEL_REQUESTED:
        return 'Requested'; // requests
      case _CANCEL_APPROVED:
        return 'Approved'; // approved (incl. final canceled)
      case _CANCEL_REJECTED:
        return 'Rejected'; // rejected
      default:
        return 'Requested'; // default
    }
  }

  // helper: normalize any status string to letters-only lowercase
  String _normalize(String? v) =>
      (v ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final l10n = AppLocalizations.of(context)!; // i18n

    return Scaffold(
      // search app bar
      appBar: AppSearchAppBar(
        hint: l10n.searchPlaceholder, // placeholder
        onQueryChanged: (q) =>
            setState(() => _searchQuery = q.toLowerCase()), // update
        debounceMs: 300, // debounce
        showBack: false, // no back arrow
        filled: true, // filled
      ),
      backgroundColor: theme.colorScheme.surface, // page bg
      body: BlocConsumer<BusinessBookingBloc, BusinessBookingState>(
        // listen for error/success toasts
        listener: (ctx, state) {
          // show error toast
          if (state.error != null) {
            showTopToast(
              ctx,
              state.error!,
              type: ToastType.error,
              haptics: true,
            );
            ctx.read<BusinessBookingBloc>().add(
              BusinessBookingClearFlash(),
            ); // clear
          }
          // show success toast + optional realtime pulse
          if (state.success != null) {
            showTopToast(
              ctx,
              l10n.bookingUpdated,
              type: ToastType.success,
              haptics: true,
            );

            // emit a generic realtime pulse for analytics (safe no-op if unused)
            int businessId = 0; // default unknown
            try {
              final dynamic s = state; // dynamic access
              if (s.businessId is int)
                businessId = s.businessId as int; // try state field
            } catch (_) {}
            if (businessId == 0 && state.bookings.isNotEmpty) {
              try {
                final dynamic b0 = state.bookings.first; // first booking
                if (b0.businessId is int)
                  businessId = b0.businessId as int; // try booking field
              } catch (_) {}
            }
            RealtimeBus.I.emit(
              RealtimeEvent(
                eventId:
                    'bb-success-${DateTime.now().microsecondsSinceEpoch}', // unique id
                domain: Domain.booking, // booking domain
                action: ActionType.statusChanged, // status changed
                businessId: businessId, // which business (0 = unknown)
                resourceId: 0, // not used here
                ts: DateTime.now(), // timestamp
                data: {'source': 'BusinessBookingScreen'}, // debug data
              ),
            );

            ctx.read<BusinessBookingBloc>().add(
              BusinessBookingClearFlash(),
            ); // clear flags
          }
        },
        builder: (context, state) {
          // show loader
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          // -------- 1) FILTER BY STATUS + SEARCH (with fixed canceled Approved logic) --------
          final List filteredByStatusAndSearch = state.bookings.where((b) {
            // normalize this booking status once
            final sNorm = _normalize(b.status); // e.g., "cancelrequested"

            // decide whether this booking is included by the top tab
            bool matchesTab = true; // default include

            // filter by top status tab
            if (state.filter == 'all') {
              matchesTab = true; // include all
            } else if (state.filter == 'canceled') {
              // we are inside the "Canceled" tab → filter by sub-tab
              if (_cancelSubFilter == _CANCEL_REQUESTED) {
                // show only "CancelRequested"
                matchesTab = (sNorm == 'cancelrequested');
              } else if (_cancelSubFilter == _CANCEL_APPROVED) {
                // ✅ FIX: show "CancelApproved" **AND** final "Canceled/CANCELLED"
                matchesTab =
                    (sNorm == 'cancelapproved' ||
                    sNorm == 'canceled' ||
                    sNorm == 'cancelled');
              } else if (_cancelSubFilter == _CANCEL_REJECTED) {
                // show only "CancelRejected"
                matchesTab = (sNorm == 'cancelrejected');
              } else {
                // unknown sub-filter → include none (safe)
                matchesTab = false;
              }
            } else {
              // other tabs: exact normalized match with the tab key
              matchesTab = (sNorm == _normalize(state.filter));
            }

            // apply search on item/user names
            final matchesSearch =
                _searchQuery.isEmpty ||
                (b.itemName?.toLowerCase().contains(_searchQuery) ?? false) ||
                (b.bookedBy?.toLowerCase().contains(_searchQuery) ?? false);

            // final decision
            return matchesTab && matchesSearch;
          }).toList();

          // -------- 2) DATE FILTER (All / Past) --------
          final now = DateTime.now(); // current date-time
          final filteredByDate = filteredByStatusAndSearch.where((b) {
            if (_dateFilter == _DateFilter.all) return true; // no date filter
            final dt = b.bookingDatetime; // booking date
            if (dt == null)
              return _dateFilter == _DateFilter.all; // keep only in "All"
            return dt.isBefore(now); // past bookings
          }).toList();

          // -------- 3) SORT --------
          filteredByDate.sort((a, b) {
            switch (_sortKey) {
              case 'date_desc':
                final ad = a.bookingDatetime, bd = b.bookingDatetime; // dates
                if (ad == null && bd == null) return 0; // both null
                if (ad == null) return 1; // null last
                if (bd == null) return -1; // null last
                return bd.compareTo(ad); // newest first
              case 'date_asc':
                final ad2 = a.bookingDatetime, bd2 = b.bookingDatetime; // dates
                if (ad2 == null && bd2 == null) return 0; // both null
                if (ad2 == null) return 1; // null last
                if (bd2 == null) return -1; // null last
                return ad2.compareTo(bd2); // oldest first
              case 'price_asc':
                return (a.price).compareTo(b.price); // price low → high
              case 'price_desc':
                return (b.price).compareTo(a.price); // price high → low
              case 'name_asc':
                return (a.itemName ?? '').toLowerCase().compareTo(
                  (b.itemName ?? '').toLowerCase(),
                ); // A–Z
              case 'name_desc':
                return (b.itemName ?? '').toLowerCase().compareTo(
                  (a.itemName ?? '').toLowerCase(),
                ); // Z–A
              default:
                return 0; // no sort
            }
          });

          // -------- UI --------
          return Column(
            children: [
              // ---- top status tabs ----
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ), // pad
                width: double.infinity, // full width
                child: Row(
                  children: [
                    for (final f in [
                      'all',
                      'pending',
                      'completed',
                      'rejected',
                      'canceled',
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ), // gap
                          child: AppButton(
                            label: _labelForFilter(l10n, f), // text
                            onPressed: () {
                              // leaving "canceled" resets sub-filter to Requested
                              if (f != 'canceled' &&
                                  _cancelSubFilter != _CANCEL_REQUESTED) {
                                setState(
                                  () => _cancelSubFilter = _CANCEL_REQUESTED,
                                ); // reset
                              }
                              // change tab in bloc
                              context.read<BusinessBookingBloc>().add(
                                BusinessBookingFilterChanged(f),
                              );
                            },
                            type: state.filter == f
                                ? AppButtonType.primary
                                : AppButtonType.outline, // active/inactive
                            size: AppButtonSize.sm, // small
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 12, // compact
                              fontWeight: state.filter == f
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ---- canceled sub-tabs (only when "canceled" is selected) ----
              if (state.filter == 'canceled')
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8), // pad
                  child: Row(
                    children: [
                      for (final sub in [
                        _CANCEL_REQUESTED,
                        _CANCEL_APPROVED,
                        _CANCEL_REJECTED,
                      ])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ), // gap
                            child: AppButton(
                              label: _labelForCancelSub(sub), // short label
                              onPressed: () => setState(
                                () => _cancelSubFilter = sub,
                              ), // switch
                              type: _cancelSubFilter == sub
                                  ? AppButtonType.primary
                                  : AppButtonType.outline, // active/inactive
                              size: AppButtonSize.sm, // small
                              textStyle: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 12, // compact
                                fontWeight: _cancelSubFilter == sub
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // ---- date filter + sort ----
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 8), // pad
                child: Row(
                  children: [
                    // date chips
                    Wrap(
                      spacing: 6, // spacing
                      children: [
                        ChoiceChip(
                          label: const Text('All dates'), // label
                          selected:
                              _dateFilter == _DateFilter.all, // is selected
                          onSelected: (_) => setState(
                            () => _dateFilter = _DateFilter.all,
                          ), // set
                          visualDensity: VisualDensity.compact, // compact
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // tight
                        ),
                        ChoiceChip(
                          label: const Text('Past'), // label
                          selected:
                              _dateFilter == _DateFilter.past, // is selected
                          onSelected: (_) => setState(
                            () => _dateFilter = _DateFilter.past,
                          ), // set
                          visualDensity: VisualDensity.compact, // compact
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // tight
                        ),
                      ],
                    ),
                    const Spacer(), // push sort to right
                    // sort popup
                    PopupMenuButton<String>(
                      initialValue: _sortKey, // current key
                      onSelected: (v) => setState(() => _sortKey = v), // change
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'date_desc',
                          child: Text('Date (Newest)'),
                        ),
                        PopupMenuItem(
                          value: 'date_asc',
                          child: Text('Date (Oldest)'),
                        ),
                        PopupMenuItem(
                          value: 'price_asc',
                          child: Text('Price ↑'),
                        ),
                        PopupMenuItem(
                          value: 'price_desc',
                          child: Text('Price ↓'),
                        ),
                        PopupMenuItem(
                          value: 'name_asc',
                          child: Text('Name A–Z'),
                        ),
                        PopupMenuItem(
                          value: 'name_desc',
                          child: Text('Name Z–A'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ), // pad
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ), // border
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.4,
                          ), // bg
                          borderRadius: BorderRadius.circular(10), // radius
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // compact
                          children: [
                            const Icon(Icons.sort, size: 18), // icon
                            const SizedBox(width: 6), // gap
                            Text(
                              _labelForSort(_sortKey),
                              style: theme.textTheme.labelMedium,
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- list + pull-to-refresh ----
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // reload from server
                    context.read<BusinessBookingBloc>().add(
                      BusinessBookingBootstrap(),
                    );
                  },
                  child: filteredByDate.isEmpty
                      // empty state
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 300, // spacer
                              child: Center(
                                child: Text(
                                  l10n.bookingsNoBookings(
                                    state.filter,
                                  ), // no data text
                                  style: theme.textTheme.bodyMedium, // style
                                ),
                              ),
                            ),
                          ],
                        )
                      // list with cards
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ), // bottom pad
                          itemCount: filteredByDate.length, // count
                          itemBuilder: (ctx, i) => BookingCardBusiness(
                            booking: filteredByDate[i], // pass booking
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
