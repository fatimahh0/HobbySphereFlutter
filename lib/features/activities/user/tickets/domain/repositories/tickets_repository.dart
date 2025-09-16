import '../entities/booking_entity.dart';

abstract class TicketsRepository {
  Future<List<BookingEntity>> getByStatus(String token, String status);
  Future<void> cancelWithReason(String token, int bookingId, String reason);
  Future<void> deleteBooking(String token, int bookingId);
}
