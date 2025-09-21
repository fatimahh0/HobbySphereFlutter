// Calendar Tickets Screen — shows user bookings in a calendar UI.
// Folder: lib/features/activities/user/tickets/presentation/screen/calendar_tickets_screen.dart

import 'package:flutter/material.dart'; // UI widgets
import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n strings
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // your themed toast

// If you already have a shared Booking entity, import it (update the path if needed).

// If you already have a nice BookingCard widget, you can import and use it in _BookingRow.
// import 'package:hobby_sphere/shared/widgets/booking_card.dart';

/// Screen that loads all user tickets once (via the same service used by Tickets screen),
/// lets the user pick a date, and shows tickets for that date.
///
/// We accept a loader callback so you can pass your existing Ticket/Booking service directly.
class CalendarTicketsScreen extends StatefulWidget {
  // A function that returns all bookings/tickets for the current user.
  // Reuse the SAME function you use in your Tickets screen.
  final Future<List<BookingEntity>> Function() loadTickets;

  const CalendarTicketsScreen({
    super.key,
    required this.loadTickets, // inject the same service method here
  });

  @override
  State<CalendarTicketsScreen> createState() => _CalendarTicketsScreenState();
}

class _CalendarTicketsScreenState extends State<CalendarTicketsScreen> {
  // Keep the Future so we don’t reload on every rebuild
  late final Future<List<BookingEntity>> _future = widget.loadTickets();

  // Current picked day (defaults to today)
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Localized strings holder
    final t = AppLocalizations.of(context)!;

    // Theme tokens (colors, text)
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // 2 tabs (Upcoming / Past) using DefaultTabController
    return DefaultTabController(
      length: 2, // two tabs
      child: Scaffold(
        // Top app bar uses your theme automatically
        appBar: AppBar(
          // Title from l10n
          title: Text(t.calendarTitle),
          // Tab bar with localized labels
          bottom: TabBar(
            // Style comes from theme (Material 3)
            tabs: [
              Tab(text: t.calendarTabsUpcoming), // Upcoming
              Tab(text: t.calendarTabsPast), // Past
            ],
          ),
        ),

        // Load all tickets once; then filter locally by tab + date
        body: FutureBuilder<List<BookingEntity>>(
          future: _future, // same service as tickets
          builder: (context, snapshot) {
            // Show a progress while waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If error: toast + fallback text (both themed + localized)
            if (snapshot.hasError) {
              // Schedule toast after this frame so Overlay is ready
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showTopToast(
                  context,
                  '${snapshot.error}', // simple message
                  type: ToastType.error, // red theme
                  haptics: true, // short vibration
                );
              });
              return Center(
                child: Text(
                  t.calendarNoActivities, // generic “no activities” text
                  style: tt.bodyMedium?.copyWith(color: cs.error),
                ),
              );
            }

            // Safe list
            final all = snapshot.data ?? const <BookingEntity>[];

            // Two tab views: Upcoming and Past — both share the same header calendar
            return TabBarView(
              children: [
                // Tab 1: Upcoming items for selected date
                _CalendarTab(
                  all: all, // all tickets
                  selected: _selectedDate, // chosen day
                  onPick: (d) => setState(() => _selectedDate = d),
                  showUpcoming: true, // filter to upcoming
                ),
                // Tab 2: Past items for selected date
                _CalendarTab(
                  all: all,
                  selected: _selectedDate,
                  onPick: (d) => setState(() => _selectedDate = d),
                  showUpcoming: false, // filter to past
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One tab body (used twice): shows a calendar on top + list below.
/// It filters the incoming bookings by the selected date and by Upcoming/Past.
class _CalendarTab extends StatelessWidget {
  // All tickets (already fetched once)
  final List<BookingEntity> all;

  // Currently selected day on the calendar
  final DateTime selected;

  // Notify parent when user picks a new date
  final ValueChanged<DateTime> onPick;

  // true: show upcoming; false: show past
  final bool showUpcoming;

  const _CalendarTab({
    required this.all,
    required this.selected,
    required this.onPick,
    required this.showUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    // i18n
    final t = AppLocalizations.of(context)!;

    // Theme
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // "Today" (ignore time for comparing)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter tickets by:
    // 1) same calendar day as `selected`
    // 2) either upcoming (>= today) or past (< today)
    final filtered =
        all.where((b) {
            // Get the start date; if null, treat as epoch so it goes to "past"
            final dt =
                b.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);

            // Date-only versions (remove time)
            final d = DateTime(dt.year, dt.month, dt.day);
            final sel = DateTime(selected.year, selected.month, selected.day);

            // Compare day equality and upcoming/past condition
            final isSameDay = d == sel;
            final isUpcoming = d.isAfter(today) || d == today;

            return isSameDay && (showUpcoming ? isUpcoming : d.isBefore(today));
          }).toList()
          // Sort by time inside the day (earliest first)
          ..sort((a, b) {
            final ad =
                a.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bd =
                b.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
            return ad.compareTo(bd);
          });

    return Column(
      children: [
        // Calendar header: themed container + built-in CalendarDatePicker
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainer, // soft card color
              borderRadius: BorderRadius.circular(16), // rounded corners
              border: Border.all(color: cs.outlineVariant), // subtle border
            ),
            // Material built-in monthly calendar (no extra package)
            child: CalendarDatePicker(
              initialDate: selected, // current day
              firstDate: DateTime(today.year - 1), // 1 year back
              lastDate: DateTime(today.year + 2), // 2 years ahead
              onDateChanged: onPick, // callback to parent
            ),
          ),
        ),

        // Below: list for tickets on selected day (or empty state)
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    t.calendarNoActivitiesForDate, // localized empty
                    style: tt.bodyMedium?.copyWith(
                      color: cs.secondary, // muted text
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16), // nice breathing space
                  itemCount: filtered.length, // number of rows
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final booking = filtered[i]; // current item
                    return _BookingRow(booking: booking);
                  },
                ),
        ),
      ],
    );
  }
}

/// Simple row for a booking. If you already have a shared BookingCard, use it here.
/// This keeps the sample independent; swap it with your widget easily.
class _BookingRow extends StatelessWidget {
  final BookingEntity booking; // the current booking to display

  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    // Uncomment to use your existing card:
    // return BookingCard(booking: booking);

    // Themed colors/typography
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Friendly time string (empty if date is null)
    final dt = booking.startDatetime;
    final time = dt == null ? '' : TimeOfDay.fromDateTime(dt).format(context);

    // Clean Material card row
    return Card(
      elevation: 0, // flat modern card
      color: cs.surfaceContainerHighest, // more elevated container tone
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          booking.itemName, // title (activity/item name)
          style: tt.titleMedium, // themed title text
        ),
        subtitle: Text(
          [
            if (time.isNotEmpty) time, // HH:mm (localized)
            if (booking.location != null && booking.location!.isNotEmpty)
              booking.location!, // location if available
          ].join(' · '), // nice separator
          style: tt.bodyMedium?.copyWith(color: cs.secondary),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: cs.secondary,
        ), // subtle arrow
        onTap: () {
          // Optional: Navigate to booking details (route is up to your app)
          // context.push(Routes.bookingDetails(booking.id));
        },
      ),
    );
  }
}
