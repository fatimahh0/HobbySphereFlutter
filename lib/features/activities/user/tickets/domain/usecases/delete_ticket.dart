import '../repositories/tickets_repository.dart';

class DeleteTicket {
  final TicketsRepository repo;
  DeleteTicket(this.repo);

  Future<void> call(String token, int bookingId) =>
      repo.deleteBooking(token, bookingId);
}
