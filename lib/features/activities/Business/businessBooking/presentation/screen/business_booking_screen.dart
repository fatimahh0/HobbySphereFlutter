// ===== Flutter 3.35.x =====
// BusinessBookingScreen — emits realtime "booking/statusChanged" after any success
// → Analytics listens and refreshes revenue immediately.

import 'package:flutter/material.dart'; // UI base
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc helpers
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // App buttons
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart'; // Search app bar
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // Top toast

// ✅ add realtime bus + event model
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // RealtimeBus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent, Domain, ActionType

import '../bloc/business_booking_bloc.dart'; // Bloc
import '../bloc/business_booking_event.dart'; // Events
import '../bloc/business_booking_state.dart'; // State
import '../widgets/booking_card_business.dart'; // Booking card

class BusinessBookingScreen extends StatefulWidget {
  const BusinessBookingScreen({super.key}); // Stateless ctor

  @override
  State<BusinessBookingScreen> createState() => _BusinessBookingScreenState(); // State create
}

// Simple date filter (All / Past) to match your current behavior
enum _DateFilter { all, past } // Date filter enum

class _BusinessBookingScreenState extends State<BusinessBookingScreen> {
  String _searchQuery = ''; // Current search text
  _DateFilter _dateFilter = _DateFilter.all; // Date filter selection

  // Sort keys: date_desc, date_asc, price_asc, price_desc, name_asc, name_desc
  String _sortKey = 'date_desc'; // Current sort key

  // ===== Cancel sub-tab support =====
  // We normalize statuses to lowercase letters only (remove spaces/_/-).
  // Constants for the 3 cancel sub-statuses:
  static const String _CANCEL_REQUESTED =
      'cancelrequested'; // "CancelRequested"
  static const String _CANCEL_APPROVED = 'cancelapproved'; // "CancelApproved"
  static const String _CANCEL_REJECTED = 'cancelrejected'; // "CancelRejected"
  // Optional generic "canceled/cancelled" forms (defensive):
  static const String _CANCELED = 'canceled';
  static const String _CANCELLED = 'cancelled';

  // Current selected sub-tab under "Canceled"
  String _cancelSubFilter = _CANCEL_REQUESTED; // Default: show requests first

  @override
  void initState() {
    super.initState(); // Parent init
    context.read<BusinessBookingBloc>().add(
      BusinessBookingBootstrap(),
    ); // First load
  }

