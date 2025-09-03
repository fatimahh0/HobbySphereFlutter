import '../../domain/entities/business_booking.dart';
import '../../domain/repositories/business_booking_repository.dart';
import '../services/business_booking_service.dart';

class BusinessBookingRepositoryImpl implements BusinessBookingRepository {
  final BusinessBookingService service;
  BusinessBookingRepositoryImpl(this.service);

  @override
  Future<List<BusinessBooking>> getBusinessBookings(String token) async {
    final raw = await service.getBusinessBookings(token);
    return raw.map((e) => BusinessBooking.fromJson(e)).toList();
  }


  @override
  Future<void> rejectBooking(String token, int id) =>
      service.rejectBooking(token, id);

  @override
  Future<void> unrejectBooking(String token, int id) =>
      service.unrejectBooking(token, id);

  @override
  Future<void> markPaid(String token, int id) => service.markPaid(token, id);
}
