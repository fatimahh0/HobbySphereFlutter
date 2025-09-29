// Flutter 3.35.x — Tickets states (unchanged)

// make sure you imported your BookingEntity above in the real file
// import '../../../tickets/domain/entities/booking_entity.dart';

import 'package:hobby_sphere/features/activities/user/tickets/domain/entities/booking_entity.dart';

abstract class TicketsState {
  const TicketsState(); // base
}

class TicketsLoading extends TicketsState {
  final String status; // which bucket is loading
  const TicketsLoading(this.status); // ctor
}

class TicketsLoaded extends TicketsState {
  final String status; // which bucket is shown
  final List<BookingEntity> tickets; // list of bookings
  final bool actionInFlight; // show small spinner during cancel/delete
  const TicketsLoaded(this.status, this.tickets, {this.actionInFlight = false});
}

class TicketsError extends TicketsState {
  final String status; // which bucket failed
  final String message; // error text
  const TicketsError(this.status, this.message); // ctor
}
