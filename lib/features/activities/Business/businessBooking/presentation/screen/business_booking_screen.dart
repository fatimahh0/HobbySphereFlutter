// ===== Flutter 3.35.x =====
// BusinessBookingScreen — responsive fixed filter tabs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';

import '../bloc/business_booking_bloc.dart';
import '../bloc/business_booking_event.dart';
import '../bloc/business_booking_state.dart';
import '../widgets/booking_card_business.dart';

class BusinessBookingScreen extends StatefulWidget {
  const BusinessBookingScreen({super.key});

  @override
  State<BusinessBookingScreen> createState() => _BusinessBookingScreenState();
}

class _BusinessBookingScreenState extends State<BusinessBookingScreen> {
  String _searchQuery = '';

  /// Get localized label for filter
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Search bar in AppBar
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
            showTopToast(ctx, state.error!, type: ToastType.error);
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

          // Filter bookings by tab + search
          final filtered = state.bookings.where((b) {
            final matchesFilter =
                state.filter == 'all' ||
                b.status.toLowerCase() == state.filter.toLowerCase();
            final matchesSearch =
                _searchQuery.isEmpty ||
                (b.itemName?.toLowerCase().contains(_searchQuery) ?? false) ||
                (b.bookedBy?.toLowerCase().contains(_searchQuery) ?? false);
            return matchesFilter && matchesSearch;
          }).toList();

          return Column(
            children: [
              // ==== RESPONSIVE FIXED FILTER TABS ====
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
                              onPressed: () {
                                context.read<BusinessBookingBloc>().add(
                                  BusinessBookingFilterChanged(f),
                                );
                              },
                              type: active
                                  ? AppButtonType.primary
                                  : AppButtonType.outline,
                              size: AppButtonSize.sm,
                              textStyle: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 12, // base size
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

              // ==== BOOKINGS LIST ====
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          l10n.bookingsNoBookings(state.filter),
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) =>
                            BookingCardBusiness(booking: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
