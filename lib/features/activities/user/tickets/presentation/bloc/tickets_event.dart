// Flutter 3.35.x — Tickets events (unchanged)

abstract class TicketsEvent {
  const TicketsEvent(); // base
}

class TicketsTabChanged extends TicketsEvent {
  // statuses we support
  final String
  status; // 'Pending' | 'Completed' | 'CancelRequested' | 'Canceled'
  const TicketsTabChanged(this.status); // ctor
}

class TicketsRefresh extends TicketsEvent {
  const TicketsRefresh(); // ask bloc to reload
}

class TicketsCancelRequested extends TicketsEvent {
  final int bookingId; // id to cancel
  final String reason; // cancel reason
  const TicketsCancelRequested(this.bookingId, this.reason); // ctor
}

class TicketsDeleteRequested extends TicketsEvent {
  final int bookingId; // id to delete
  const TicketsDeleteRequested(this.bookingId); // ctor
}
