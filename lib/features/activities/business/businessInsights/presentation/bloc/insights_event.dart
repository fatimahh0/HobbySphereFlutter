// lib/features/activities/business/businessInsights/presentation/bloc/insights_event.dart
// tie this file to the bloc file that declared `part 'insights_event.dart';`
part of 'insights_bloc.dart';

// base class for all insights events
class InsightsEvent {
  const InsightsEvent(); // simple empty base
}

// load bookings/insights for a specific item
class LoadInsights extends InsightsEvent {
  final String token; // auth token string
  final int itemId; // which item to load insights for

  const LoadInsights({
    required this.token, // require token
    required this.itemId, // require item id
  });
}

// mark a booking as paid, then reload insights for that same item
class MarkAsPaid extends InsightsEvent {
  final String token; // auth token string
  final int itemId; // item whose insights we refresh
  final int bookingId; // booking to mark as paid

  const MarkAsPaid({
    required this.token, // require token
    required this.itemId, // require item id
    required this.bookingId, // require booking id
  });
}
