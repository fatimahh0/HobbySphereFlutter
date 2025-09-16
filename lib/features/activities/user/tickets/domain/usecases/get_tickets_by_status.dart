import '../entities/booking_entity.dart';
import '../repositories/tickets_repository.dart';

class GetTicketsByStatus {
  final TicketsRepository repo;
  GetTicketsByStatus(this.repo);

  Future<List<BookingEntity>> call(String token, String status) =>
      repo.getByStatus(token, status);
}