  // Map top status filter key -> localized label
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
        return filter; // Fallback
    }
  }

  // Sort key -> label
  String _labelForSort(String key) {
    switch (key) {
      case 'date_desc':
        return 'Date (Newest)'; // Newest first
      case 'date_asc':
        return 'Date (Oldest)'; // Oldest first
      case 'price_asc':
        return 'Price ↑'; // Price ascending
      case 'price_desc':
        return 'Price ↓'; // Price descending
      case 'name_asc':
        return 'Name A–Z'; // Name asc
      case 'name_desc':
        return 'Name Z–A'; // Name desc
      default:
        return 'Sort'; // Fallback
    }
  }

  // Cancel sub-tab key -> short label (simple English)
  String _labelForCancelSub(String key) {
    switch (key) {
      case _CANCEL_REQUESTED:
        return 'Requested'; // CancelRequested
      case _CANCEL_APPROVED:
        return 'Approved'; // CancelApproved
      case _CANCEL_REJECTED:
        return 'Rejected'; // CancelRejected
      default:
        return 'Requested'; // Default
    }
  }

  // Normalize a status string to compare (lowercase, letters only)
  String _normalize(String? v) =>
      (v ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''); // Keep a-z

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Theme
    final l10n = AppLocalizations.of(context)!; // i18n

    return Scaffold(
      appBar: AppSearchAppBar(
        hint: l10n.searchPlaceholder, // Search hint
        onQueryChanged: (q) =>
            setState(() => _searchQuery = q.toLowerCase()), // Update search
        debounceMs: 300, // Debounce
        showBack: false, // No back arrow
        filled: true, // Filled style
      ),
      backgroundColor: theme.colorScheme.surface, // BG color
      body: BlocConsumer<BusinessBookingBloc, BusinessBookingState>(
        // Show top toast on one-shot error/success
        listener: (ctx, state) {
          // ❌ error toast
          if (state.error != null) {
            showTopToast(
              ctx,
              state.error!, // Error message
              type: ToastType.error, // Red
              haptics: true, // Haptic
            );
            ctx.read<BusinessBookingBloc>().add(
              BusinessBookingClearFlash(),
            ); // Clear flash
          }

          // ✅ success toast + realtime pulse for analytics
          if (state.success != null) {
            showTopToast(
              ctx,
              l10n.bookingUpdated, // Success text
              type: ToastType.success, // Green
              haptics: true, // Haptic
            );

            // ---- REALTIME ANALYTICS PULSE (BOOKING STATUS CHANGED) ----
            // we try to get businessId from state (or from first booking).
            // if not found, we send 0 (see bloc note to treat 0 as wildcard).
            int businessId = 0; // default
            try {
              // try a field on state (if your state exposes businessId)
              final dynamic s = state; // dynamic to access safely
              if (s.businessId is int) businessId = s.businessId as int;
            } catch (_) {}

            if (businessId == 0 && state.bookings.isNotEmpty) {
              // try first booking’s businessId if exposed by entity
              final b0 = state.bookings.first;
              try {
                final dynamic d = b0;
                if (d.businessId is int) businessId = d.businessId as int;
              } catch (_) {}
            }

            // build unique event id
            final eid = 'bb-success-${DateTime.now().microsecondsSinceEpoch}';

            // emit generic "booking/statusChanged" so Analytics refreshes now
            RealtimeBus.I.emit(
              RealtimeEvent(
                eventId: eid, // unique id
                domain: Domain.booking, // booking domain
                action: ActionType.statusChanged, // status changed
                businessId: businessId, // which business (0 if unknown)
                resourceId: 0, // unknown booking id → not needed by analytics
                ts: DateTime.now(), // now
                data: {
                  'source': 'BusinessBookingScreen', // debug source
                  'hint': state.success, // optional message
                },
              ),
            );
            // ----------------------------------------------------------

            ctx.read<BusinessBookingBloc>().add(
              BusinessBookingClearFlash(),
            ); // Clear flash
          }
        },
        builder: (context, state) {
          if (state.loading) {
            // Loading spinner
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          // ===== 1) FILTER BY STATUS + SEARCH =====
          final List filtered = state.bookings.where((b) {
            final sNorm = _normalize(b.status); // Normalize status once
            bool matchesFilter; // decide match

            if (state.filter == 'all') {
              matchesFilter = true; // no filter
            } else if (state.filter == 'canceled') {
              // within "Canceled" → only the chosen sub-state
              matchesFilter = sNorm == _cancelSubFilter;
            } else {
              // other tabs → exact normalized match
              matchesFilter = sNorm == _normalize(state.filter);
            }

            // search by item name / user name
            final matchesSearch =
                _searchQuery.isEmpty ||
                (b.itemName?.toLowerCase().contains(_searchQuery) ?? false) ||
                (b.bookedBy?.toLowerCase().contains(_searchQuery) ?? false);

            return matchesFilter && matchesSearch; // final
          }).toList();

          // ===== 2) DATE FILTER (All / Past) =====
          final now = DateTime.now(); // Current time
          final filteredByDate = filtered.where((b) {
            if (_dateFilter == _DateFilter.all) return true; // keep all
            final dt = b.bookingDatetime; // Nullable date
            if (dt == null)
              return _dateFilter == _DateFilter.all; // only in All
            return dt.isBefore(now); // past only
          }).toList();

          // ===== 3) SORT =====
          filteredByDate.sort((a, b) {
            switch (_sortKey) {
              case 'date_desc':
                final ad = a.bookingDatetime;
                final bd = b.bookingDatetime;
                if (ad == null && bd == null) return 0;
                if (ad == null) return 1;
                if (bd == null) return -1;
                return bd.compareTo(ad); // newest first
              case 'date_asc':
                final ad2 = a.bookingDatetime;
                final bd2 = b.bookingDatetime;
                if (ad2 == null && bd2 == null) return 0;
                if (ad2 == null) return 1;
                if (bd2 == null) return -1;
                return ad2.compareTo(bd2); // oldest first
              case 'price_asc':
                return (a.price).compareTo(b.price); // price ↑
              case 'price_desc':
                return (b.price).compareTo(a.price); // price ↓
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

          return Column(
            children: [
              // ===== TOP STATUS TABS =====
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ), // outer pad
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
                            label: _labelForFilter(l10n, f), // tab text
                            onPressed: () {
                              // leaving "canceled" → reset sub-tab
                              if (f != 'canceled' &&
                                  _cancelSubFilter != _CANCEL_REQUESTED) {
                                setState(
                                  () => _cancelSubFilter = _CANCEL_REQUESTED,
                                );
                              }
                              // change filter
                              context.read<BusinessBookingBloc>().add(
                                BusinessBookingFilterChanged(f),
                              );
                            },
                            type: state.filter == f
                                ? AppButtonType
                                      .primary // active
                                : AppButtonType.outline, // inactive
                            size: AppButtonSize.sm, // small
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 12, // compact
                              fontWeight: state.filter == f
                                  ? FontWeight.bold
                                  : FontWeight.w500, // weight
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ===== CANCEL SUB-TABS (ONLY WHEN "CANCELED" TAB IS ACTIVE) =====
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
                              label: _labelForCancelSub(sub), // text
                              onPressed: () =>
                                  setState(() => _cancelSubFilter = sub), // set
                              type: _cancelSubFilter == sub
                                  ? AppButtonType
                                        .primary // active
                                  : AppButtonType.outline, // inactive
                              size: AppButtonSize.sm, // small
                              textStyle: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 12, // compact
                                fontWeight: _cancelSubFilter == sub
                                    ? FontWeight.bold
                                    : FontWeight.w500, // weight
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // ===== DATE FILTER + SORT BAR =====
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 8), // pad
                child: Row(
                  children: [
                    // date chips
                    Wrap(
                      spacing: 6, // space
                      children: [
                        ChoiceChip(
                          label: const Text('All dates'), // label
                          selected: _dateFilter == _DateFilter.all, // selected?
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
                              _dateFilter == _DateFilter.past, // selected?
                          onSelected: (_) => setState(
                            () => _dateFilter = _DateFilter.past,
                          ), // set
                          visualDensity: VisualDensity.compact, // compact
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // tight
                        ),
                      ],
                    ),
                    const Spacer(), // push sort right
                    // sort popup
                    PopupMenuButton<String>(
                      initialValue: _sortKey, // current
                      onSelected: (v) => setState(() => _sortKey = v), // update
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
                          borderRadius: BorderRadius.circular(10), // round
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // tight
                          children: [
                            const Icon(Icons.sort, size: 18), // icon
                            const SizedBox(width: 6), // gap
                            Text(
                              _labelForSort(_sortKey), // text
                              style: theme.textTheme.labelMedium, // style
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== LIST + PULL-TO-REFRESH =====
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<BusinessBookingBloc>().add(
                      BusinessBookingBootstrap(),
                    ); // reload
                  },
                  child: filteredByDate.isEmpty
                      // empty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 300, // space
                              child: Center(
                                child: Text(
                                  l10n.bookingsNoBookings(
                                    state.filter,
                                  ), // no items text
                                  style: theme.textTheme.bodyMedium, // style
                                ),
                              ),
                            ),
                          ],
                        )
                      // list
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ), // bottom pad
                          itemCount: filteredByDate.length, // count
                          itemBuilder: (ctx, i) => BookingCardBusiness(
                            booking: filteredByDate[i], // item
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
