// Flutter 3.35.x — Calendar Tickets Screen
// - Month grid with dot markers on days that have bookings
// - Uses your TicketCard for the list (same style as Tickets screen)
// - Realtime refresh via rt.userBridge.onBooking
// - No extra packages; pure Flutter

import 'package:flutter/material.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:intl/intl.dart';

import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// Your existing card:
import '../widgets/ticket_card.dart';

// Realtime bridge (same as Tickets screen)
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;

// Optional: to build absolute image URLs for TicketCard (same trick as Tickets)
import 'package:hobby_sphere/core/network/globals.dart' as g;

class CalendarTicketsScreen extends StatefulWidget {
  /// Provide the SAME loader you use in Tickets screen (fetch all user bookings).
  final Future<List<BookingEntity>> Function() loadTickets;

  const CalendarTicketsScreen({super.key, required this.loadTickets});

  @override
  State<CalendarTicketsScreen> createState() => _CalendarTicketsScreenState();
}

class _CalendarTicketsScreenState extends State<CalendarTicketsScreen> {
  Future<List<BookingEntity>>? _future; // mutable to allow reloads
  bool _wsBound = false; // make sure we bind realtime once

  // Selected day & currently visible month
  late DateTime _selectedDate;
  late DateTime
  _visibleMonthFirst; // first day of visible month (e.g., 2025-09-01)

  // Build image base like Tickets screen (strip trailing /api)
  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _visibleMonthFirst = DateTime(now.year, now.month, 1);

    _reload(); // initial load

    // Bind realtime once the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wsBound) return;
      _wsBound = true;
      rt.userBridge.onBooking = (payload) {
        if (!mounted) return;
        _reload(); // fetch again on any booking event
      };
    });
  }

  @override
  void dispose() {
    // cleanup the realtime listener
    rt.userBridge.onBooking = null;
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = widget.loadTickets();
    });
  }

  // Helpers to move between months
  void _goPrevMonth() {
    final y = _visibleMonthFirst.year;
    final m = _visibleMonthFirst.month;
    setState(() {
      _visibleMonthFirst = DateTime(y, m - 1, 1);
      // also snap selection into the visible month if it doesn't match
      _selectedDate = DateTime(
        _visibleMonthFirst.year,
        _visibleMonthFirst.month,
        1,
      );
    });
  }

  void _goNextMonth() {
    final y = _visibleMonthFirst.year;
    final m = _visibleMonthFirst.month;
    setState(() {
      _visibleMonthFirst = DateTime(y, m + 1, 1);
      _selectedDate = DateTime(
        _visibleMonthFirst.year,
        _visibleMonthFirst.month,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.calendarTitle)),
      body: FutureBuilder<List<BookingEntity>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showTopToast(
                context,
                '${snap.error}',
                type: ToastType.error,
                haptics: true,
              );
            });
            return Center(
              child: Text(
                t.calendarNoActivities,
                style: TextStyle(color: cs.error),
              ),
            );
          }

          final bookings = snap.data ?? const <BookingEntity>[];

          // Build a map: dateWithoutTime -> list of bookings
          final Map<DateTime, List<BookingEntity>> byDay = {};
          for (final b in bookings) {
            final dt = b.startDatetime;
            if (dt == null) continue;
            final key = DateTime(dt.year, dt.month, dt.day);
            (byDay[key] ??= []).add(b);
          }

          // Get items for selected day
          final selectedKey = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          );
          final forSelected = (byDay[selectedKey] ?? [])
            ..sort((a, b) {
              final ad =
                  a.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bd =
                  b.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
              return ad.compareTo(bd);
            });

          // Split to upcoming & past relative to "today" (ignore time)
          final now = DateTime.now();
          final todayKey = DateTime(now.year, now.month, now.day);

          final upcoming = forSelected.where((b) {
            final dt =
                b.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dkey = DateTime(dt.year, dt.month, dt.day);
            return dkey.isAfter(todayKey) || dkey == todayKey;
          }).toList();

          final past = forSelected.where((b) {
            final dt =
                b.startDatetime ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dkey = DateTime(dt.year, dt.month, dt.day);
            return dkey.isBefore(todayKey);
          }).toList();

          return Column(
            children: [
              // Month header + controls
              _MonthHeader(
                month: _visibleMonthFirst,
                onPrev: _goPrevMonth,
                onNext: _goNextMonth,
              ),

              // Month grid with dot markers
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: _MonthGrid(
                  monthFirst: _visibleMonthFirst,
                  selected: _selectedDate,
                  hasEvents: byDay.map((k, v) => MapEntry(k, v.isNotEmpty)),
                  onPick: (d) => setState(() => _selectedDate = d),
                ),
              ),

              // Tab: Upcoming / Past for the selected day
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: t.calendarTabsUpcoming),
                          Tab(text: t.calendarTabsPast),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _BookingList(
                              items: upcoming,
                              imageBaseUrl: _serverRoot(),
                              emptyLabel: t.calendarNoActivitiesForDate,
                            ),
                            _BookingList(
                              items: past,
                              imageBaseUrl: _serverRoot(),
                              emptyLabel: t.calendarNoActivitiesForDate,
                            ),
                          ],
                        ),
                      ),
                    ],
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

