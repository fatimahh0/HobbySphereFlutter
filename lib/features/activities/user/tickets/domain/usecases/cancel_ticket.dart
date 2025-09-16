import '../repositories/tickets_repository.dart';

class CancelTicket {
  final TicketsRepository repo;
  CancelTicket(this.repo);

  Future<void> call(String token, int bookingId, String reason) =>
      repo.cancelWithReason(token, bookingId, reason);
}
