import '../../../tickets/domain/entities/booking_entity.dart';

abstract class TicketsState {
  const TicketsState();
}

class TicketsLoading extends TicketsState {
  final String status;
  const TicketsLoading(this.status);
}

class TicketsLoaded extends TicketsState {
  final String status;
  final List<BookingEntity> tickets;
  final bool actionInFlight;
  const TicketsLoaded(this.status, this.tickets, {this.actionInFlight = false});
}

class TicketsError extends TicketsState {
  final String status;
  final String message;
  const TicketsError(this.status, this.message);
}
