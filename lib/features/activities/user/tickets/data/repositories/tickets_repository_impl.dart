import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../models/booking_model.dart';
import '../services/tickets_service.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsService service;
  TicketsRepositoryImpl(this.service);

  @override
  Future<List<BookingEntity>> getByStatus(String token, String status) async {
    final raw = await service.getByStatus(token, status);
    return BookingModel.listFromJson(raw);
  }

  @override
  Future<void> cancelWithReason(String token, int bookingId, String reason) =>
      service.requestCancel(token, bookingId, reason);

  @override
  Future<void> deleteBooking(String token, int bookingId) =>
      service.deleteCanceled(token, bookingId);
}
