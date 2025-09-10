import '../entities/business_booking.dart';

abstract class BusinessBookingRepository {
  Future<List<BusinessBooking>> getBusinessBookings(String token);
  Future<void> rejectBooking(String token, int id);
  Future<void> unrejectBooking(String token, int id);
  Future<void> markPaid(String token, int id);
  Future<void> approveCancel(String token, int id);
  Future<void> rejectCancel(String token, int id);
}
