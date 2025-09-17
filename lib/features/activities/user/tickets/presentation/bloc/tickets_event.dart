abstract class TicketsEvent {
  const TicketsEvent();
}

class TicketsTabChanged extends TicketsEvent {
  final String
  status; // 'Pending' | 'Completed' | 'CancelRequested' | 'Canceled'
  const TicketsTabChanged(this.status);
}

class TicketsRefresh extends TicketsEvent {
  const TicketsRefresh();
}

class TicketsCancelRequested extends TicketsEvent {
  final int bookingId;
  final String reason;
  const TicketsCancelRequested(this.bookingId, this.reason);
}

class TicketsDeleteRequested extends TicketsEvent {
  final int bookingId;
  const TicketsDeleteRequested(this.bookingId);
}