/// Month header with prev/next
class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final title = DateFormat.yMMMM().format(month); // e.g., "September 2025"

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous month',
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

/// Simple month grid with weekday header and dots on days with events.
class _MonthGrid extends StatelessWidget {
  final DateTime monthFirst; // first day of the month
  final DateTime selected;
  final Map<DateTime, bool> hasEvents; // date-only -> has dot
  final ValueChanged<DateTime> onPick;

  const _MonthGrid({
    required this.monthFirst,
    required this.selected,
    required this.hasEvents,
    required this.onPick,
  });

  // Normalize to date-only key
  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Weekday labels (Mon..Sun) respecting locale
    final weekdayLabels = _weekdayShortLabels(context);

    // Compute grid days:
    // Start from the Monday (or locale first weekday) of the grid,
    // end at the Sunday of the last week that contains this month.
    final first = DateTime(monthFirst.year, monthFirst.month, 1);
    final firstWeekday = first.weekday; // 1=Mon..7=Sun
    final start = first.subtract(Duration(days: firstWeekday - 1));
    final last = DateTime(
      monthFirst.year,
      monthFirst.month + 1,
      0,
    ); // last of month
    final lastWeekday = last.weekday;
    final end = last.add(Duration(days: 7 - lastWeekday));

    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final selKey = _key(selected);

    return Column(
      children: [
        // weekday header
        Row(
          children: List.generate(7, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  weekdayLabels[i],
                  style: tt.labelMedium?.copyWith(color: AppColors.muted),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // days grid (6 rows x 7 cols typical)
        GridView.builder(
          itemCount: days.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (_, i) {
            final d = days[i];
            final inMonth = d.month == monthFirst.month;
            final isSelected = _key(d) == selKey;
            final hasDot = hasEvents[_key(d)] == true;

            final baseText = Theme.of(context).textTheme.bodyMedium;
            final textStyle = baseText?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: inMonth
                  ? (isSelected ? cs.onPrimary : cs.onSurface)
                  : cs.outline,
            );

            final bgColor = isSelected
                ? cs.primary
                : (inMonth ? cs.surfaceContainer : cs.surface);
            final borderColor = isSelected ? cs.primary : cs.outlineVariant;

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onPick(DateTime(d.year, d.month, d.day)),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${d.day}', style: textStyle),
                    const SizedBox(height: 2),
                    // dot indicator (hidden if no events)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: hasDot ? 1 : 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? cs.onPrimary : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> _weekdayShortLabels(BuildContext context) {
    // MON..SUN in current locale (Intl)
    // Using a fixed Monday-first order to match Grid start above.
    final dt = DateTime(2025, 9, 1); // Monday
    final fmt = DateFormat.E(Localizations.localeOf(context).toLanguageTag());
    return List.generate(
      7,
      (i) => fmt.format(dt.add(Duration(days: i))).toUpperCase(),
    );
  }
}

/// Reuses your TicketCard for a specific day bucket (Upcoming or Past).
class _BookingList extends StatelessWidget {
  final List<BookingEntity> items;
  final String imageBaseUrl;
  final String emptyLabel;

  const _BookingList({
    required this.items,
    required this.imageBaseUrl,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: tt.bodyMedium?.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final b = items[i];
        return TicketCard(
          booking: b,
          imageBaseUrl: imageBaseUrl,
          onCancel: (id, reason) {
            // You can no-op here or route to your cancel flow.
            // This widget only displays; cancellation is handled in Tickets screen.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cancel from Tickets screen please.')),
            );
          },
        );
      },
    );
  }
}
