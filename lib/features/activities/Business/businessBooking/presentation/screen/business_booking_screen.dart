// ===== Flutter 3.35.x =====
// BusinessBookingScreen — tabs + date filter (all/upcoming/past) + sort (date/price/name) + pull-to-refresh

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../bloc/business_booking_bloc.dart';
import '../bloc/business_booking_event.dart';
import '../bloc/business_booking_state.dart';
import '../widgets/booking_card_business.dart';

class BusinessBookingScreen extends StatefulWidget {
  const BusinessBookingScreen({super.key});

  @override
  State<BusinessBookingScreen> createState() => _BusinessBookingScreenState();
}

enum _DateFilter { all, past }

class _BusinessBookingScreenState extends State<BusinessBookingScreen> {
  String _searchQuery = '';
  _DateFilter _dateFilter = _DateFilter.all;

  /// sort keys: date_desc, date_asc, price_asc, price_desc, name_asc, name_desc
  String _sortKey = 'date_desc';

  @override
  void initState() {
    super.initState();
    // First load
    context.read<BusinessBookingBloc>().add(BusinessBookingBootstrap());
  }

  String _labelForFilter(AppLocalizations l10n, String filter) {
    switch (filter) {
      case 'all':
        return l10n.bookingsFiltersAll;
      case 'pending':
        return l10n.bookingsFiltersPending;
      case 'completed':
        return l10n.bookingsFiltersCompleted;
      case 'rejected':
        return l10n.bookingsFiltersRejected;
      case 'canceled':
        return l10n.bookingsFiltersCanceled;
      default:
        return filter;
    }
  }

  String _labelForSort(String key) {
    switch (key) {
      case 'date_desc':
        return 'Date (Newest)';
      case 'date_asc':
        return 'Date (Oldest)';
      case 'price_asc':
        return 'Price ↑';
      case 'price_desc':
        return 'Price ↓';
      case 'name_asc':
        return 'Name A–Z';
      case 'name_desc':
        return 'Name Z–A';
      default:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppSearchAppBar(
        hint: l10n.searchPlaceholder,
        onQueryChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
        debounceMs: 300,
        showBack: false,
        filled: true,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<BusinessBookingBloc, BusinessBookingState>(
        listener: (ctx, state) {
          if (state.error != null) {
            showTopToast(
              ctx,
              state.error!,
              type: ToastType.error,
              haptics: true,
            );
            ctx.read<BusinessBookingBloc>().add(BusinessBookingClearFlash());
          }
          if (state.success != null) {
            showTopToast(
              ctx,
              l10n.bookingUpdated,
              type: ToastType.success,
              haptics: true,
            );
            ctx.read<BusinessBookingBloc>().add(BusinessBookingClearFlash());
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          // 1) Base filter (status + search)
          final List filtered = state.bookings.where((b) {
            final status = b.status.trim().toLowerCase();

            final matchesFilter =
                state.filter == 'all' ||
                (state.filter == 'canceled'
                    ? (status == 'canceled' || status == 'cancel_requested')
                    : status == state.filter.toLowerCase());

            final matchesSearch =
                _searchQuery.isEmpty ||
                (b.itemName?.toLowerCase().contains(_searchQuery) ?? false) ||
                (b.bookedBy?.toLowerCase().contains(_searchQuery) ?? false);

            return matchesFilter && matchesSearch;
          }).toList();

          // 2) Date filter (All / Upcoming / Past)
          final now = DateTime.now();
          final filteredByDate = filtered.where((b) {
            if (_dateFilter == _DateFilter.all) return true;
            final dt = b.bookingDatetime; // may be null
            if (dt == null)
              return _dateFilter == _DateFilter.all; // keep only in "All"
            return _dateFilter == _DateFilter.past
                ? dt.isBefore(now)
                : dt.isBefore(now);
          }).toList();

          // 3) Sort
          filteredByDate.sort((a, b) {
            switch (_sortKey) {
              case 'date_desc':
                final ad = a.bookingDatetime;
                final bd = b.bookingDatetime;
                if (ad == null && bd == null) return 0;
                if (ad == null) return 1; // nulls last
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
                return (a.price).compareTo(b.price);
              case 'price_desc':
                return (b.price).compareTo(a.price);
              case 'name_asc':
                return (a.itemName ?? '').toLowerCase().compareTo(
                  (b.itemName ?? '').toLowerCase(),
                );
              case 'name_desc':
                return (b.itemName ?? '').toLowerCase().compareTo(
                  (a.itemName ?? '').toLowerCase(),
                );
              default:
                return 0;
            }
          });

          return Column(
            children: [
              // ==== STATUS TABS ====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                width: double.infinity,
                child: Row(
                  children:
                      [
                        'all',
                        'pending',
                        'completed',
                        'rejected',
                        'canceled',
                      ].map((f) {
                        final active = state.filter == f;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AppButton(
                              label: _labelForFilter(l10n, f),
                              onPressed: () => context
                                  .read<BusinessBookingBloc>()
                                  .add(BusinessBookingFilterChanged(f)),
                              type: active
                                  ? AppButtonType.primary
                                  : AppButtonType.outline,
                              size: AppButtonSize.sm,
                              textStyle: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 12,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              // ==== DATE FILTER + SORT BAR ====
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                child: Row(
                  children: [
                    // Date filter chips
                    Wrap(
                      spacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('All dates'),
                          selected: _dateFilter == _DateFilter.all,
                          onSelected: (_) =>
                              setState(() => _dateFilter = _DateFilter.all),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),

                        ChoiceChip(
                          label: const Text('Past'),
                          selected: _dateFilter == _DateFilter.past,
                          onSelected: (_) =>
                              setState(() => _dateFilter = _DateFilter.past),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Sort menu
                    PopupMenuButton<String>(
                      initialValue: _sortKey,
                      onSelected: (v) => setState(() => _sortKey = v),
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
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.4,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _labelForSort(_sortKey),
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==== LIST + PULL-TO-REFRESH ====
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<BusinessBookingBloc>().add(
                      BusinessBookingBootstrap(),
                    );
                  },
                  child: filteredByDate.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  l10n.bookingsNoBookings(state.filter),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 12),
                          itemCount: filteredByDate.length,
                          itemBuilder: (ctx, i) =>
                              BookingCardBusiness(booking: filteredByDate[i]),
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
